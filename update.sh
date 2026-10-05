#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$repo_dir"

tmp_dir="$(mktemp -d)"

# Files update.sh is allowed to modify. Back them up so a failure rolls back
# to exactly the state we started in.
managed_files=(package.nix flake.lock package-lock.json)
for file in "${managed_files[@]}"; do
  if [[ -e "$file" ]]; then
    mkdir -p -- "$tmp_dir/backup/$(dirname -- "$file")"
    cp -- "$file" "$tmp_dir/backup/$file"
  fi
done

in_git_repo=false
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  in_git_repo=true
fi

update_succeeded=false
cleanup() {
  status=$?
  set +e

  if [[ "$update_succeeded" != true ]]; then
    for file in "${managed_files[@]}"; do
      if [[ -e "$tmp_dir/backup/$file" ]]; then
        cp -- "$tmp_dir/backup/$file" "$file"
      else
        rm -f -- "$file"
      fi
    done

    # Undo the `git add -N` below so the repository is left as we found it.
    if [[ "$in_git_repo" == true ]]; then
      git reset -q -- package-lock.json 2>/dev/null || true
    fi
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

# Since 1.0.1 the published tarball no longer contains npm-shrinkwrap.json, but
# buildNpmPackage needs a lockfile. Generate one from the shipped package.json.
mkdir -p -- "$tmp_dir/npm"
tar -xOf "$src_path" package/package.json \
  | jq 'del(.devDependencies)' \
  > "$tmp_dir/npm/package.json"

(
  cd -- "$tmp_dir/npm"
  npm install --package-lock-only --ignore-scripts --no-audit --no-fund
)

cp -- "$tmp_dir/npm/package-lock.json" package-lock.json
# Flakes only see files that git knows about; intent-to-add exposes the new
# lockfile to Nix without staging its contents for commit.
if [[ "$in_git_repo" == true ]]; then
  git add -N -- package-lock.json
fi

PI_VERSION="$version" \
PI_SRC_HASH="$src_hash" \
perl -0pi -e '
  my $version_count = s/version = "[^"]+";/version = "$ENV{PI_VERSION}";/;
  my $hash_count = s/hash = "sha256-[^"]+";/hash = "$ENV{PI_SRC_HASH}";/;
  my $npm_hash_count = s/npmDepsHash = ("sha256-[^"]+"|lib\.fakeHash);/npmDepsHash = lib.fakeHash;/;

  die "Could not update every expected package.nix field\n"
    unless $version_count == 1
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
