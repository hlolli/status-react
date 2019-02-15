{ stdenv, dpkg, fetchurl }:

stdenv.mkDerivation rec {
  name = "nsis-${version}";
  version = "2.50-1";

  src =
    if stdenv.hostPlatform.system == "x86_64-linux" then
      fetchurl {
        url = "http://archive.ubuntu.com/ubuntu/pool/universe/n/nsis/nsis_${version}_amd64.deb";
        sha256 = "1zi3s06jzc2ghk3kb1cnvgkhb0yzqwrlgn3f4zqqzkr4xxdpi3pp";
      }
    else throw "${name} is not supported on ${stdenv.hostPlatform.system}";

  nativeBuildInputs = [ dpkg ];

  unpackPhase = "dpkg-deb -x ${src} ./";

  installPhase = ''
    mkdir $out
    mv usr/* $out/
    rmdir usr
    mv * $out/
  '';

  meta = {
    description = "NSIS is a free scriptable win32 installer/uninstaller system that doesn't suck and isn't huge";
    homepage = https://nsis.sourceforge.io/;
    license = stdenv.lib.licenses.zlib;
    maintainers = [ stdenv.lib.maintainers.pombeirp ];
    platforms = stdenv.lib.platforms.linux;
  };
}
