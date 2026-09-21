{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  workspaceIntegrities = builtins.fromJSON ''
    {
      "https://registry.npmjs.org/@earendil-works/chord/-/chord-0.86.1.tgz": "sha512-GzUr5n4tFBHUYxN9CjcRHK8QWo9tbxNrZu6iWPQ+PFiFrLASvSZOKeAVAgh3gHv/t0X5OvUpFlrMQ/nEFfCYpg==",
      "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-0.86.1.tgz": "sha512-8TbBzhYsDeu5V1Zl2NsyrBqJAzX1EiEL3Np3ZjGpy0pSDdGRVOpcyW1qruLqfWmEqGcnxmvgnTMLS/wJNZO2XQ==",
      "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-0.86.1.tgz": "sha512-1XHhI6D/fyQdsBieHC/E/4zGKVOoGe4yDyX67VXvzoYkFsX/qE7NpZE7E1RC8e6Bz8B9oG/P+MQFXikv2/BGEg==",
      "https://registry.npmjs.org/@earendil-works/pi-telemetry/-/pi-telemetry-0.86.1.tgz": "sha512-SOcEqOS3oVGgKeahs2jHB906d8hFjuLP+RBee8xKYMRgw5KAeWHNg+YABfL0ALlp3Bt6tW4b632MLghc3vnTog==",
      "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-0.86.1.tgz": "sha512-FU/zU/zG4RWokcZt+BVXXcieWi5ggvYnWP2kkB5XXjMaHRoy5BDhcZJ9JAnLTN9MwrCRoXgPQxOI0bFqwYeZkQ=="
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
  version = "0.86.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-jf+T5voD4NSY5yp40se7XwlPXgbuJo5qvQALophKC2o=";
  };

  npmDepsHash = "sha256-hEYJLkwZca+iUwflHamQFTtmAn7ESB79K2nklDuAvKU=";
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
