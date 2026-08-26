# Architecture

## Current Overview

This project currently has no game-specific architecture.

Future projects should document:
- Main scenes
- Autoloads
- Core gameplay systems
- Input flow
- Save/load flow
- UI flow
- Build/export process

## Autoloads

List autoloads here when added.

| Name | Path | Purpose |
|---|---|---|
| SceneNavigator | `res://src/autoloads/scene_navigator.gd` | Centralizes scene changes, menu routing, quitting, and optional transition playback. |
| SoundManager | `res://src/autoloads/sound_manager.gd` | Centralizes music, sound effects, audio player pooling, and project audio bus volume controls. |
| DisplaySettingsManager | `res://src/autoloads/display_settings_manager.gd` | Centralizes session display settings for window mode and VSync. |
| PauseManager | `res://src/autoloads/pause_manager.gd` | Centralizes gameplay pause state, pause menu overlays, and paused settings flow. |
| SaveManager | `res://src/autoloads/save_manager.gd` | Provides a minimal versioned profile save/load helper using Godot's per-user storage path. |

## Scene Navigation

`SceneNavigator` reads its default scene paths and transition settings from the `[scene_navigator]` section in `project.godot`.

Update those settings when replacing the placeholder start scene, swapping menus, disabling transitions, or changing the transition scene. The template includes routes for the main menu, settings menu, credits menu, and placeholder start scene.

Menu scene scripts should keep screen-specific intent local, such as Start, Settings, Credits, Resume, Back, and Quit actions. Shared behavior such as scene changes, transition playback, pause state, and audio playback should stay in reusable helpers or autoloads. Avoid introducing a data-driven menu action system until several screens repeat the same button action pattern.

## Project Info and Credits

Runtime project metadata lives in exported project settings, not in root repository files.

`ProjectInfo` at `res://src/common/project_info.gd` reads the project name from `application/config/name`, the visible app version from `application/config/version`, and the creator handle from `starter_template/credits/creator_handle`.

The root `VERSION` file is reserved for repository release tooling and is excluded from Godot exports. Use `ProjectInfo.get_project_version()` or `ProjectInfo.get_version_label()` when showing the version in-game.

The main menu shows the current version. The Credits menu shows the project name and creator credit. Update these values when starting a new project from the template.

## Interaction Helpers

`HitBox3D` at `res://src/common/interaction/hit_box_3d.gd` is a small `Area3D` helper for forwarding interactions to a target node.

It is intentionally 3D-only. Add a separate 2D helper only when a project has a real 2D interaction pattern to preserve.

## Pause Flow

`PauseManager` listens for the custom `pause` input action and only responds when pause has been enabled by the active scene.

Menu scenes should call `PauseManager.set_pause_allowed(false)` so the pause overlay cannot open on top of main-menu flows. Gameplay scenes should call `PauseManager.set_pause_allowed(true)` when they are ready for pause behavior.

The pause menu is an overlay at `res://src/ui/pause_menu/pause_menu.tscn`. It pauses the scene tree, shows Resume, Settings, and Main Menu actions, and can open the existing Settings menu as a paused overlay without changing away from the current gameplay scene.

## Input Baseline

`project.godot` defines a minimal custom input baseline for template projects:

- `move_left`, `move_right`, `move_up`, and `move_down` for cardinal movement.
- `interact` for generic player interaction.
- `pause` for gameplay pause.
- `confirm` and `cancel` for project-level non-UI prompts.

These names are deliberately genre-neutral. A new project can keep them for top-down, side-scroller, or 3D movement, or replace them with more specific names such as `move_forward`, `strafe_left`, or `turn_right` once the game controls are known.

The custom `cancel` action does not bind Escape so it does not collide with `pause`. Godot's built-in UI actions such as `ui_accept` and `ui_cancel` can still be used by Control nodes.

## Audio

The default audio bus layout defines `Master`, `Music`, and `SFX`.

`SoundManager` exposes a small global API for playing overlapping sound effects, playing or fading music, stopping audio, and setting normalized `0.0` to `1.0` volumes for the standard buses.

Volume settings are treated as user attenuation rather than mix calibration. `1.0` means the calibrated mix plays unchanged at `0 dB`, while `0.0` mutes the selected bus. The Settings menu presents these values as `0` to `10` steps and `SoundManager` maps them to fixed decibel levels so each step has a predictable perceptual change.

`Master` attenuates the final output of all audio routed through it. `Music` and `SFX` attenuate only their own buses before reaching `Master`, so muting or lowering one slider does not rewrite the other slider values.

Audio settings are persisted by `SoundManager` in `user://settings.cfg` under the `audio` section. UI scripts should call the manager API and let the manager handle save/load behavior.

## Display Settings

`DisplaySettingsManager` stores visual settings for the Settings menu.

The template uses `1280 x 720` as its base design size. Windowed mode restores that fixed OS window size and centers the window. Fullscreen mode uses the current display size while Godot's `canvas_items` stretch mode scales 2D scene content and UI from the base design size.

Display settings are persisted by `DisplaySettingsManager` in `user://settings.cfg` under the `display` section. New settings should follow the same pattern: the menu owns controls, while the manager owns defaults, application, and persistence.

Internal render resolution, low-resolution pixel scaling, SubViewport composition, texture filtering, render scale, and integer scaling are project-level rendering choices that should be planned separately per game.

## Save/Profile Flow

`SaveManager` is a small starter helper for game progress or profile data. It saves one profile file at `user://profile.cfg` with metadata for `version`, `created_at`, and `updated_at`, plus a generic `data` dictionary for project-specific fields.

`user://` is Godot's per-user application data location. It is outside the project repository and outside exported `res://` game resources. On desktop builds, Godot maps it to the player's local app data area for the game. On Web builds, Godot maps it to browser-backed persistent storage.

Use the settings managers for user preferences such as audio and display values. Use `SaveManager` as a starting point for game progress, profile metadata, unlocks, or other project-specific state. New projects can replace this helper with a slot-based or game-specific save system once their save requirements are known.
