#!/usr/bin/env python3
"""Check that Godot export presets exclude repository-only files."""

from __future__ import annotations

import re
import sys
from pathlib import Path


EXPORT_PRESETS_PATH = Path("export_presets.cfg")

REQUIRED_EXCLUSIONS = {
    "docs/**",
    "res://docs/**",
    "*.md",
    "res://*.md",
    "VERSION",
    "res://VERSION",
    ".github/**",
    "res://.github/**",
    ".gitignore",
    "res://.gitignore",
    ".gitattributes",
    "res://.gitattributes",
}


def _parse_presets(config_text: str) -> dict[str, dict[str, str]]:
    presets: dict[str, dict[str, str]] = {}
    current_preset: str | None = None

    for raw_line in config_text.splitlines():
        line = raw_line.strip()
        preset_match = re.fullmatch(r"\[preset\.(\d+)\]", line)
        if preset_match:
            current_preset = preset_match.group(1)
            presets[current_preset] = {}
            continue

        if line.startswith("["):
            current_preset = None
            continue

        if current_preset is None or "=" not in line:
            continue

        key, value = line.split("=", 1)
        presets[current_preset][key.strip()] = value.strip().strip('"')

    return presets


def _split_filter(filter_value: str) -> set[str]:
    return {item.strip() for item in filter_value.split(",") if item.strip()}


def main() -> int:
    if not EXPORT_PRESETS_PATH.exists():
        print(f"Missing {EXPORT_PRESETS_PATH}.", file=sys.stderr)
        return 1

    presets = _parse_presets(EXPORT_PRESETS_PATH.read_text(encoding="utf-8"))
    if not presets:
        print("No export presets found.", file=sys.stderr)
        return 1

    failures: list[str] = []
    for preset_index, preset in presets.items():
        preset_name = preset.get("name", f"preset.{preset_index}")
        exclusions = _split_filter(preset.get("exclude_filter", ""))
        missing = sorted(REQUIRED_EXCLUSIONS - exclusions)

        if missing:
            failures.append(f"{preset_name}: missing {', '.join(missing)}")

    if failures:
        print("Export privacy audit failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print(f"Export privacy audit passed for {len(presets)} preset(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
