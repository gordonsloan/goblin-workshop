# Godot Starter Project

A reusable Godot starter template for small-scale game projects.

## Intended Use

This template is intended for:
- Small Godot prototypes
- Web exports for itch.io
- Windows desktop builds
- Projects using GDScript
- Scene-local script organization

## Folder Structure

- `src/assets/` - Game assets such as audio, images, fonts, models, and third-party content.
- `src/autoloads/` - Global singleton scripts.
- `src/common/` contains reusable scripts, scenes, and resources that are not specific to one game object or level.
- `src/data/` - Static data resources, config files, JSON, custom resources, etc.
- `src/scenes/` - Main game scenes, actors, objects, levels, and systems.
- `src/shaders/` - Shader files and shader resources.
- `src/ui/` - UI scenes, controls, menus, HUDs, and reusable UI components.
- `docs/` - Project documentation and workflow notes. Visible in Godot but excluded from exports by preset filters.
- `exports/` - Local export output. Ignored by Godot and Git.
- `builds/` - Local build output. Ignored by Godot and Git.

## Naming Conventions

- Files and folders use `snake_case`.
- Godot node names use `PascalCase`.
- Scene files should usually sit beside their related scripts.

## Starting a New Project

1. Create a new repository from this template.
2. Rename the project in `project.godot`.
3. Update this README.
4. Set the main scene.
5. Update `application/config/version` and `starter_template/credits/creator_handle` in `project.godot`.
6. Review the Web and Windows export presets.
7. Review the GitHub Actions build workflow.

## New Project Setup Checklist

After creating a new repository from this template:

- [ ] Rename the project in Godot Project Settings.
- [ ] Update the root `README.md`.
- [ ] Replace the default icon.
- [ ] Set the main scene.
- [ ] Update the runtime version and credits handle.
- [ ] Configure display/window/stretch settings.
- [ ] Configure input actions.
- [ ] Review export preset names, icons, metadata, and supported platforms.
- [ ] Confirm GitHub Actions should build Web, Windows, or both.
- [ ] Update `docs/architecture.md`.
- [ ] Remove unused placeholder README files if desired.
- [ ] Create the first project-specific commit.

## Builds and Exports

This template includes Web and Windows export presets plus GitHub Actions workflows for pull request, manual, and published release builds.

Documentation and repository workflow files are excluded from Godot exports by the export preset filters. Keep runtime assets and scripts under `src/`, and keep private planning or agent notes under `docs/` or another non-runtime documentation folder.

Release version metadata is synced from the root `VERSION` file. See `docs/releases.md` for the release process.
