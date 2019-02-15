{ stdenv, pkgs }:

with pkgs;
with stdenv; 

let
  conan = callPackage ./conan { };
  appimagetool = callPackage ./appimagetool { };
  linuxdeployqt = callPackage ./linuxdeployqt { };
  nsis = callPackage ./nsis { };

in
  {
    buildInputs = [
      cmake
      extra-cmake-modules
      go
      qt5.full
    ] ++ lib.optional isLinux [ appimagetool conan linuxdeployqt nsis patchelf ];
    shellHook = ''
      export QT_PATH="${qt5.full}"
    '';
  }
