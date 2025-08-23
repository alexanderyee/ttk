class_name HoverMovement
extends BossMovement

const FLIP_Y: Vector3 = Vector3(0, -1, 1)
@export var amplitude: float = 15.0
@export var frequency: float = 0.5
@export var axis: Vector3 = Vector3(0, .5, 1)
@export var base_position: Vector3
@export var max_y: float = 9.0
@export var min_y: float = 0.0

func get_next_position(boss: LeftHandBossEnemy, time: float, delta: float) -> Vector3:
	var offset = axis * sin(time * frequency) * amplitude
	var result_pos: Vector3 = base_position + offset
	if result_pos.y >= max_y or result_pos.y <= min_y:
		axis *= Vector3.DOWN
		return base_position
	return base_position + offset
