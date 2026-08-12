#!/usr/bin/env bash
set -euo pipefail

tmp_dir="$(mktemp -d)"
cp -- package.nix "$tmp_dir/package.nix"
cp -- flake.lock "$tmp_dir/flake.lock"

update_succeeded=false
cleanup() {
  status=$?
  set +e

  if [[ "$update_succeeded" != true ]]; then
    cp -- "$tmp_dir/package.nix" package.nix
    cp -- "$tmp_dir/flake.lock" flake.lock
  fi

  rm -rf -- "$tmp_dir"
  exit "$status"
}
trap cleanup EXIT

version="${1:-}"
if [[ -z "$version" ]]; then
  version="$(npm view @earendil-works/pi-coding-agent version)"
fi

tarball="https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${version}.tgz"
prefetch_result="$(nix store prefetch-file --json "$tarball")"
src_hash="$(jq -er '.hash' <<<"$prefetch_result")"
src_path="$(jq -er '.storePath' <<<"$prefetch_result")"

tar -xOf "$src_path" package/npm-shrinkwrap.json \
  | jq -r '
      .packages
      | to_entries[]
      | select(.value.resolved? | type == "string")
      | select(.value.integrity? == null)
      | select(.value.resolved | test("^https?://"))
      | [
          (.key | sub("^.*node_modules/"; "")),
          .value.version,
          .value.resolved
        ]
      | @tsv
    ' \
  | while IFS=$'\t' read -r package dependency_version resolved; do
      integrity="$(npm view "${package}@${dependency_version}" dist.integrity)"
      if [[ -z "$integrity" ]]; then
        echo "No registry integrity found for ${package}@${dependency_version}." >&2
        exit 1
      fi
      jq -n --arg key "$resolved" --arg value "$integrity" '{ key: $key, value: $value }'
    done \
  | jq -S -s 'from_entries' > "$tmp_dir/workspace-integrities.json"

workspace_integrities="$(<"$tmp_dir/workspace-integrities.json")"

PI_VERSION="$version" \
PI_SRC_HASH="$src_hash" \
PI_WORKSPACE_INTEGRITIES="$workspace_integrities" \
perl -0pi -e '
  my $quotes = chr(39) x 2;
  my $integrities = $ENV{PI_WORKSPACE_INTEGRITIES};
  $integrities =~ s/^/    /mg;
  my $integrity_replacement =
    "workspaceIntegrities = builtins.fromJSON $quotes\n$integrities\n  $quotes;\n  workspaceIntegrityReplacements";

  my $integrity_count = s{
    workspaceIntegrities\s*=.*?\n\s*workspaceIntegrityReplacements
  }{$integrity_replacement}sx;
  my $version_count = s/version = "[^"]+";/version = "$ENV{PI_VERSION}";/;
  my $hash_count = s/hash = "sha256-[^"]+";/hash = "$ENV{PI_SRC_HASH}";/;
  my $npm_hash_count = s/npmDepsHash = ("sha256-[^"]+"|lib\.fakeHash);/npmDepsHash = lib.fakeHash;/;

  die "Could not update every expected package.nix field\n"
    unless $integrity_count == 1
      && $version_count == 1
      && $hash_count == 1
      && $npm_hash_count == 1;
' package.nix

nix flake update

set +e
build_output="$(nix build .#pi --no-link 2>&1)"
build_status=$?
set -e

if [[ "$build_status" -eq 0 ]]; then
  echo "Expected the placeholder npmDepsHash to cause a hash mismatch." >&2
  exit 1
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

echo "Updated Pi to ${version}."
echo "src hash: ${src_hash}"
echo "npmDepsHash: ${npm_deps_hash}"

update_succeeded=true
