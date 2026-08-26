# UI Themes

Shared project UI themes live here.

- `default_theme.tres` is the active project theme.
- `arcade_theme.tres` is an alternate theme that can be swapped in as a starting point.

To switch themes, update `gui/theme/custom` in `project.godot` to point at the theme resource you want:

```ini
[gui]

theme/custom="res://src/ui/themes/default_theme.tres"
```

Menu label sizes use theme variations:
- `MenuTitleLabel`
- `MenuSectionLabel`
- `MenuBodyLabel`

Use those variations on future menu labels so headings and body text can be restyled from the theme resource instead of per scene.
