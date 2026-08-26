# Changelog

All notable changes to this project will be documented in this file.

This project loosely follows Semantic Versioning.

## [Unreleased]

### Added

### Changed

### Fixed

### Removed

### Known Issues

## [0.2.0] - 2026-05-23

### Added

- Added persistent `ConfigFile` settings for audio, window mode, and VSync.
- Added small reusable menu audio wiring helpers for button and hover control groups.
- Added reusable main menu and settings menu templates.
- Added scene navigation autoload with configurable menu, settings, start scene, and transition paths.
- Added fade, wipe, checker, and instant scene transition templates.
- Added sound manager autoload with music, sound effect pooling, and standard `Master`, `Music`, and `SFX` buses.
- Added placeholder menu music and UI sound effects.
- Added display settings manager with window mode and VSync controls.
- Added pause manager autoload and reusable pause menu template with Resume, Settings, and Main Menu actions.
- Added baseline input actions for movement, interaction, pause, confirm, and cancel.
- Added minimal `SaveManager` profile persistence helper using `user://profile.cfg`.
- Added reusable runtime project info helper for project name, app version, and creator credits.
- Added a Credits menu and visible main menu app version label.
- Added an export privacy audit script and CI validation step for export preset exclusions.
- Added default and arcade UI themes.
- Added animated checkerboard menu background shader.
- Added placeholder start scene for template projects.
- Added Web and Windows Desktop export presets.
- Added GitHub Actions builds for pull requests and manual Web/Windows exports.
- Added build artifact naming and 7-day retention for pull request and manual build artifacts.
- Added build documentation covering exported files, artifact naming, and local Web testing.
- Added pull request template with testing and changelog reminders.
- Added a GitHub Actions validation job for headless project load and script parsing before export builds.
- Added version metadata sync/check script using `VERSION` as the source of truth.
- Added CI version metadata drift checking.
- Added GitHub Release build workflow for Web and Windows release packages.
- Added release documentation covering version sync, changelog prep, release tags, and release assets.

### Changed

- Updated menu and pause scripts to prefer direct autoload calls where practical.
- Updated menu audio helpers to load placeholder audio lazily and skip audio wiring during headless validation.
- Updated template guidance for exports, scene-local button intent, and avoiding premature data-driven menu action abstractions.
- Renamed the reusable interaction helper from `HitBox` to `HitBox3D` to make its 3D-only scope explicit.
- Updated architecture and build documentation for save/profile storage and export privacy audits.
- Updated project setup and README guidance for export presets, build workflow, and documentation privacy.
- Updated architecture documentation for autoloads, scene navigation, audio, and display settings.
- Kept documentation visible in Godot while excluding documentation and repository workflow files from exports.
- Defaulted Windows exports to fullscreen while keeping editor and Web builds windowed.
- Added stretch-based scaling for 2D scene content, UI, and the animated menu background.
- Updated settings menu back behavior so it can be reused from the pause overlay without leaving gameplay.
- Hid the Quit button in Web builds and guarded quit behavior on unsupported platforms.
- Updated Codex/agent workflow guidance for the expanded template structure.
- Updated `VERSION`, runtime app version metadata, and Windows export version metadata to `0.2.0`.

### Fixed

- Fixed fresh-checkout headless validation by storing the main scene as a `res://` path instead of a UID.
- Fixed GitHub Actions Godot download URLs for CI builds.
- Fixed missing settings menu sound effects and made sound sliders use stepped values.
- Fixed integer division warning when centering the window in display settings.
- Removed debug output from `HitBox3D` and made interaction forwarding less opinionated.

### Removed

### Known Issues

## [0.1.0] - 2026-04-29

### Added

- Added starter Godot project structure.
- Added `src/` folder organization.
- Added placeholder README files for core source folders.
- Added initial documentation structure.
- Added `CHANGELOG.md`.
- Added `VERSION`.
