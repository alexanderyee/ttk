shader_type spatial;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform bool is_flashing = false;
uniform bool is_flashing_fast = false;

void fragment() {
	vec3 color = mix(vec3(1.0), vec3(1.0, 0.0, 0.0), intensity);
	if (is_flashing) {
		color = mix(vec3(1.0), vec3(1.0, 0.0, 0.0), abs(sin(TIME * 5.0)));
	} else if (is_flashing_fast) {
		color = mix(vec3(1.0), vec3(1.0, 0.0, 0.0), abs(sin(TIME * 16.0)));

	}
	ALBEDO = color;
}
