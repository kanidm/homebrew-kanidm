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

import json
import re
import sys
from hashlib import sha256
from pathlib import Path

import requests

STABLE_TAG = re.compile(r"v[0-9]+\.[0-9]+\.[0-9]+")
VERSION_LINE = re.compile(r'(?m)^([ \t]*version )"(v[0-9]+\.[0-9]+\.[0-9]+)"$')
HASH_LINE = re.compile(r'(?m)^([ \t]*sha256 )"[0-9a-f]{64}"$')

URL = "https://api.github.com/repos/kanidm/kanidm/releases"


def get_latest_release() -> str:
    """pull the latest release from the GitHub API and return the tag name"""
    try:
        response = requests.get(URL, timeout=30)
        response.raise_for_status()
        data = response.json()
        for entry in data:
            tag = entry.get("tag_name")
            if (
                isinstance(tag, str)
                and STABLE_TAG.fullmatch(tag)
                and not entry.get("draft")
                and not entry.get("prerelease")
            ):
                return tag
        raise ValueError("No published stable release with a vX.Y.Z tag found.")
    except requests.RequestException as e:
        print(f"Failed to get latest release from {URL}: {e}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Failed to parse JSON response: {e}", file=sys.stderr)
        sys.exit(1)
    except ValueError as e:
        print(f"Some other weird error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def get_hash(url: str) -> str:
    """get the hash of the file at the given URL"""
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return sha256(response.content).hexdigest()
    except requests.RequestException as e:
        print(f"Failed to get hash from {url}: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:  # noqa: BLE001
        print(f"Some other weird error occurred: {e}", file=sys.stderr)
        sys.exit(1)


def version_tuple(tag: str) -> tuple[int, ...]:
    return tuple(map(int, tag[1:].split(".")))


def update_specfile(specfile: Path, latest_release: str) -> None:
    if not STABLE_TAG.fullmatch(latest_release):
        raise ValueError(f"Unexpected stable release tag: {latest_release!r}")

    content = specfile.read_text()
    versions = list(VERSION_LINE.finditer(content))
    if len(versions) != 1 or len(HASH_LINE.findall(content)) != 1:
        raise ValueError("Expected exactly one version and SHA-256 in kanidm.rb.")
    if version_tuple(latest_release) <= version_tuple(versions[0][2]):
        print(f"No newer release: upstream {latest_release}, tap {versions[0][2]}.")
        return

    file_hash = get_hash(
        f"https://github.com/kanidm/kanidm/archive/refs/tags/{latest_release}.tar.gz"
    )
    print(f"Updating kanidm.rb to {latest_release}")
    new_content = VERSION_LINE.sub(lambda m: f'{m[1]}"{latest_release}"', content)
    new_content = HASH_LINE.sub(lambda m: f'{m[1]}"{file_hash}"', new_content)
    specfile.write_text(new_content)


def main() -> None:
    """Update only the version and checksum of the Kanidm formula."""
    update_specfile(Path("kanidm.rb"), get_latest_release())


if __name__ == "__main__":
    main()
