{ pkg }:
let
  inherit (import <nixpkgs> {}) stdenv lib python3 coreutils strace;

  agent = stdenv.mkDerivation {
    name = "autobake-agent";

    src = ./.;

    buildInputs = [ python3 ];

    preferLocalBuild = true;

    installPhase = ''
      mkdir -p $out/bin
      export postbuild=$out/libexec/autobake-agent/postbuild
      install -D postbuild $postbuild
      substitute agent.in $out/bin/autobake-agent \
        --subst-var postbuild \
        --subst-var-by mktemp ${coreutils}/bin/mktemp \
        --subst-var-by rm ${coreutils}/bin/rm \
        --subst-var-by strace ${strace}/bin/strace
      chmod 755 $out/bin/autobake-agent
    '';
  };

in lib.overrideDerivation pkg (oldAttrs: {
  builder = "${agent}/bin/autobake-agent";
  args = [ oldAttrs.builder ] ++ oldAttrs.args;
})
