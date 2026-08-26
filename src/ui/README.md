# UI

Store user interface scenes, scripts, and resources here.

Examples:
- Menus
- HUDs
- Dialog boxes
- Inventory screens
- Pause screens
- Reusable UI components

Where practical, keep UI scripts beside the `.tscn` files they support.

`menu_audio.gd` contains small helpers for shared menu sounds, hover sounds, and bulk button/control wiring. Keep screen-specific button intent in the owning scene script unless repeated menu screens make a more generic action layer worthwhile.

The Credits menu reads project name and creator handle through `ProjectInfo`, so it continues to work in exported builds where root repository metadata files are excluded.
