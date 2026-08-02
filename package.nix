{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  piAgentCoreIntegrity = "sha512-RorGp9OH5l3ElpuC5a5ZQ2eWcchZGXflXRzVGkV99y3y6tT+LLNyxoYIdVKvTKWEObwhExeQbTH0fI2tE4iX4g==";
  piAiIntegrity = "sha512-m3IZD4g3er0V8TC9+Vpgw/sjTKqcJlkcIBy/JvsgRubuuik3tAVzyugUg4rVrShIkkOT69mEd34NEqKUIsl6JQ==";
  piTuiIntegrity = "sha512-IoYrb0rORjELmEpNtoCA/U8je3KopMkRAVJRdSzvXRvgb+Huo1gNh8Q5CSZvNOiYtDxJdj2tYZZHZ4B3+IN3hA==";
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.83.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-cJf+Szh2Ldp+x4AB57kEMMhJ+69xcyW/6BCXROMiVeY=";
  };

  npmDepsHash = "sha256-2RTaFMXGfRLXj097XoggCo7vJlNxQOp+4l44YnXCEMM=";
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
