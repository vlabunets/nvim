#!/usr/bin/env bash
# Find the branch the current branch originated from (used by the avante #review_PR shortcut).
# Usage: pr-base.sh [base-branch]   (an explicit branch skips detection)
# Prints BASE_BRANCH, BASE_SHA (merge-base with HEAD) and SOURCE, exit 0.
# When the parent can't be determined reliably, prints the closest candidates and exits 2.
set -u

cur=$(git branch --show-current)
base="${1:-}"
source="argument"

# 1. Open pull request for this branch: its base is exactly the PR scope
if [ -z "$base" ] && command -v gh >/dev/null 2>&1; then
	base=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null)
	source="gh pr view"
fi

# 2. Reflog of the branch: "branch: Created from <ref>" (useless when created from HEAD)
if [ -z "$base" ] && [ -n "$cur" ]; then
	base=$(git reflog show --format=%gs "refs/heads/$cur" 2>/dev/null | sed -n 's/^branch: Created from //p' | tail -1)
	[ "$base" = "HEAD" ] && base=""
	source="reflog"
fi

if [ -n "$base" ]; then
	# prefer the remote-tracking ref (what a PR compares against), fall back to the local branch
	base=${base#refs/heads/}
	base=${base#refs/remotes/}
	ref=$base
	git rev-parse --verify -q "origin/${base#origin/}" >/dev/null && ref="origin/${base#origin/}"
	if sha=$(git merge-base HEAD "$ref" 2>/dev/null); then
		printf 'BASE_BRANCH=%s\nBASE_SHA=%s\nSOURCE=%s\n' "$ref" "$sha" "$source"
		exit 0
	fi
	echo "Base '$base' from $source is not a known ref" >&2
fi

# 3. Unknown: list branches whose merge-base lies on this branch's first-parent history, closest first
echo "UNKNOWN: no open PR and no reflog origin for '$cur'. Closest candidates (first-parent commits ahead, branch):"
head=$(git rev-parse HEAD)
fp=$(mktemp)
git rev-list --first-parent HEAD >"$fp"
git for-each-ref --format='%(refname:short)' refs/heads refs/remotes/origin |
	grep -v -x -e "$cur" -e "origin/$cur" -e origin/HEAD -e origin |
	while read -r ref; do
		mb=$(git merge-base HEAD "$ref" 2>/dev/null) || continue
		[ "$mb" = "$head" ] && continue
		grep -q -x "$mb" "$fp" || continue
		echo "$(git rev-list --first-parent --count "$mb"..HEAD) $ref"
	done | sort -n | head -5
rm -f "$fp"
exit 2
