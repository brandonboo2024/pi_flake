{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  workspaceIntegrities = builtins.fromJSON ''
    {
      "https://registry.npmjs.org/@earendil-works/chord/-/chord-0.99.1.tgz": "sha512-4xyn0IBzJ+Xu/iOGi2hjXJGAR61QEhEWZsIqTDqr+GmItdquYwBO5jYFnqGiBaTqlY12/EpM7QHoEKSHbyvOug==",
      "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.99.1.tgz": "sha512-zywvWnj5FujeuFI/x/CJHwwxhcLIQgjqseTA+bQgX4O8gJTcgjRd/I8SZnQDqJvxC9QcV12ujiGLviv6EgwcCg==",
      "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.99.1.tgz": "sha512-4nV9JKc94iPX8bwdGPc2nTuVPKIPsffhnp3WoN9NYCNqbtoOF8LhYcIs/+Sn/alroqJK/5QRu6/Z6Ck+n0hyBA==",
      "https://registry.npmjs.org/@earendil-works/pi-codemode/-/pi-codemode-0.99.1.tgz": "sha512-oh8TMsBI3SWTN3xTQtX8u5n+BKhnVXcFagroWumfn6/WWfBnDYL/LmeQtjLb83WRTb9rcu+ZdK8rFa4vggvCJg==",
      "https://registry.npmjs.org/@earendil-works/pi-mcp/-/pi-mcp-0.99.1.tgz": "sha512-YCFGPkmDzLwQuIzwfbP6Vuk/g/ukKpZhwTpbcfzomuI1Fkiu6hHRkOGwAqsO3G8cTkZWkM8vmOkFJjStQNC4qA==",
      "https://registry.npmjs.org/@earendil-works/pi-telemetry/-/pi-telemetry-0.99.1.tgz": "sha512-9PBPjGk+TXRtuMianpqBbHBpYpyKusESF6rwdmgD0WTZSTUQXhcKEO0hAINRLuSwy4V7yPvXV+EVV0ONY7mbpQ==",
      "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.99.1.tgz": "sha512-gZp0Guat96Fr1AuC/xqVz5B2lulZakp/PxD1lXx3lSgBdjiqmwYhJbcQ0HRrGAfy0WtMGn9b05RJr5qJf7oIuw=="
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
  version = "0.99.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-ZoZZKtrqGQkshclPXUAyPb89sUHpDrPt6enocwKr3R0=";
  };

  npmDepsHash = "sha256-e7ANNX/AZizgM7AlPhj9M9nMIoBCjn5mKljENLMRnss=";
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
