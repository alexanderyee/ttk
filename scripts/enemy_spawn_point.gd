class_name EnemySpawnPoint extends Node3D

@export var spawn_path: Path3D
@export var animation_duration_s := 1.0
@export var start_rotation: Vector3
@export var end_rotation: Vector3
@export var scale_override := Vector3(1.0, 1.0, 1.0)
@export var enabled: bool = true

func spawn(enemy: Enemy) -> void:
	enemy.scale = scale_override
	if not spawn_path and not end_rotation:
		add_child(enemy)
		return
	if end_rotation and not spawn_path:
		await rotate_enemy(enemy)
		return
	var path_follow = PathFollow3D.new()
	path_follow.rotation_mode = PathFollow3D.ROTATION_NONE
	spawn_path.add_child(path_follow)
	path_follow.add_child(enemy)
	enemy.rotation_degrees = start_rotation
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(path_follow, "progress_ratio", 1.0, animation_duration_s)
	tween.set_parallel()

	tween.tween_property(enemy, "rotation_degrees", end_rotation, animation_duration_s)
	
	await tween.finished

	enemy.reparent(self)
	path_follow.queue_free()

func rotate_enemy(enemy: Enemy) -> void:
	add_child(enemy)
	enemy.global_position = global_position
	enemy.rotation_degrees = start_rotation
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(enemy, "rotation_degrees", end_rotation, animation_duration_s)
	await tween.finished

func is_available() -> bool:
	for child in get_children():
		if child is Enemy:
			return false
	return true
