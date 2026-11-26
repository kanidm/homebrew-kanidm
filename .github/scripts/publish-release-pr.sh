#!/usr/bin/env bash
set -euo pipefail

: "${GITHUB_REPOSITORY:?}" "${DEFAULT_BRANCH:?}" "${GH_TOKEN:?}"
[[ "$(git diff --name-only HEAD)" == kanidm.rb ]]
version=$(sed -nE 's/^[[:blank:]]*version "(v[0-9]+\.[0-9]+\.[0-9]+)"$/\1/p' kanidm.rb)
[[ "$version" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
branch="brew-update/$version"
ref="refs/heads/$branch"

git config user.name 'Kanidm release automation'
git config user.email 'kanidm-release-automation@users.noreply.github.com'
git add -- kanidm.rb
git commit -m "Update Kanidm to $version"
gh auth setup-git

# Reuse this exact release PR on retries, but never replace an existing branch.
remote=$(git ls-remote --heads origin "$ref")
if [[ -n "$remote" ]]; then
  git fetch --no-tags origin "$ref"
  if [[ "$(git rev-parse FETCH_HEAD^)" != "$(git rev-parse HEAD^)" ]] \
    || ! git diff --quiet FETCH_HEAD HEAD; then
    echo "Refusing to reuse $ref: its base or tree differs from the generated release." >&2
    exit 1
  fi
  head=$(git rev-parse FETCH_HEAD)
else
  git push origin "HEAD:$ref"
  head=$(git rev-parse HEAD)
fi

pr=$(gh pr list --repo "$GITHUB_REPOSITORY" --state all \
  --base "$DEFAULT_BRANCH" --head "$branch" \
  --json url,isCrossRepository,headRefOid,state \
  --jq '[.[] | select(.isCrossRepository == false)] | first // empty')
if [[ -z "$pr" ]]; then
  url=$(gh pr create --repo "$GITHUB_REPOSITORY" --base "$DEFAULT_BRANCH" \
    --head "$branch" --title "Update Kanidm to $version" \
    --body "Update the Kanidm CLI formula to the upstream $version release.")
  pr=$(gh pr view "$url" --json url,isCrossRepository,headRefOid,state)
fi
if ! jq -e --arg head "$head" \
  '.state == "OPEN" and .headRefOid == $head and .isCrossRepository == false' \
  <<<"$pr" >/dev/null; then
  echo "Not enabling auto-merge: PR is closed or its source does not match." >&2
  exit 1
fi
url=$(jq -er '.url' <<<"$pr")

# Repository rules, not this job's success, must hold the PR until CI passes.
# gh pr merge --auto can merge immediately if requirements are already satisfied.
base=$(jq -nr --arg branch "$DEFAULT_BRANCH" '$branch | @uri')
rules=$(gh api "repos/$GITHUB_REPOSITORY/rules/branches/$base")
if ! jq -e '
  [.[] | select(.type == "required_status_checks")
       | .parameters.required_status_checks[].context]
  | index("Install Kanidm (Homebrew)") != null and index("dependency-review") != null
' <<<"$rules" >/dev/null; then
  echo "PR opened, but auto-merge withheld: main must require both CI checks via an active ruleset." >&2
  exit 1
fi

already_enabled=$(gh pr view "$url" --json autoMergeRequest --jq '.autoMergeRequest != null')
if [[ "$already_enabled" == false ]]; then
  gh pr merge "$url" --repo "$GITHUB_REPOSITORY" --auto --squash --match-head-commit "$head"
fi
