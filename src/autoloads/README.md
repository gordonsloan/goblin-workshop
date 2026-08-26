# Autoloads

Store scripts here that are intended to be registered as Godot autoloads/singletons.

Examples:
- Game state managers
- Save/load managers
- Audio managers
- Scene transition managers
- Global signal/event buses

Only place files here if they are intended to be globally available through Project Settings > Autoload.

Current template autoloads include:

- `SceneNavigator` for menu and scene transitions.
- `SoundManager` for music, SFX, and audio bus volumes.
- `DisplaySettingsManager` for display preferences.
- `PauseManager` for gameplay pause overlays.
- `SaveManager` for a minimal versioned profile save/load pattern.
