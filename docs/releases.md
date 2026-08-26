# Releases

This project uses the root `VERSION` file as the source of truth for release version numbers.

## Version Metadata

Update `VERSION` manually during release preparation, then sync generated metadata:

```powershell
python scripts/sync_version.py --write
```

On Windows systems without `python` on PATH, use the Python launcher or another known Python executable:

```powershell
py -3 scripts/sync_version.py --write
```

The sync script updates:

- `project.godot` runtime app version.
- `src/common/project_info.gd` fallback version.
- `src/ui/main_menu/main_menu.tscn` editor preview label.
- Windows export preset file and product versions.

CI runs the same script in check mode:

```powershell
python scripts/sync_version.py --check
```

## Release Preparation

Prepare releases from `main` after feature work has merged.

1. Update `VERSION`.
2. Run the version sync script in write mode.
3. Move `CHANGELOG.md` entries from `[Unreleased]` to the new release section.
4. Reset `[Unreleased]` to empty headings.
5. Run local validation.
6. Commit the release prep changes.
7. Create and publish a GitHub Release whose tag matches `v<VERSION>`.

For example, `VERSION` value `0.2.0` must be released with tag `v0.2.0`.

## Release Builds

Publishing a GitHub Release triggers `.github/workflows/godot-release.yml`.

The release workflow:

- Checks that the release tag matches `VERSION`.
- Runs the project validation and export privacy audit.
- Runs version metadata drift checks.
- Exports Web and Windows release builds.
- Packages release assets under `builds/release/v<VERSION>/` inside the workflow runner.
- Uploads zip files and `SHA256SUMS.txt` to the GitHub Release.
- Uploads the same packaged files as workflow artifacts with 90-day retention.

GitHub Actions cannot save files into your local `builds/` folder. The `builds/release/v<VERSION>/` path is used inside the runner so release packages have the same shape as local release output.

## Local Release Builds

To create local release builds manually, export through Godot using the existing presets and place packaged output under:

```text
builds/release/v<VERSION>/
```

Use the same names as the release workflow:

```text
godot-starter-template-v<VERSION>-web.zip
godot-starter-template-v<VERSION>-windows.zip
SHA256SUMS.txt
```
