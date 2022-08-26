{ lib }:
with (lib).trivial;
let
  libStr = lib.strings;
  libAttr = lib.attrsets;

  plistCustomTypeKey =
    "__plist_custom_type__"; # a relatively unique attribute key to detect custom types

  inherit (lib) isFunction;
in rec {
  mkCustom = type: value: {
    ${plistCustomTypeKey} = type;
    inherit value;
  };
  mkData = mkCustom "data";
  mkDate = mkCustom "date";

  # PLIST handling
  toPlist = { }:
    v:
    with builtins;
    let
      isFloat = isFloat or (x: false);
      isCustomType = x: isAttrs x && hasAttr plistCustomTypeKey x;
      expr = ind: x:
        # custom type has to be placed relatively in front of others types because
        # otherwise it could be mistaken as Attrset
        if x == null then
          ""
        else if isCustomType x then
          custom ind x
        else if isBool x then
          bool ind x
        else if isInt x then
          int ind x
        else if isString x then
          str ind x
        else if isList x then
          list ind x
        else if isAttrs x then
          attrs ind x
        else if isFloat x then
          float ind x
        else
          abort "generators.toPlist: should never happen (v = ${v})";

      literal = ind: x: ind + x;

      bool = ind: x: literal ind (if x then "<true/>" else "<false/>");
      int = ind: x: literal ind "<integer>${toString x}</integer>";
      str = ind: x: literal ind "<string>${x}</string>";
      key = ind: x: literal ind "<key>${x}</key>";
      float = ind: x: literal ind "<real>${toString x}</real>";
      custom = ind: x:
        let tag = x.${plistCustomTypeKey};
        in if tag == null then
          literal ind x.value
        else
          literal ind "<${tag}>${toString x.value}</${tag}>";

      indent = ind: expr "	${ind}";

      item = ind: libStr.concatMapStringsSep "\n" (indent ind);

      list = ind: x:
        libStr.concatStringsSep "\n" [
          (literal ind "<array>")
          (item ind x)
          (literal ind "</array>")
        ];

      attrs = ind: x:
        libStr.concatStringsSep "\n" [
          (literal ind "<dict>")
          (attr ind x)
          (literal ind "</dict>")
        ];

      attr = let attrFilter = name: value: name != "_module" && value != null;
      in ind: x:
      libStr.concatStringsSep "\n" (lib.flatten (lib.mapAttrsToList
        (name: value:
          lib.optional (attrFilter name value) [
            (key "	${ind}" name)
            (expr "	${ind}" value)
          ]) x));

    in ''
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      ${expr "" v}
      </plist>'';
}
