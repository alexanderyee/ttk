class_name SweepMovement
extends BossMovement

@export var speed: float = 5.0
@export var min_global_z: float = -25.0
@export var max_global_z: float = -5.0
var dir := 1

func get_next_position(boss: LeftHandBossEnemy, time: float, delta: float) -> Vector3:
	var pos = boss.global_position
	pos.z += speed * dir * delta
	if pos.z > max_global_z or pos.z < min_global_z:
		dir *= -1
		pos = boss.global_position
	return pos
