let
  pkgs = import ((import <nixpkgs> { }).fetchFromGitHub {
    owner = "status-im";
    repo = "nixpkgs";
    rev = "06e0997892cae4ffafed8e79cfdf422c10773391";
    sha256 = "1j9hsh9zxqib9r1s8j5rmy8s2aqj9cpw05lspagcgcznlaiy9rxw";
  }) { config = { }; };

in with pkgs;
  let
    derivation = if stdenv.isLinux then stdenvNoCC.mkDerivation else stdenv.mkDerivation;
    nodejs = nodejs-10_x;
    statusDesktop = callPackage ./scripts/lib/setup/nix/desktop { };
    statusMobile = callPackage ./scripts/lib/setup/nix/mobile { };
    nodeInputs = import ./scripts/lib/setup/nix/global-node-packages/output {
      # The remaining dependencies come from Nixpkgs
      inherit pkgs;
      inherit nodejs;
    };
    nodePkgs = [
      nodejs
      python27 # for e.g. gyp
      yarn
    ] ++ (map (x: nodeInputs."${x}") (builtins.attrNames nodeInputs));

  in derivation rec {
    name = "env";
    env = buildEnv { name = name; paths = buildInputs; };
    buildInputs = with stdenv; [
      bash
      clojure
      curl
      git
      jq
      leiningen
      maven
      openjdk
      statusDesktop.buildInputs
      statusMobile.buildInputs
      watchman
      unzip
      wget
    ] ++ nodePkgs
      ++ lib.optional isDarwin cocoapods
      ++ lib.optional isLinux gcc7;
    shellHook = ''
        ${statusDesktop.shellHook}
        ${statusMobile.shellHook}

        [ -d "$ANDROID_SDK_ROOT" ] || ./scripts/setup # we assume that if the Android SDK dir does not exist, make setup needs to be run
    '';
  }
