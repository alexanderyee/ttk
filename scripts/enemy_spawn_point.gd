class_name EnemySpawnPoint extends Node3D

@export var spawn_path: Path3D
@export var animation_duration_s: float = 1.0
@export var end_rotation: Vector3

func spawn(enemy: Enemy) -> void:
	if end_rotation and not spawn_path:
		await rotate_enemy(enemy)
		return
	var path_follow = PathFollow3D.new()
	spawn_path.add_child(path_follow)
	path_follow.add_child(enemy)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(path_follow, "progress_ratio", 1.0, animation_duration_s)
	tween.tween_property(enemy.get_mesh(), "rotation_degrees", end_rotation, animation_duration_s)
	
	await tween.finished

	enemy.reparent(self)
	path_follow.queue_free()

func rotate_enemy(enemy: Enemy) -> void:
	enemy.global_position = global_position
	add_child(enemy)
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(enemy.get_mesh(), "rotation_degrees", end_rotation, animation_duration_s)
	await tween.finished

func is_available() -> bool:
	return get_child_count() == 0
