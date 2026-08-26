# Starting a New Project From This Template

## Steps

1. Create a new GitHub repository from this template.
2. Clone it locally.
3. Open the project in Godot.
4. Rename the project in Project Settings.
5. Set the main scene.
6. Update `application/config/version` and `starter_template/credits/creator_handle` in `project.godot`.
7. Update README.md.
8. Update docs/architecture.md.
9. Configure input actions.
10. Review the Web and Windows export presets.
11. Review the GitHub Actions build workflow.
12. Commit the initial project-specific setup.

## Documentation and Exports

The `docs/` folder is visible in the Godot editor so project notes can be reviewed alongside runtime files.

The export presets exclude the `docs/` folder, Markdown documentation, and root-level repository files such as `VERSION`, `.github/`, `.gitignore`, and `.gitattributes`. Keep private workflow notes in documentation folders, not inside runtime folders such as `src/`.

## Automated Builds

The template includes a GitHub Actions workflow for Web and Windows exports.

- Pull requests build both platforms.
- Manual runs can build Web, Windows, or both.
- Manual runs can choose release or debug exports.
- Published GitHub Releases build Web and Windows release packages.
- Pull request and manual artifacts are uploaded to the workflow run; release packages are attached to the GitHub Release.

When creating a new project from this template:

1. Keep the preset names `Web` and `Windows Desktop` unless you also update the workflow.
2. Update `project.godot` with the new project name and main scene.
3. Update `application/config/version` for in-game version display.
4. Update `starter_template/credits/creator_handle` for the Credits menu.
5. Update export preset metadata such as product name, icon, version, and company fields.
6. Remove any platform preset you do not plan to support.

## Optional Godot Editor Folders

Godot may create optional project-level folders for editor customization:

- `script_templates/` stores custom script templates.
- `feature_profiles/` stores editor feature profiles.
- `text_editor_themes/` stores editor syntax themes.
- `export_templates/` is only needed if you intentionally keep custom export templates in the project.

These folders are not required for the starter template unless you add project-specific content to them.
