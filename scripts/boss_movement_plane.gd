class_name BossMovementPlane
extends Node3D

@export var size_x: float = 30.0
@export var size_y: float = 12.0
@export var cols: int = 10
@export var rows: int = 4
var cell_width := size_x / cols
var cell_height := size_y / rows

func _process(_delta: float) -> void:
	# draw plane
	if Global.DEBUG_MODE:
		for c in range(cols):
			for r in range(rows):
				var local_x := float(c) / float(cols) * size_x + cell_width
				var local_y := float(r) / float(rows) * size_y + cell_height
				var local := Vector3(0.0, local_y - size_y / 2.0, local_x - size_x / 2.0)
				var top_left_global := to_global(local)
				var top_right_global := top_left_global + Vector3(0.0, 0.0, cell_width)
				var bottom_left_global := top_left_global + Vector3(0.0, -cell_height, 0.0)
				var bottom_right_global := top_right_global + Vector3(0.0, -cell_height, 0.0)
				DebugDraw3D.draw_line(top_left_global, top_right_global, Color.FUCHSIA)
				DebugDraw3D.draw_line(top_right_global, bottom_right_global, Color.FUCHSIA)
				DebugDraw3D.draw_line(bottom_right_global, bottom_left_global, Color.FUCHSIA)
				DebugDraw3D.draw_line(bottom_left_global, top_left_global, Color.FUCHSIA)
				var cell_center: Vector3 = get_cell_center_global_transform(c, r)
				DebugDraw3D.draw_sphere(cell_center, .2, Color.AQUA)
			
	pass

func get_cell_center_global_transform(col: int, row: int) -> Vector3:
	if row >= rows or col >= cols:
		push_warning("Requested cell is out of bounds: " + str(col) + ", " + str(row))
		return Vector3.ZERO
	var local_x := float(col) / float(cols)	* size_x + cell_width / 2.0
	var local_y := float(row) / float(rows)	* size_y + cell_height / 2.0
	var local := Vector3(0.0, local_y - size_y / 2.0, local_x - size_x / 2.0)
	
	return to_global(local)

func get_random_cell(current: Vector2i = Vector2i(-1, -1)) -> Vector2i:
	var random_cell := current
	while (random_cell - current).length() > 1:
		random_cell = Vector2i(Global.rng.randi_range(0, cols), Global.rng.randi_range(0, rows))
	return random_cell
	
func get_center_cell() -> Vector2i:
	return Vector2i(cols / 2, rows / 2)
