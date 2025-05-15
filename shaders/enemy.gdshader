shader_type spatial;

uniform float intensity : hint_range(0.0, 1.0) = 0.0;
uniform bool is_flashing = false;
uniform bool is_flashing_fast = false;
uniform float fade_amount : hint_range(0.0, 1.0) = 0.0;


void fragment() {
	vec3 base_color = mix(vec3(1.0), vec3(1.0, 0.0, 0.0), intensity);
	if (is_flashing) {
		base_color = mix(vec3(1.0), vec3(1.0, 0.0, 0.0), abs(sin(TIME * 5.0)));
	} else if (is_flashing_fast) {
		base_color = mix(vec3(1.0), vec3(1.0, 0.0, 0.0), abs(sin(TIME * 16.0)));

	}
	vec4 color = vec4(base_color, ALPHA);
	color.a *= 1.0 - fade_amount;
	ALBEDO = base_color;
	ALPHA = color.a;
}
