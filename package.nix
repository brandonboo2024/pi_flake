{
  lib,
  buildNpmPackage,
  fetchurl,
  nodejs_22,
}:

(buildNpmPackage.override { nodejs = nodejs_22; }) rec {
  pname = "pi-coding-agent";
  version = "1.0.3";

  src = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz";
    hash = "sha256-EG6tsfgj9y8BLAjyO9NuQ1+eYvbIHpil2PcMipVD3QU=";
  };

  # As of 1.0.1 the published npm tarball no longer ships a lockfile
  # (npm-shrinkwrap.json). Use the package-lock.json that update.sh generates
  # from the tarball's package.json and vendors in this repo, so the dependency
  # install stays fully reproducible.
  postPatch = ''
    rm -f npm-shrinkwrap.json
    install -m 0644 ${./package-lock.json} package-lock.json

    # Drop devDependencies so npm ci only installs runtime dependencies.
    sed -i '/"devDependencies": {/,/^[[:space:]]*},/d' package.json
  '';

  npmDepsHash = "sha256-s8mPPnGvdo0Irf2Q6/9awV1lw7FtZBJ7JiY7Ku9ALy8=";
  npmDepsFetcherVersion = 2;

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
