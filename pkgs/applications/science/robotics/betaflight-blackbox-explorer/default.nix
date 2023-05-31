{lib, stdenv, fetchurl, unzip, makeDesktopItem, nwjs, wrapGAppsHook, gsettings-desktop-schemas, gtk3 }:

let
  pname = "betaflight-blackbox-explorer";
  desktopItem = makeDesktopItem {
    name = pname;
    exec = pname;
    icon = pname;
    comment = "Betaflight Blackbox Log Viewer";
    desktopName = "Blackbox Log Viewer";
    genericName = "Betaflight Blackbox Explorer";
  };
in
stdenv.mkDerivation rec {
  inherit pname;
  version = "3.5.0";
  src = fetchurl {
    url = "https://github.com/betaflight/blackbox-log-viewer/releases/download/${version}/${pname}_${version}_linux64.zip";
    sha256 = "sha256-OTYbcuJUgk478nDfnssEUUgOSeViXrmZYt87VCzyXF4=";
  };

  postUnpack = ''
    find -name "lib*.so" -delete
  '';

  nativeBuildInputs = [ wrapGAppsHook unzip ];

  buildInputs = [ gsettings-desktop-schemas gtk3 ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin \
             $out/opt/${pname}

    cp -r . $out/opt/${pname}/
    install -m 444 -D icon/bf_icon_128.png $out/share/icons/hicolor/128x128/apps/${pname}.png
    cp -r ${desktopItem}/share/applications $out/share/

    makeWrapper ${nwjs}/bin/nw $out/bin/${pname} --add-flags $out/opt/${pname}
    runHook postInstall
  '';

  meta = with lib; {
    description = "The Betaflight blackbox log explorer tool.";
    longDescription = ''
      A crossplatform blackbox explorer tool for the Betaflight flight control system.
    '';
    homepage    = "https://github.com/betaflight/betaflight/wiki";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license     = licenses.gpl3Only;
    maintainers = with maintainers; [ andresnav ];
    platforms   = platforms.linux;
  };
}
