{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  piAgentCoreIntegrity = "sha512-Z3kloziJIE2dmrisRckZX8zDca/gIv9/YdFAzeoqpHiLV2wsni6bL4hInNSjVKLbqT+4kqLIkph2JQLKvSepjg==";
  piAiIntegrity = "sha512-3WFYRhEp3lQB3444EhPMBcM7zSaEUE3eJgHOR7s4081NLqbw/FsWilIKWXSua0Gv3sRr7m9xMidR3pPDE7jI/A==";
  piTuiIntegrity = "sha512-9yN8hALfKaxZq7n54EMxqhFCWnMi6LHkraMJ/1YjHiATq75XrI6XDMVppn9EDtiK7Fks8hUe1SDXUTrIvwRWfQ==";
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.82.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-g0OrlcurV2by9dSIRN+NsT53Lq0uKXYWbLuCCinay30=";
  };

  npmDepsHash = "sha256-cRV1W5N2gUETt355jzdA+TEqcQsT5rg9lSAxx75cEGM=";
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
