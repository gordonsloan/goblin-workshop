extends CanvasLayer

@export var transition_duration: float = 0.32
@export var stagger_duration: float = 0.18
@export_range(4, 32, 1) var columns: int = 12
@export_range(4, 32, 1) var rows: int = 8
@export var square_color: Color = Color(0.0, 0.0, 0.0, 1.0)

@onready var _cells: Control = %Cells

var _tween: Tween = null
var _cell_nodes: Array[ColorRect] = []


func _ready() -> void:
	_build_cells()
	_set_cell_alpha(0.0)
	visible = false


func transition_out() -> void:
	visible = true
	_build_cells()
	_set_cell_alpha(0.0)
	await _tween_cells(1.0)


func transition_in() -> void:
	await _tween_cells(0.0)
	visible = false


func _build_cells() -> void:
	for child in _cells.get_children():
		child.queue_free()

	_cell_nodes.clear()

	var viewport_size := get_viewport().get_visible_rect().size
	var cell_size := Vector2(viewport_size.x / float(columns), viewport_size.y / float(rows))

	for row in range(rows):
		for column in range(columns):
			var cell := ColorRect.new()
			cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
			cell.color = Color(square_color.r, square_color.g, square_color.b, 0.0)
			cell.position = Vector2(column * cell_size.x, row * cell_size.y)
			cell.size = cell_size + Vector2.ONE
			_cells.add_child(cell)
			_cell_nodes.append(cell)


func _set_cell_alpha(alpha: float) -> void:
	for cell in _cell_nodes:
		cell.color.a = alpha


func _tween_cells(target_alpha: float) -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()

	_tween = create_tween()
	_tween.set_parallel(true)

	var max_diagonal: int = max(1, columns + rows - 2)
	var index: int = 0
	for row in range(rows):
		for column in range(columns):
			var cell: ColorRect = _cell_nodes[index]
			var diagonal: int = row + column
			var delay: float = stagger_duration * (float(diagonal) / float(max_diagonal))
			_tween.tween_property(cell, "color:a", target_alpha, transition_duration).set_delay(delay).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			index += 1

	await _tween.finished
