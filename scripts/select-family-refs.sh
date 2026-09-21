#!/usr/bin/env bash
set -euo pipefail
# Resolve only branch names supplied by GitHub, never execute their contents here.
branch="${GITHUB_HEAD_REF:-}"
[[ -n "$branch" ]] || exit 0
git check-ref-format "refs/heads/$branch"
for directory in packages/dataraft.*; do
  [[ -d "$directory/.git" ]] || continue
  if git -C "$directory" ls-remote --exit-code --heads origin "refs/heads/$branch" > /dev/null; then
    git -C "$directory" fetch --depth=1 origin "refs/heads/$branch"
    git -C "$directory" checkout --detach FETCH_HEAD
  fi
done
