#!/usr/bin/env bash
set -euo pipefail

# A named local tap makes Brew use this checkout, not the core or published tap.
tap=local/kanidm-ci
brew tap-new --no-git "$tap"
install -m 0644 kanidm.rb "$(brew --repo "$tap")/Formula/kanidm.rb"
brew install --build-from-source "$tap/kanidm"
brew test "$tap/kanidm"
