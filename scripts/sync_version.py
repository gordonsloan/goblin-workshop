#!/usr/bin/env python3
"""Sync or check project version metadata from the root VERSION file."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


VERSION_PATH = Path("VERSION")
PROJECT_PATH = Path("project.godot")
PROJECT_INFO_PATH = Path("src/common/project_info.gd")
EXPORT_PRESETS_PATH = Path("export_presets.cfg")
MAIN_MENU_PATH = Path("src/ui/main_menu/main_menu.tscn")

SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")


def _read_version() -> str:
    if not VERSION_PATH.exists():
        raise RuntimeError("Missing VERSION file.")

    version = VERSION_PATH.read_text(encoding="utf-8").strip()
    if not SEMVER_RE.fullmatch(version):
        raise RuntimeError(f"VERSION must use MAJOR.MINOR.PATCH format, got '{version}'.")

    return version


def _replace(path: Path, pattern: str, replacement: str) -> tuple[str, bool]:
    if not path.exists():
        raise RuntimeError(f"Missing {path}.")

    text = path.read_text(encoding="utf-8")
    updated, count = re.subn(pattern, replacement, text, count=1, flags=re.MULTILINE)
    if count != 1:
        raise RuntimeError(f"Could not update version metadata in {path}.")

    return updated, updated != text


def _expected_updates(version: str) -> dict[Path, str]:
    updates: dict[Path, str] = {}

    updates[PROJECT_PATH] = _replace(
        PROJECT_PATH,
        r'^config/version="[^"]*"',
        f'config/version="{version}"',
    )[0]

    updates[PROJECT_INFO_PATH] = _replace(
        PROJECT_INFO_PATH,
        r'^const DEFAULT_PROJECT_VERSION := "[^"]*"',
        f'const DEFAULT_PROJECT_VERSION := "{version}"',
    )[0]

    updates[MAIN_MENU_PATH] = _replace(
        MAIN_MENU_PATH,
        r'^text = "v\d+\.\d+\.\d+"',
        f'text = "v{version}"',
    )[0]

    export_text = EXPORT_PRESETS_PATH.read_text(encoding="utf-8")
    export_text, file_count = re.subn(
        r'^application/file_version="[^"]*"',
        f'application/file_version="{version}"',
        export_text,
        count=1,
        flags=re.MULTILINE,
    )
    export_text, product_count = re.subn(
        r'^application/product_version="[^"]*"',
        f'application/product_version="{version}"',
        export_text,
        count=1,
        flags=re.MULTILINE,
    )
    if file_count != 1 or product_count != 1:
        raise RuntimeError(f"Could not update Windows version metadata in {EXPORT_PRESETS_PATH}.")

    updates[EXPORT_PRESETS_PATH] = export_text
    return updates


def _check(version: str) -> int:
    failures: list[str] = []
    updates = _expected_updates(version)

    for path, expected_text in updates.items():
        current_text = path.read_text(encoding="utf-8")
        if current_text != expected_text:
            failures.append(str(path))

    if failures:
        print(f"Version metadata is out of sync with VERSION ({version}):", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        print("Run: python3 scripts/sync_version.py --write", file=sys.stderr)
        return 1

    print(f"Version metadata is in sync with VERSION ({version}).")
    return 0


def _write(version: str) -> int:
    updates = _expected_updates(version)
    changed: list[str] = []

    for path, updated_text in updates.items():
        current_text = path.read_text(encoding="utf-8")
        if current_text == updated_text:
            continue

        path.write_text(updated_text, encoding="utf-8", newline="\n")
        changed.append(str(path))

    if changed:
        print(f"Synced version metadata to {version}:")
        for path in changed:
            print(f"- {path}")
    else:
        print(f"Version metadata already synced to {version}.")

    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true", help="Fail if generated version metadata is not in sync.")
    mode.add_argument("--write", action="store_true", help="Update generated version metadata.")
    args = parser.parse_args()

    try:
        version = _read_version()
        if args.check:
            return _check(version)
        return _write(version)
    except RuntimeError as error:
        print(f"Version sync failed: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
