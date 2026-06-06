#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
if [[ -z "$version" ]]; then
  version="$(npm view @earendil-works/pi-coding-agent version)"
fi

tarball="https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz"
src_hash="$(
  nix store prefetch-file --json "$tarball" \
    | sed -n 's/.*"hash":"\([^"]*\)".*/\1/p'
)"
agent_core_integrity="$(npm view "@earendil-works/pi-agent-core@${version}" dist.integrity)"
ai_integrity="$(npm view "@earendil-works/pi-ai@${version}" dist.integrity)"
tui_integrity="$(npm view "@earendil-works/pi-tui@${version}" dist.integrity)"

PI_VERSION="$version" \
PI_SRC_HASH="$src_hash" \
PI_AGENT_CORE_INTEGRITY="$agent_core_integrity" \
PI_AI_INTEGRITY="$ai_integrity" \
PI_TUI_INTEGRITY="$tui_integrity" \
perl -0pi -e '
  s/version = "[^"]+";/version = "$ENV{PI_VERSION}";/;
  s/hash = "sha256-[^"]+";/hash = "$ENV{PI_SRC_HASH}";/;
  s/piAgentCoreIntegrity = "[^"]+";/piAgentCoreIntegrity = "$ENV{PI_AGENT_CORE_INTEGRITY}";/;
  s/piAiIntegrity = "[^"]+";/piAiIntegrity = "$ENV{PI_AI_INTEGRITY}";/;
  s/piTuiIntegrity = "[^"]+";/piTuiIntegrity = "$ENV{PI_TUI_INTEGRITY}";/;
  s/npmDepsHash = ("sha256-[^"]+"|lib\.fakeHash);/npmDepsHash = lib.fakeHash;/;
' package.nix

set +e
build_output="$(nix build .#pi --no-link 2>&1)"
build_status=$?
set -e

if [[ "$build_status" -eq 0 ]]; then
  nix flake update
  echo "Updated Pi to ${version}; npmDepsHash was already valid."
  exit 0
fi

npm_deps_hash="$(
  printf '%s\n' "$build_output" \
    | sed -n 's/.*got:[[:space:]]*\(sha256-[A-Za-z0-9+/=]*\).*/\1/p' \
    | tail -n 1
)"

if [[ -z "$npm_deps_hash" ]]; then
  printf '%s\n' "$build_output" >&2
  echo "Could not determine npmDepsHash from nix build output." >&2
  exit "$build_status"
fi

PI_NPM_DEPS_HASH="$npm_deps_hash" \
perl -0pi -e 's/npmDepsHash = lib\.fakeHash;/npmDepsHash = "$ENV{PI_NPM_DEPS_HASH}";/' package.nix
nix build .#pi --no-link
nix flake update

echo "Updated Pi to ${version}."
echo "src hash: ${src_hash}"
echo "npmDepsHash: ${npm_deps_hash}"
