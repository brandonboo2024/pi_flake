{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  piAgentCoreIntegrity = "sha512-oPwVRkkAvyKPWyM7E4k+EaTNmynbYn7ZLG/LBh9BUnMNb2gvpMp+VQ420R6JCJ20uogSqrHnWTyosSa/rU8lVw==";
  piAiIntegrity = "sha512-CM2pkTs1iupG/maw381lC9Q/Y/aQaMGK7GILc28ttImD0ci3LDwKroDsGkWbly5JIy3iqxdRxB9JlG7vvzCzTg==";
  piTuiIntegrity = "sha512-07GVQo/38a0yvIPlWDr3RJn1B8gk3ZuIX9h2oIQ+Biyu3JN0KppWmgWHfaWRydQgse5JtC++KDw5MWaIRnV0mw==";
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.78.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-72mCHDg9kv0n59mtvcseN2IUQelMUjSOR6KQHqnX3Qw=";
  };

  npmDepsHash = "sha256-QGTbsdFhhrcNH3hi45a2hA8YxK7pr6oQj45s1Rke8Q8=";
  npmDepsFetcherVersion = 2;

  postPatch = ''
    substituteInPlace npm-shrinkwrap.json \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-${version}.tgz"' '"resolved": "https://registry.npmjs.org/@earendil-works/pi-agent-core/-/pi-agent-core-${version}.tgz", "integrity": "${piAgentCoreIntegrity}"' \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz"' '"resolved": "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz", "integrity": "${piAiIntegrity}"' \
      --replace-fail '"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-${version}.tgz"' '"resolved": "https://registry.npmjs.org/@earendil-works/pi-tui/-/pi-tui-${version}.tgz", "integrity": "${piTuiIntegrity}"'
    substituteInPlace package.json \
      --replace-fail '	"devDependencies": {
		"@types/cross-spawn": "6.0.6",
		"@types/diff": "7.0.2",
		"@types/hosted-git-info": "3.0.5",
		"@types/ms": "2.1.0",
		"@types/node": "24.12.4",
		"@types/proper-lockfile": "4.1.4",
		"shx": "0.4.0",
		"typescript": "5.9.3",
		"vitest": "3.2.4"
	},
' ""
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
