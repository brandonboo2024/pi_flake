{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  piAgentCoreIntegrity = "sha512-BF9WPhixIFjT6Kp3Iz3H6ugkU+4AWotM8py96XE5pIK0arJbQKMWbR+dXSWWDEmR5yc/aFQODnuyowOEzMGO7Q==";
  piAiIntegrity = "sha512-5GNKfdrRJ4uZ5Zd9iudoXggi/BbUcKnD/xfRHtdR+7q4vWqPvfx8auFuaT+ewGBVI8K4wj87eigFQ/iCSuy9RQ==";
  piTuiIntegrity = "sha512-OvOAMIbXiC9OSse17YMiXIsI9AS5XM/ZV8N/k+UzdlRpPILDQYmLElevgGW92kkXR8qHBClIdzhCjuzlBGvphA==";
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.80.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-nKsYZhU0XzzCqx0199bxOTBqMSKgMKRffCRUifc0kIU=";
  };

  npmDepsHash = "sha256-F0mLfNjTuuBq0lCqC3pixhjyAjcTYGPn6JTGdc1BaxA=";
  npmDepsFetcherVersion = 2;

  postPatch = ''
    substituteInPlace npm-shrinkwrap.json \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-${version}.tgz"' '"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-${version}.tgz", "integrity": "${piAgentCoreIntegrity}"' \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz"' '"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz", "integrity": "${piAiIntegrity}"' \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-${version}.tgz"' '"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-${version}.tgz", "integrity": "${piTuiIntegrity}"'
    # Remove devDependencies block from package.json (avoids dependency on specific versions)
    sed -i '/"devDependencies": {/,/^[[:space:]]*},/d' package.json
  '';

  dontNpmBuild = true;

  meta = {
    description = "Coding agent CLI with read, bash, edit, write tools and session management";
    homepage = "https://github.com/earendil-works/pi/tree/main/packages/coding-agent";
    changelog = "https://github.com/earendil-works/pi/blob/main/packages/coding-agent/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "pi";
    platforms = lib.platforms.unix;
  };
}
