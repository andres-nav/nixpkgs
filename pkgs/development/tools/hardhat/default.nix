# {
#   lib,
#   stdenv,
#   pkgs,
#   fetchFromGitHub,
#   mkYarnPackage,
#   mkYarnModules,
# }: let
#   pname = "hardhat";
#   version = "2.15.0";
#   src = fetchFromGitHub {
#     owner = "NomicFoundation";
#     repo = pname;
#     rev = "${pname}@${version}";
#     hash = "sha256-e1nJO1agiuLGN4Crh3CKUF0iztlapg0HmM1xYQpG3k8=";
#   };
#   deps = mkYarnModules {
#     inherit pname version;
#     packageJSON = "${src}/package.json";
#     yarnLock = "${src}/yarn.lock";
#   };
#   package = mkYarnPackage {
#     inherit pname version src;
#   };
# in
#   stdenv.mkDerivation {
#     inherit pname version;
#     # Grab the dependencies from the above mkYarnModules derivation
#     configurePhase = ''
#       mkdir -p $out/bin
#       ln -s ${deps}/node_modules $out
#     '';
#     # Write a script to the output folder that invokes the entrypoint of the application
#     installPhase = ''
#       cat <<EOF > $out/bin/hardhat
#       #!${pkgs.nodejs}/bin/node
#       require('$out/node_modules/hardhat/oscal-deep-diff/lib/cli/cli.js');
#       EOF
#       chmod a+x $out/bin/hardhat
#     '';
#     # Skip the unpack step (mkDerivation will complain otherwise)
#     dontUnpack = true;
#     meta = with lib; {
#       description = "Ethereum development environment for professionals";
#       homepage = "https://hardhat.org";
#       license = licenses.mit;
#       maintainers = with maintainers; [andresnav];
#     };
#   }
{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  mkYarnPackage,
  nodejs,
  makeWrapper,
}:
mkYarnPackage rec {
  pname = "hardhat";
  version = "2.15.0";

  src = fetchFromGitHub {
    owner = "NomicFoundation";
    repo = pname;
    rev = "${pname}@${version}";
    hash = "sha256-e1nJO1agiuLGN4Crh3CKUF0iztlapg0HmM1xYQpG3k8=";
  };

  packageJson = "${src}/package.json";
  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    sha256 = "sha256-GoBBoIhuOn14m+kEV8mynldRVsZ3n0ymaWkYBSBae/M=";
  };

  nativeBuildInputs = [makeWrapper];
  configurePhase = ''
    cp -r "$node_modules" node_modules
    chmod -R u+w node_modules
  '';

  buildPhase = ''
    runHook preBuild

    # compile TypeScript sources
    yarn --offline --save-dev build

    runHook postBuild
  '';

  doCheck = true;

  postInstall = ''
    # server wrapper
    makeWrapper '${nodejs}/bin/node' "$out/bin/${pname}" \
      --add-flags "$OUT_JS_DIR/src/discordas.js"
  '';

  # don't generate the dist tarball
  doDist = false;

  meta = with lib; {
    description = "Ethereum development environment for professionals";
    homepage = "https://hardhat.org";
    license = licenses.mit;
    maintainers = with maintainers; [andresnav];
  };
}
