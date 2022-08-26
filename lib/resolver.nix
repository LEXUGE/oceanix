{ lib }:
with lib;
with builtins; rec {
  pathToName = path: (replaceStrings [ "/" ] [ "+" ] path);

  pathToRelative = level: path:
    strings.concatStrings (strings.intersperse "/"
      (lists.drop level (splitString "/" (toString path))));

  mkACPIRecursive = dir:
    (flatten (mapAttrsToList (name: type:
      let path = dir + "/${name}";
      in if type == "regular" then
        if lib.hasSuffix ".aml" path then [{
          Comment = name;
          # default to false
          Enabled = false;
          Path = pathToRelative 7 path;
        }] else
          [ ]
      else
        mkACPIRecursive path) (readDir dir)));

  mkACPI = pkg: mkACPIRecursive "${pkg}/EFI/OC/ACPI";

  mkDriversRecursive = dir:
    (flatten (mapAttrsToList (name: type:
      let path = dir + "/${name}";
      in if type == "regular" then
        if lib.hasSuffix ".efi" path then [{
          Comment = name;
          Enabled = false;
          Path = pathToRelative 7 path;
        }] else
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
    map (x: x.data) (oc.dag.topoSort
      (builtins.listToAttrs (mkKextsRecursive "${pkg}/EFI/OC/Kexts"))).result;

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
