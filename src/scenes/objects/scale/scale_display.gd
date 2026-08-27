extends Node3D
class_name ScaleDisplay

@export_node_path("MeshInstance3D") var display_mesh_path: NodePath = ^"display"
@export_node_path("SubViewport") var display_viewport_path: NodePath = ^"DisplayViewport"
@export_node_path("Label") var value_label_path: NodePath = ^"DisplayViewport/DisplayRoot/ValueLabel"
@export var display_color: Color = Color(0.45, 1.0, 0.35, 1.0)

@onready var _display_mesh: MeshInstance3D = get_node(display_mesh_path) as MeshInstance3D
@onready var _display_viewport: SubViewport = get_node(display_viewport_path) as SubViewport
@onready var _value_label: Label = get_node(value_label_path) as Label


func _ready() -> void:
	_apply_display_material()
	clear_display()
	GameManager.box_weight_displayed.connect(_on_box_weight_displayed)
	GameManager.box_cleared.connect(_on_box_cleared)


func show_weight(weight_kg: float) -> void:
	_value_label.text = "%.1f kg" % weight_kg


func clear_display() -> void:
	_value_label.text = ""


func _apply_display_material() -> void:
	var texture := _display_viewport.get_texture()
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = texture
	material.albedo_color = display_color
	material.emission_enabled = true
	material.emission = display_color
	material.emission_texture = texture
	material.emission_energy_multiplier = 1.5
	_display_mesh.set_surface_override_material(0, material)


func _on_box_weight_displayed(_box: Node, weight_kg: float) -> void:
	show_weight(weight_kg)


func _on_box_cleared(_box: Node) -> void:
	clear_display()
