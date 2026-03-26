shader_type canvas_item;
#include "../deps/FastNoiseLite.gdshaderinc"

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec4 ridge_colour;
uniform vec4 base_colour;

uniform vec2 offset;
uniform float scale = 1.0;

void fragment() {
	fnl_state state = fnlCreateState(0);
	
	state.noise_type = FNL_NOISE_PERLIN;
	state.frequency = 0.0084 / scale;
	state.fractal_type = FNL_FRACTAL_RIDGED;
	state.octaves = 1;
	
	float value = fnlGetNoise2D(state, VERTEX.x + offset.x, VERTEX.y + offset.y) * 4.0;
	float ridge_dist_abs = min((mod(value, 1)), mod(-value, 1));
	
	const float ridge_dist_threshold = 0.1;
	
	if (ridge_dist_abs > ridge_dist_threshold)
		ridge_dist_abs = ridge_dist_threshold;
	
	COLOR = mix(ridge_colour, base_colour, ridge_dist_abs / ridge_dist_threshold);
}
