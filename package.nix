{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  workspaceIntegrities = builtins.fromJSON ''
    {
      "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.84.1.tgz": "sha512-evyzXYWCLQGmcaBYHlmSku02r8qoN4SGI60GZABo6iV+H+nqX+P9ud8fEZ4GmRq9mUSREvvfX+w9dA9ThF9C6w==",
      "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.84.1.tgz": "sha512-wMsAdJMxuNri08vLqTyYVI201DQQezGhPSTkzYsHdw5dYX3rCNwEmSvpaAwhi7ELKI/2tE/CEgSWg/6iRxSgdQ==",
      "https://registry.npmjs.org/@earendil-works/pi-client/-/pi-client-0.84.1.tgz": "sha512-/V5hGHE4Zq+jG0GtwIB9PyBUOGd6gBLZ7lkQYFKchKnxYHeH3rmWC5xw4kpnZKKBuBuFTdLVbU9vEjlAGMMb2A==",
      "https://registry.npmjs.org/@earendil-works/pi-protocol/-/pi-protocol-0.84.1.tgz": "sha512-Ox1pciyeSPGEEUcxvR0/dJcrY7C6hrEGA8y71rOsvSIUlXN1Cbp/be/eoL71OGDBk5O97TeQPfWN6Ju/2Ehjww==",
      "https://registry.npmjs.org/@earendil-works/pi-telemetry/-/pi-telemetry-0.84.1.tgz": "sha512-180/xGJtsq7IoR3p9EKWjRd0e9M4DkxInhlo9xyD7prDC7Qrhqq+nhvwrW0lFjPfXcEI2FSHmGCSyvSJE9GsaQ==",
      "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.84.1.tgz": "sha512-udeXFbgEhJ6JiB0uguwNVNkDy2FENfmtQwPcY+/iJ8GWeq18wkal1tKqa5YyeH0IqtX1vG0cGh8zfSYzyzVuLA=="
    }
  '';
  workspaceIntegrityReplacements = lib.concatStringsSep " \\\n      " (
    lib.mapAttrsToList (
      resolved: integrity:
      ''--replace-fail '"resolved": "${resolved}"' "\"resolved\": \"${resolved}\", \"integrity\": \"${integrity}\""''
    ) workspaceIntegrities
  );
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.84.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-ppoYWWAX6RlV/Q/Wd75p+rW26gHVsGIHvO407hUivCA=";
  };

  npmDepsHash = "sha256-wQLXYRCK7uJH6Js6MvCfagOnTenrP1n97gCpF/H+eIg=";
  npmDepsFetcherVersion = 2;

  postPatch = ''
    substituteInPlace npm-shrinkwrap.json \
      ${workspaceIntegrityReplacements}
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
