# Builds

This project includes export presets for Web and Windows Desktop builds.

Automated builds run through GitHub Actions on pull requests and manual workflow runs. Build artifacts are uploaded to the workflow run and are not published as releases automatically.

Pull request and manual build artifacts are non-release test builds. They are retained for 7 days.

Artifact names use this format:

```text
<project-name>-<build-kind>-<platform>-<short-sha>
```

Examples:

```text
godot-starter-template-pr-web-a1b2c3d
godot-starter-template-manual-windows-a1b2c3d
```

Version numbers are intentionally not included in pull request or manual artifact names. Reserve versioned names for future release builds, such as `<project-name>-v<version>-<platform>.zip`.

Release builds run when a GitHub Release is published. Release packages are uploaded directly to the GitHub Release and are also uploaded as 90-day workflow artifacts. See `docs/releases.md` for the release process.

## Web Build Contents

The Web artifact should be kept as a folder of files. Do not remove the sidecar files unless you have changed the export preset and tested the result.

- `index.html` is the browser entry point.
- `index.js` contains the startup code used by the HTML page.
- `index.wasm` contains the Godot engine compiled to WebAssembly.
- `index.pck` contains the exported project data, including scenes, scripts, resources, and imported assets.
- `index.png` is the boot splash image used while the game loads.

Browsers usually cannot run the Web export by opening `index.html` directly from disk. Serve the folder from a local web server instead, then open the local server URL in the browser.

Example:

```powershell
cd path\to\web-build
python -m http.server 8000
```

Then open:

```text
http://localhost:8000/
```

Some Web export options require extra response headers. If a simple local server still fails with cross-origin isolation or CORS-related errors, test with Godot's recommended local Web server script or review the Web export preset options.

## Windows Build Contents

The Windows artifact should include the executable and project data pack together.

- `.exe` is the exported Godot runtime for Windows.
- `.pck` contains the exported project data, including scenes, scripts, resources, and imported assets.

Keep the `.exe` and `.pck` in the same folder. The Windows preset currently keeps the `.pck` separate instead of embedding it into the executable.

## Export Privacy

The export presets exclude documentation and repository workflow files from runtime builds. Keep private project notes in ignored documentation folders such as `docs/`, not inside runtime folders such as `src/`.

Run the export privacy audit after changing export presets:

```powershell
python3 scripts/audit_export_privacy.py
```

On Windows systems that use the Python launcher, run `py -3 scripts/audit_export_privacy.py` instead.

The audit checks each export preset in `export_presets.cfg` for required exclusions covering documentation, Markdown files, repository workflow files, and root metadata files. It is also run by the GitHub Actions validation job before export builds.
