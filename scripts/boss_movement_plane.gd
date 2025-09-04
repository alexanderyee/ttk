class_name BossMovementPlane
extends Node3D

@export var size_x: float = 30.0
@export var size_y: float = 12.0
@export var cols: int = 11
@export var rows: int = 4
var cell_width := size_x / cols
var cell_height := size_y / rows

func _process(_delta: float) -> void:
	pass

func get_cell_center_global_position(col: int, row: int) -> Vector3:
	if row >= rows or col >= cols:
		push_warning("Requested cell is out of bounds: " + str(col) + ", " + str(row))
		return Vector3.ZERO
	var local_x := float(col) / float(cols) * size_x + cell_width / 2.0
	var local_y := float(row) / float(rows) * size_y + cell_height / 2.0
	var local := Vector3(0.0, local_y - size_y / 2.0, local_x - size_x / 2.0)
	
	return to_global(local)

func get_random_cell(current: Vector2i = Vector2i(-1, -1)) -> Vector2i:
	var random_cell := current
	while (random_cell - current).length() <= 2:
		random_cell = Vector2i(Global.rng.randi_range(0, cols - 1), Global.rng.randi_range(0, rows - 1))
	return random_cell
	
func get_center_cell() -> Vector2i:
	return Vector2i(floor(cols / 2.0), floor(rows / 2.0))
