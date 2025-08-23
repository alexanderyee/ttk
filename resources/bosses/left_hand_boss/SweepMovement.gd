class_name SweepMovement
extends BossMovement

func get_next_position(boss: LeftHandBossEnemy, time: float, delta: float) -> Vector3:
	return boss.global_position
