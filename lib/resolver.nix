# This file contains functions used to generate related OpenCore settings based on installed resources.
{ lib }:
with lib;
with builtins; rec {
  # Make every child node default
  mkDefaultRecursive = attrs:
    mapAttrsRecursive (path: value: (mkDefault value)) attrs;

  # Transpose the generated attrsets back to the format OpenCore required, use it ONLY on ACPI and Drivers
  transpose = attrs: mapAttrsToList (n: v: v) attrs;

  pathToName = path: (replaceStrings [ "/" ] [ "+" ] path);

  pathToRelative = level: path:
    strings.concatStrings (strings.intersperse "/"
      (lists.drop level (splitString "/" (toString path))));

  mkACPIRecursive = dir:
    listToAttrs (flatten (mapAttrsToList
      (name: type:
        let path = dir + "/${name}";
        in if type == "regular" then
          if lib.hasSuffix ".aml" path then
            [
              (nameValuePair name {
                Comment = name;
                # default to false
                Enabled = false;
                Path = pathToRelative 7 path;
              })
            ]
          else
            [ ]
        else
          mkACPIRecursive path)
      (readDir dir)));

  # Generated attrsets are of the form:
  # {
  #   "foo.aml" = {
  #      Comment = "foo.aml";
  #      Enabled = false;
  #      Path = "foo.aml";
  #   };
  # }
  mkACPI = pkg: mkACPIRecursive "${pkg}/EFI/OC/ACPI";

  mkDriversRecursive = dir:
    listToAttrs (flatten (mapAttrsToList
      (name: type:
        let path = dir + "/${name}";
        in if type == "regular" then
          if lib.hasSuffix ".efi" path then
            [
              (nameValuePair name {
                Comment = name;
                Enabled = false;
                Path = pathToRelative 7 path;
              })
            ]
          else
            [ ]
        else
          mkDriversRecursive path)
      (readDir dir)));

  mkDrivers = pkg: mkDriversRecursive "${pkg}/EFI/OC/Drivers";

  # How to generate Kexts
  # 1. Parse kexts using mkKexts: pkg -> attrset
  # 2. Make it recursively default
  # 3. Do recursive enable on plugins
  # 4. Apply DAG ordering
  # 5. Remove passthru

  # parent: the name of the parent Kext, null if it is at the top level
  # dir: current dir
  mkKextsRecursive = pkgs: parent: dir:
    (flatten (mapAttrsToList
      (name: type:
        let
          path = dir + "/${name}";
          # if this is folder, try to see if it is a kext
        in
        if (type == "directory") then
          if hasSuffix ".kext" path then
          # if it is a kext, we shall resolve dependency and add it to a list
            let
              infoListPath = path + "/Contents/Info.plist";
              info = parsePlist pkgs infoListPath;
            in
            [
              (nameValuePair name ({
                Arch = "Any";
                Comment = name;
                Enabled = false;
                BundlePath = pathToRelative 7 path;
                ExecutablePath = "Contents/MacOS/"
                + info.CFBundleExecutable or "";
                PlistPath = "Contents/Info.plist";

                # passthru should be removed later
                passthru = {
                  identifier = info.CFBundleIdentifier;
                  parent = parent;
                  depList = trace "${name} (${info.CFBundleIdentifier}) depends on [${toString (parseKextDeps info)}]" (parseKextDeps info);
                };
              }))
            ] ++
            # recursively descend for plugins, changing parent to the current kext
            (mkKextsRecursive pkgs name path)
          else
          # recursively descend, inheriting current parent
            mkKextsRecursive pkgs parent path
        # if it is not a folder, we do nothing.
        else
          [ ])
      (readDir dir)));

  mkKexts = pkgs: pkg: listToAttrs (mkKextsRecursive pkgs null "${pkg}/EFI/OC/Kexts");

  # recursively enable plugins before transpose
  enablePluginsRecursive = attrs:
    mapAttrs
      (name: value: {
        inherit (value) Arch Comment BundlePath ExecutablePath PlistPath passthru;
        Enabled =
          if value.passthru.parent == null then
            value.Enabled
          else
            attrs."${value.passthru.parent}".Enabled;
      })
      attrs;

  orderKexts = attrs:
    map (x: x.data)
      (oc.dag.topoSort
        (mapAttrs (name: value: oc.dag.entryAfter value.passthru.depList value)
          (mapAttrs'
            (name: value: nameValuePair (value.passthru.identifier) value)
            attrs))).result;

  removePassthru = list:
    map
      (value: {
        inherit (value) Arch Comment BundlePath ExecutablePath PlistPath Enabled;
      })
      list;

  # used by end-user
  finalizeKexts = autoEnablePlugins: attrs:
    removePassthru (orderKexts
      (if autoEnablePlugins then enablePluginsRecursive attrs else attrs));

  parseKextDeps = attrs: mapAttrsToList (name: value: name) attrs.OSBundleLibraries or { };

  parsePlist' = pkgs: path: pkgs.runCommand "parsePlist_${pathToRelative 7 path}" { nativeBuildInputs = [ pkgs.libplist ]; } ''
    mkdir $out
    cp "${path}" ./plist.in
    substituteInPlace ./plist.in --replace "<data>" "<string>" --replace "</data>" "</string>" --replace "<date>" "<string>" --replace "</date>" "<string>"
    plistutil -i ./plist.in -o $out/plist.out -f json
  '';

  parsePlist = pkgs: plist: fromJSON (readFile "${parsePlist' pkgs plist}/plist.out");
}