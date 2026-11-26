# homebrew-kanidm

Kanidm Casks for installation - please see https://github.com/kanidm/kanidm for the project.

## Installation: 

Tap the repository:

```
brew tap kanidm/kanidm
```

Install the package of your choice:

```
brew install kanidm
```

## Automated release updates

Every pull request runs **Install Kanidm (Homebrew)** on a macOS runner. It
builds the checked-out tap formula from source and runs its `brew test` smoke
test, which invokes `kanidm --version`. It does not use the already published
formula or a bottle. Pull requests also run **dependency-review**.

The scheduled **Check and update brew definitions** workflow (also runnable
manually from `main`) opens a version-specific PR when a newer stable release is
available. Auto-merge applies to those PRs only. A failed check leaves the PR
unmerged. The workflow will not enable auto-merge unless both checks are
required by active rules on the default branch.

One-time setup by a maintainer:

1. Install a dedicated GitHub App on **this repository only**, with
   **Contents: Read and write** and **Pull requests: Read and write**. Do not
   give it a bypass for branch rules. GitHub holds checks on PRs opened with
   the default Actions token for manual approval.
2. Create an Actions environment named `release-automation` restricted to
   the default branch. Set environment variable `RELEASE_APP_CLIENT_ID` and
   environment secret `RELEASE_APP_PRIVATE_KEY`. Do not require approvals on
   the environment if the scheduled updater is meant to be unattended.
3. Leave **Allow auto-merge** and **Allow squash merging** enabled. After the
   workflow has run on a PR so the checks are selectable, use an active branch
   ruleset on the default branch requiring **Install Kanidm (Homebrew)** and
   **dependency-review** from GitHub Actions. Keep any intentionally required
   human reviews; GitHub will still wait for them.
4. Run the updater from `main` when the tap is behind a stable upstream
   release. Check that the release PR's workflows start without a click and
   that it waits for both checks. If a version-specific branch exists with a
   different base or tree, the updater stops rather than rewriting it.
