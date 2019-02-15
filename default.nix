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
      clojure
      curl
      jq
      leiningen
      maven
      openjdk
      statusDesktop.buildInputs
      watchman
      unzip
      wget
    ] ++ nodePkgs
      ++ lib.optional isDarwin cocoapods
      ++ lib.optional isLinux gcc7;
    shellHook = ''
        ${statusDesktop.shellHook}

        local toolversion="$(git rev-parse --show-toplevel)/scripts/toolversion"

        export JAVA_HOME="${openjdk}"
        export ANDROID_HOME=~/.status/Android/Sdk
        export ANDROID_SDK_ROOT="$ANDROID_HOME"
        export ANDROID_NDK_ROOT="$ANDROID_SDK_ROOT/android-ndk-$($toolversion android-ndk)"
        export ANDROID_NDK_HOME="$ANDROID_NDK_ROOT"
        export ANDROID_NDK="$ANDROID_NDK_ROOT"
        export PATH="$ANDROID_HOME/bin:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools:$PATH"

        [ -d "$ANDROID_NDK_ROOT" ] || ./scripts/setup # we assume that if the Android NDK dir does not exist, make setup needs to be run
    '';
  }