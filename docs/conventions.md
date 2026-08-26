# Project Conventions

## File Organization

Scripts usually live beside their related scenes.

Example:

src/scenes/player/
  player.tscn
  player.gd
  player_camera.gd

## Scene Organization

Prefer small reusable scenes over large monolithic scenes.

Common folders:
- `actors/`
- `objects/`
- `levels/`
- `systems/`

## GDScript Style

- Use typed variables where practical.
- Use signals for decoupling.
- Use groups sparingly and document expected group names.
- Prefer exported values for tuning.
- Prefer direct autoload calls over `get_node("/root/...").call(...)` when the singleton is a required project dependency.

## Runtime Project Metadata

Use exported project settings for metadata shown in-game. Root repository files such as `VERSION` are release-tooling inputs and may be excluded from exported builds.

Use `ProjectInfo` for project name, visible app version, and creator credits instead of reading root files at runtime.

## Exports vs Code

Use exported values for designer-tunable or swappable data, such as scene paths, audio streams, transition timing, colors, behavior flags, and optional `NodePath` references.

Keep control flow in code when it depends on state, platform checks, persistence, scene transitions, pause rules, or other runtime decisions. Scene-specific button intent should usually remain in that scene script unless several screens repeat the same action pattern.
