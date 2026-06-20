{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  piAgentCoreIntegrity = "sha512-8m5fcqRpoGpq3QY0I/tFXROSTmPwBb1dAuzYZO3XYgjsdCokkRMAGRjA9P8s/UD6Jy9yy69lyE4H6sz/5A1TmQ==";
  piAiIntegrity = "sha512-ZpSwaD7oNpsjn9vtEatZQNT9PSdDJXi6rFeY5Qv+OHQGFDKlmcrfJE4ypm4SAc/fBECPs4Rdi3l+YjVtXYrkKw==";
  piTuiIntegrity = "sha512-QerB+0wUc6eEO8MwvzOQGtzcsbwo6y8VvdxYU6vGcakz6ofJZWhrmwrknp1dCGx3bEtCf+siUIxEzkqvFCzIsg==";
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.79.8";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-SU3oOmLfP3o8MZe6AIcIkPO8w1YbvMm50KnGLftOPmI=";
  };

  npmDepsHash = "sha256-JIltmhs5pTkVyJXZfq46Q4un8pEvNbg6SYAfJ0UswYM=";
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
