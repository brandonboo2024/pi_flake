{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  piAgentCoreIntegrity = "sha512-jQOtYjRGZ7+XC/olw9euLd2V03vkAPO8u0sSnQoLbyOQZz66dEBZrklTESk34Sf3AaeBSua28wjZR48ch1aXJQ==";
  piAiIntegrity = "sha512-D/2aDoe9vcCbqAztALQcKkdqXGuaQcqAzLm8LfUhNaorwoIHkwnaAuDVlo+OkF5clpEwS8Z1bk2o8NiSrwEdsA==";
  piTuiIntegrity = "sha512-qAQWMruW7YKbk2hPcTD4INtXfvIySXifbPQ+mFY5j3J8yf2tfElkh+gGPuBvgPKPT0z9WiAkd7iySCuQq0txuQ==";
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.79.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-ZUJ5bjTyzbNhfSlsPKTpI1cs9OAHOlm+Rc+aDA+bcmM=";
  };

  npmDepsHash = "sha256-4wSTRus25s0+rA0o1PyZUWtkM9OIbtUFvsWX4PZquBM=";
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
