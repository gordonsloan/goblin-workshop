# Common

Store reusable scripts, scenes, and resources here that are not specific to one game object, level, or UI screen.

Examples:
- Interaction helpers
- Reusable camera helpers
- Debug utilities
- Generic component scripts
- Shared base classes

Current reusable helpers:
- `project_info.gd` reads exported project settings for project name, visible app version, and creator credits.
- `interaction/hit_box_3d.gd` forwards `Area3D` interactions to a target node.

Game-specific scenes should usually live in `src/scenes/`.
