shader_type canvas_item;
render_mode unshaded;

void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	float distance_to_edge = length(p);
	float light = max(0.0, 1.0 - length((UV - vec2(0.5, 0.43)) * vec2(1.2, 1.0)));
	vec2 pixel = floor(UV * vec2(360.0, 500.0));
	float grain = fract(sin(dot(pixel, vec2(12.9898, 78.233))) * 43758.5453) - 0.5;
	vec3 felt = mix(vec3(0.043, 0.125, 0.086), vec3(0.098, 0.273, 0.180), light);
	felt += grain * 0.025;
	COLOR = vec4(felt, 1.0 - smoothstep(0.97, 1.0, distance_to_edge));
}
