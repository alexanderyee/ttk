extends ColorRect

var gradient := Gradient.new()
var gradient_data := {
	0.0: Color.DARK_RED,
	1.0: Color.RED
}

func _ready() -> void:
	gradient.offsets = gradient_data.keys()
	gradient.colors = gradient_data.values()
	var gradient_texture := GradientTexture2D.new()
	gradient_texture.gradient = gradient
	material.set("shader_parameter/tex", gradient_texture)
	
