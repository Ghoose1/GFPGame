shader_type canvas_item;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform vec4 ridge_colour;
uniform vec4 base_colour;

void fragment() {
	float value = texture(TEXTURE, UV).r * 4.0;
	float ridge_dist_abs = min((mod(value, 1)), mod(-value, 1));
	
	const float ridge_dist_threshold = 0.1;
	
	if (ridge_dist_abs > ridge_dist_threshold)
		ridge_dist_abs = ridge_dist_threshold;
	
	//COLOR = vec4(ridge_dist_abs);
	COLOR = mix(ridge_colour, base_colour, ridge_dist_abs / ridge_dist_threshold);
	
	//if (ridge_dist_abs < 0.02)
		//COLOR = vec4(1.0, 0.0, 0.0, 1.0);
	//if ((value - float(int(value))) > 0.1)
		//COLOR = base_colour;
	//else
		//COLOR = ridge_colour;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
