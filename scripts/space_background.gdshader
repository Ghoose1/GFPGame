shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec2 random(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}
float worley(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	
	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);
			
			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			minimum_dist = min(minimum_dist, dist);
		}
	}
	
	return minimum_dist;
}
vec2 voronoi(vec2 uv, float columns, float rows) {
	
	vec2 index_uv = floor(vec2(uv.x * columns, uv.y * rows));
	vec2 fract_uv = fract(vec2(uv.x * columns, uv.y * rows));
	
	float minimum_dist = 1.0;  
	vec2 minimum_point;

	for (int y= -1; y <= 1; y++) {
		for (int x= -1; x <= 1; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = random(index_uv + neighbor);

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);
			
			if(dist < minimum_dist) {
				minimum_dist = dist;
				minimum_point = point;
			}
		}
	}
	return minimum_point;
}

uniform vec2 offset;
uniform float scale = 1.0;

const vec3 BLACK = vec3(0);
const vec3 WHITE = vec3(1);

const vec3 gradient_colours[] = {
	vec3(0, 0.7, 0.75), 
	vec3(0, 0.25, 1.0), 
	vec3(1, 0.5, 0.75), 
	WHITE
};
const float gradient_values[] = {
	0.0, 0.25, 0.5, 0.65, 1.0
};

// x = a * (1 - r) + b * (r)
// x = a - r(a + b)
// r = (a - x) / (a + b)
float between(float a, float b, float x) {
	return (a - x) / (a + b);
}

vec3 gradient(float input) {
	for (int i = 0; i < gradient_values.length() - 1; i++) {
		if (input > gradient_values[i + 1]) 
			continue;
		
		return mix(gradient_colours[i], gradient_colours[i + 1], between(gradient_values[i], gradient_values[i + 1], input));
	}
}

void fragment() {
	float worley_val = worley((VERTEX + offset) / scale, 12.0, 6.0);
	float voronoi_val = voronoi(UV, 12.0, 6.0).r;
	
	float bright_value = 1.0 - worley_val;
	
	const float bright_threshold = 0.03;
	
	if (bright_value > (1.0 - bright_threshold)) {
		//vec4 bright_colour = vec4(gradient(voronoi_val), 1);
		//vec4 bright_colour = vec4(WHITE, 1);
		vec4 bright_colour = vec4(gradient_colours[int(voronoi_val * 4.0) % gradient_colours.length()], 1);
		COLOR = mix(vec4(BLACK, 1), bright_colour, (bright_value - 1.0 + bright_threshold) / bright_threshold);
	}
	else 
		COLOR = vec4(BLACK, 1);
	
}
