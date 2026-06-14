{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

let
  piAgentCoreIntegrity = "sha512-Ksvnu6CpQLYGbCSgnQEetzliI7yb+QkqtSlmmunJ69QluT45kd3DjQZRNHfRLk++Dd02Y8QvsRKMopSJCcWoWw==";
  piAiIntegrity = "sha512-lMSput/haP5uZAGbXhS5rAYd3GB7GYdJkoAUxg3VFummBeqGqGqllaTWrbHFN12kVGyVfWHhdySNXkiqVh65Iw==";
  piTuiIntegrity = "sha512-cpmkEM1aEuGUx6YZM36VlzpulwLzqD5T2cUEkGHndDTNGEbnn5sj/9SYm+QBfKjvZsWoHfZuFBnu4+hh96/FbA==";
in
(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "0.79.3";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-+yjLrpqRvHo+dnKVBCdl/X4mIYPK50LwHAx0sgyN4yg=";
  };

  npmDepsHash = "sha256-8hnRJ0MU4N2Qev97HiaE6sH9Dzfj3DWUdfu3U+oDtpw=";
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
