class_name BossMovement
extends Resource

# Base class for left hand boss movement scripts

func get_next_position(boss: LeftHandBossEnemy, time: float, delta: float) -> Vector3:
	return boss.global_position
