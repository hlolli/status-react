{ stdenv, pkgs, target-os, nodejs }:

with pkgs;
with stdenv;

let
  targetLinux = {
    "linux" = true;
    "" = isLinux;
  }.${target-os} or false;
  targetWindows = {
    "windows" = true;
    "" = isLinux;
  }.${target-os} or false;
  windowsPlatform = callPackage ./windows { };
  appimagekit = callPackage ./appimagekit { };
  linuxdeployqt = callPackage ./linuxdeployqt { inherit appimagekit; };
  nodePkgs = import ../global-node-packages {
    inherit pkgs;
    inherit nodejs;
  };
in
  {
    buildInputs = [
      cmake
      extra-cmake-modules
      file
      gnupg # Used by appimagetool
      go
      ncurses
      python27
      yarn
      nodePkgs."realm-git+https://github.com/status-im/realm-js.git#heads/v2.20.1"
      hostname # Used by run-app.sh
    ] ++ lib.optional targetLinux [ appimagekit linuxdeployqt patchelf ]
      ++ lib.optional (! targetWindows) qt5.full
      ++ lib.optional targetWindows windowsPlatform.buildInputs;
    shellHook = (if target-os == "windows" then "unset QT_PATH" else ''
      export QT_PATH="${qt5.full}"
      export PATH="${stdenv.lib.makeBinPath [ qt5.full ]}:$PATH"
    '') + (lib.optionalString isDarwin ''
      export MACOSX_DEPLOYMENT_TARGET=10.9
    '');
  }
