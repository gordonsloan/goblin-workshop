# UI Transitions

Reusable scene transition effects live here.

`fade_transition.tscn` is the default transition used by `SceneNavigator`.

Available starter transitions:

- `fade_transition.tscn` - fades to and from a full-screen color.
- `wipe_transition.tscn` - wipes a full-screen color across the viewport.
- `checker_transition.tscn` - covers and reveals the viewport with staggered checker squares.
- `instant_transition.tscn` - keeps the transition interface but skips visible animation.

To switch the active transition, update `scene_navigator/transition_scene_path` in `project.godot`:

```ini
[scene_navigator]

transition_scene_path="res://src/ui/transitions/checker_transition.tscn"
```

To add another transition:

1. Create a transition scene.
2. Attach a script with these methods:

```gdscript
func transition_out() -> void:
	pass

func transition_in() -> void:
	pass
```

3. Update `scene_navigator/transition_scene_path` in `project.godot`.

Set `scene_navigator/use_transitions=false` to disable transitions while keeping centralized navigation.
