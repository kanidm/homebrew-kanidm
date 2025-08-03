#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.11"
# dependencies = ["requests"]
# ///

"""homebrew_check_latest_release.py
This script fetches the latest release tag from the Kanidm GitHub repository
and updates the Homebrew formula accordingly.
"""

import re
import json
import sys
from hashlib import sha256
from pathlib import Path

import requests

URL = "https://api.github.com/repos/kanidm/kanidm/releases"


def get_latest_release() -> str:
    """pull the latest release from the GitHub API and return the tag name"""
    try:
        response = requests.get(URL, timeout=30)
        response.raise_for_status()
        data = response.json()
        for entry in data:
            if entry.get("tag_name"):
                if entry["tag_name"] == "debs":
                    continue
                return str(entry["tag_name"])
        raise ValueError("Invalid tag name or 'debs' found.")
    except requests.RequestException as e:
        print(f"Failed to get latest release from {URL}: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Failed to parse JSON response: {e}", file=sys.stderr)
        sys.exit(1)
    except ValueError as e:
        print(f"Some other weird error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def find_specfile() -> Path:
    """find the first .rb file in the current directory"""

    specfile = next(Path.cwd().glob("*.rb"), None)
    if specfile is None:
        print("No .rb file found in the current directory.", file=sys.stderr)
        sys.exit(1)
    return specfile


def get_hash(url: str) -> str:
    """get the hash of the file at the given URL"""
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return sha256(response.content).hexdigest()
    except requests.RequestException as e:
        print(f"Failed to get hash from {url}: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:  # pylint: disable=broad-except
        print(f"Some other weird error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def update_specfile(specfile: Path, latest_release: str, file_hash: str) -> None:
    """update the specfile with the latest release tag"""
    new_hash = f'sha256 "{file_hash}"'
    version_replacer = re.compile(r"version\s+.*")
    sha256_replacer = re.compile(r"sha256\s+.*")
    try:
        content = specfile.read_text()
        new_content = version_replacer.sub(f'version "{latest_release}"', content)
        new_content = sha256_replacer.sub(new_hash, new_content)
        if content != new_content:
            print(f"Updating specfile content... version is now {latest_release}")
            specfile.write_text(new_content)

    except Exception as e:  # pylint: disable=broad-except
        print(f"Failed to update {specfile}: {e}", file=sys.stderr)
        sys.exit(1)


def main() -> None:
    """Main function to execute the script logic"""
    version = get_latest_release()
    update_specfile(
        find_specfile(),
        version,
        get_hash(
            f"https://github.com/kanidm/kanidm/archive/refs/tags/{version}.tar.gz"
        ),
    )
    sys.exit(0)


if __name__ == "__main__":
    main()
