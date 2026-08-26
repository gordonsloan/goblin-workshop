# AGENTS.md

## Repository Purpose

This is a reusable Godot starter project for small-scale game development. It is intended to be copied or used as a template for new Godot projects.

## Engine and Language

- Engine: Godot 4.x
- Primary language: GDScript
- Prefer Godot-native patterns over external dependencies.
- Do not add plugins, packages, or large dependencies without asking first.

## Repository Layout

- `src/assets/` contains game assets.
- `src/autoloads/` contains singleton scripts registered in Project Settings.
- `src/data/` contains static data, custom resources, JSON, config, and lookup tables.
- `src/scenes/` contains gameplay scenes, actors, objects, levels, and systems.
- `src/shaders/` contains shader files.
- `src/ui/` contains UI scenes and scripts.
- `docs/` contains project documentation.
- `exports/` and `builds/` are local output folders and should not be used for source files.

## Godot Conventions

- Keep `.gd` scripts beside the `.tscn` scene they primarily support.
- Use `snake_case` for file and folder names.
- Use `PascalCase` for node names.
- Prefer typed GDScript where practical.
- Prefer exported variables for designer-tunable values.
- Avoid hard-coded node paths where an exported `NodePath` or `%UniqueNodeName` would be clearer.
- Keep scenes modular and reusable.
- Avoid putting game-specific logic into the starter template unless it is broadly reusable.

## Change Rules

- Preserve existing scene/script relationships.
- Do not move files unless necessary.
- Do not rename nodes, files, inputs, or autoloads without checking references.
- When changing a `.tscn`, consider whether attached scripts or exported paths also need updates.
- Do not edit generated/cache folders such as `.godot/`.

## Testing and Verification

When making code changes:
- Check affected scripts for parse errors.
- Explain how to manually test the change in Godot.
- If a command-line Godot executable is available, prefer running a headless parse/check command.
- Summarize changed files and any risks.

Local Godot validation note:
- The local Godot 4.6 install has been configured for self-contained editor data using an `_sc_` marker beside the Godot executable.
- Its editor data lives outside this repository at `C:\Workspace\GameDev\Godot\Engines\Godot_v4.6-stable_win64.exe\editor_data\`.
- In Codex, sandboxed `godot --headless --path . --quit` project checks may still crash because Godot's project-load path needs write access outside the repo sandbox.
- If that happens, rerun the same Godot validation command with escalation rather than treating it as a project failure.
- This is local environment context only; do not commit Godot editor data or treat it as a template requirement.

## Output Style

When reporting back:
- Be specific about which files changed.
- Mention any assumptions.
- Include manual test steps.
- Call out follow-up improvements separately from required fixes.

## Codex workflow

Before making changes:
- Run `git status`
- Read README.md, CHANGELOG.md, VERSION, and project.godot
- Do not modify release/version files unless asked

After changing GDScript or scenes:
- Run a Godot headless project check if available
- Run `git diff`
- Summarise changed files and any verification failures

Do not run:
- git reset --hard
- git clean -fd
- git push
- release/publish commands without explicit approval.
