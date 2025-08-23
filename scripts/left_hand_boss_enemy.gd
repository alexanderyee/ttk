class_name LeftHandBossEnemy extends Enemy

enum MOVEMENT_STATE {
	IDLE,
	SWEEP_DOWN_LEFT,
	ATTACKING
}

var current_state: MOVEMENT_STATE = MOVEMENT_STATE.IDLE

func _ready():
	super._ready()

func _process(delta: float) -> void:
	super._process(delta)
	# movement


func player_letter_typed(letter: String, dmg: float) -> bool:
	if not is_mouse_over():
		return false
	return super.player_letter_typed(letter, dmg)

func is_mouse_over() -> bool:
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var camera := viewport.get_camera_3d()
	var from := camera.project_ray_origin(mouse_pos)
	var to := from + camera.project_ray_normal(mouse_pos) * 1000.0

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))

	if result and result.collider == self:
		return true

	return false
