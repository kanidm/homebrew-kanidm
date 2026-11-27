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

Pull requests build the checked-out Kanidm formula from source on macOS and
run `brew test`. The scheduled updater opens or updates one release PR and
enables squash auto-merge. GitHub waits for the required install and dependency
checks (and any required reviews).

The updater assumes auto-merge and squash merging are enabled, and
**Install Kanidm (Homebrew)** and **dependency-review** are required on `main`.
The `release-automation` environment uses `RELEASE_APP_CLIENT_ID` and
`RELEASE_APP_PRIVATE_KEY` for a GitHub App scoped to this repository with
Contents and Pull requests write access and no branch-rule bypass. The app
token lets PR checks start without GitHub’s manual workflow approval.
