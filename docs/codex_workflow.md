# Codex Workflow

## Good Tasks for Codex

- Refactor a small scene/script pair.
- Add typed variables and comments.
- Review a script for bugs.
- Generate manual test steps.
- Create helper functions.
- Update documentation after a change.

## Risky Tasks

Ask for confirmation before:
- Moving large parts of the project structure.
- Renaming scenes, nodes, autoloads, or input actions.
- Adding plugins or third-party dependencies.
- Changing project-wide settings.
- Changing export settings.

## Expected Response From Codex

For each change, Codex should provide:
1. Summary of changes.
2. Files modified.
3. Manual Godot test steps.
4. Risks or assumptions.

## Changelog Practice

Keep `CHANGELOG.md` manually curated under `[Unreleased]` during feature work.

Add changelog entries when a change affects:
- Player-facing or user-facing behavior.
- Reusable template systems.
- Build or release process.
- Documentation or workflow guidance.
- Architecture or project conventions.

Do not add changelog entries for tiny internal refactors unless they affect template users.

Before merging a pull request, confirm the changelog was considered. Before a release, move relevant `[Unreleased]` entries into the next version section and reset `[Unreleased]`.
