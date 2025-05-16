class_name PlayerCamera
extends Camera3D

@export var shake_intensity := Vector3(0.1, 0, 0)
func shake() -> void:
	var start_pos = global_transform.origin
	var right_peak_pos = start_pos + shake_intensity
	var left_peak_pos = start_pos - shake_intensity
	
	var tween := create_tween()
	#tween.tween_property(self, "global_transform:origin", )
