# This file contains functions used to generate related OpenCore settings based on installed resources.
{ lib }:
with lib;
with builtins; rec {
  # Make every child node default
  mkDefaultRecursive = attrs:
    mapAttrsRecursive (path: value: (mkDefault value)) attrs;

  # Transpose the generated attrsets back to the format OpenCore required
  transpose = attrs: mapAttrsToList (n: v: v) attrs;

  pathToName = path: (replaceStrings [ "/" ] [ "+" ] path);

  pathToRelative = level: path:
    strings.concatStrings (strings.intersperse "/"
      (lists.drop level (splitString "/" (toString path))));

  mkACPIRecursive = dir:
    listToAttrs (flatten (mapAttrsToList (name: type:
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
        mkACPIRecursive path) (readDir dir)));

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
    listToAttrs (flatten (mapAttrsToList (name: type:
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
        mkDriversRecursive path) (readDir dir)));

  mkDrivers = pkg: mkDriversRecursive "${pkg}/EFI/OC/Drivers";

  mkKextsRecursive = dir:
    (flatten (mapAttrsToList (name: type:
      let
        path = dir + "/${name}";
        # if this is folder, try to see if it is a kext
      in if (type == "directory") then
        if hasSuffix ".kext" path then
        # if it is a kext, we shall resolve dependency and add it to a list
          let infoListPath = path + "/Contents/Info.plist";
          in [
            (nameValuePair (parseKextIdentifier infoListPath) (oc.dag.entryAfter
              (trace
                "${name} depends on [${toString (parseKextDeps infoListPath)}]"
                (parseKextDeps infoListPath)) {
                  Arch = "Any";
                  Comment = name;
                  Enabled = false;
                  BundlePath = pathToRelative 7 path;
                  ExecutablePath = "Contents/MacOS/"
                    + (parseKextExecName infoListPath);
                  PlistPath = "Contents/Info.plist";
                }))
          ] ++
          # recursively descend for plugins
          (mkKextsRecursive path)
        else
        # recursively descend
          mkKextsRecursive path
          # if it is not a folder, we do nothing.
      else
        [ ]) (readDir dir)));

  mkKexts = pkg:
    listToAttrs (map (x: {
      name = x.data.Comment;
      value = x.data;
    }) (oc.dag.topoSort
      (builtins.listToAttrs (mkKextsRecursive "${pkg}/EFI/OC/Kexts"))).result);

  # nix requires us to do exact matching. Therefore, we need `.*` around the expressions we regularly would have write.
  parseKextIdentifier = path:
    head (match ''
      .*<key>CFBundleIdentifier</key>[
      	]*<string>([.a-zA-Z0-9]*)</string>.*'' (readFile path));

  parseKextExecName = path:
    head (match ''
      .*<key>CFBundleExecutable</key>[
      	]*<string>([.a-zA-Z0-9]*)</string>.*'' (readFile path));

  # FIXME: We cannot make it lazy.
  getKextDepsSection = path:
    let
      fallback = (match ''
        .*<key>OSBundleLibraries</key>[
        	]*<dict>(.*?)</dict>.*'' (readFile path));
      preferred = (match ''
        .*<key>OSBundleLibraries</key>[
        	]*<dict>(.*?)</dict>[
        	]*<key>OSBundleRequired</key>.*'' (readFile path));
    in head (if preferred != null then preferred else fallback);

  parseKextDeps = path:
    flatten (map (line: parseKextDeps' line)
      (strings.splitString "\n" (getKextDepsSection path)));

  # Luckily this doesn't match <key>OSBundleLibraries_x86_64</key>
  parseKextDeps' = line:
    let result = (match ".*<key>([.a-zA-Z0-9]+)</key>.*" line);
    in if result == null then [ ] else result;
}
