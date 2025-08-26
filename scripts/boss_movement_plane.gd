class_name BossMovementPlane
extends Node3D

@export var size_x: float = 20.0	# world units width
@export var size_y: float = 10.0	# world units height
@export var cols: int = 6
@export var rows: int = 3

func get_cell_center_global_transform(col: int, row: int) -> Vector3:
	if row >= rows or col >= cols:
		push_warning("Requested cell is out of bounds: " + str(col) + ", " + str(row))
		return Vector3.ZERO
	var local_x := float(col) / float(cols)	* size_x + size_x / float(cols) / 2.0	# 0..size_x
	var local_y := float(row) / float(rows)	* size_y + size_y / float(rows) / 2.0	# 0..size_y
	# Local 3D offset on the plane: X = right, Y = up (board's local)
	var local := Vector3(local_x - size_x / 2.0, 0.0, local_y - size_y / 2.0)
	return global_transform * local

func random_cell(current: Vector2i = Vector2i(-1, -1)) -> Vector2i:
	# build possible cells
	var possible_cells := []
	for c in range(cols):
		for r in range(rows):
			if current.x == c and current.y == r:
				continue
			possible_cells.append(Vector2i(c, r))
	if possible_cells.size() <= 0:
		push_error("Unable to get random cell, no possible cells!")
		return Vector2i(-1, -1)
	return possible_cells[randi() % possible_cells.size()]
