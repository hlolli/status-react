{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  name = "appimagetool";
  version = "20190221";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "https://desktop-app-files.ams3.digitaloceanspaces.com/appimagetool-x86_64_${version}.AppImage";
        sha256 = "1z40rirbzzkrikg5k6fpxnwwbch03np5l2jr74wd0q36s44psw91";
        executable = true;
      }
    else throw "${name} is not supported on ${stdenv.hostPlatform.system}";

  unpackCmd = "mkdir .";

  phases = "installPhase";
  installPhase = ''
    mkdir -p $out/bin
    cp ${src} $out/bin/${name}.AppImage
  '';

  meta = {
    description = "Makes Linux applications self-contained by copying in the libraries and plugins that the application uses, and optionally generates an AppImage. Can be used for Qt and other applications";
    homepage = https://github.com/probonopd/linuxdeployqt/;
    license = stdenv.lib.licenses.gpl3;
    maintainers = [ stdenv.lib.maintainers.pombeirp ];
    platforms = stdenv.lib.platforms.linux;
  };
}
