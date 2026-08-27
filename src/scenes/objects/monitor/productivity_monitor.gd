extends Node3D
class_name ProductivityMonitor

@export_node_path("MeshInstance3D") var display_mesh_path: NodePath = ^"display"
@export_node_path("SubViewport") var display_viewport_path: NodePath = ^"DisplayViewport"
@export_node_path("ProgressBar") var progress_bar_path: NodePath = ^"DisplayViewport/DisplayRoot/ProductivityBar"
@export_node_path("Label") var value_label_path: NodePath = ^"DisplayViewport/DisplayRoot/ValueLabel"
@export var display_color: Color = Color(0.55, 0.9, 1.0, 1.0)

@onready var _display_mesh: MeshInstance3D = get_node(display_mesh_path) as MeshInstance3D
@onready var _display_viewport: SubViewport = get_node(display_viewport_path) as SubViewport
@onready var _progress_bar: ProgressBar = get_node(progress_bar_path) as ProgressBar
@onready var _value_label: Label = get_node(value_label_path) as Label


func _ready() -> void:
	_apply_display_material()
	_configure_progress_bar()
	_update_productivity(GameManager.productivity)
	GameManager.productivity_changed.connect(_update_productivity)


func _configure_progress_bar() -> void:
	_progress_bar.min_value = 0.0
	_progress_bar.max_value = 100.0
	_progress_bar.step = 0.1
	_progress_bar.show_percentage = false


func _update_productivity(value: float) -> void:
	_progress_bar.value = value
	_value_label.text = "%d%%" % roundi(value)


func _apply_display_material() -> void:
	var texture := _display_viewport.get_texture()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color = display_color
	material.emission_enabled = true
	material.emission = display_color
	material.emission_texture = texture
	material.emission_energy_multiplier = 1.2
	_display_mesh.set_surface_override_material(0, material)
