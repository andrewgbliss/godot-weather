shader_type canvas_item;

uniform int rarity : hint_range(0, 4) = 0; // 0=COMMON, 1=UNCOMMON, 2=RARE, 3=EPIC, 4=LEGENDARY
uniform float intensity : hint_range(0.0, 2.0) = 1.0; // Controls the intensity of the color effect
uniform float border_width : hint_range(0.0, 10.0) = 2.0; // Controls the width of the border

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Get the original color
	vec4 original_color = texture(TEXTURE, UV);

	// Define rarity colors (you can adjust these to match your game's theme)
	vec3 rarity_colors[5];
	rarity_colors[0] = vec3(0.7, 0.7, 0.7); // COMMON - Gray
	rarity_colors[1] = vec3(0.2, 0.8, 0.2); // UNCOMMON - Green
	rarity_colors[2] = vec3(0.2, 0.2, 0.8); // RARE - Blue
	rarity_colors[3] = vec3(0.8, 0.2, 0.8); // EPIC - Purple
	rarity_colors[4] = vec3(1.0, 0.8, 0.0); // LEGENDARY - Gold

	// Get the color for the current rarity
	vec3 rarity_color = rarity_colors[rarity];

	// If the original pixel is transparent, keep it transparent
	if (original_color.a < 0.01) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}

	// Apply rarity tinting to non-transparent pixels
	vec3 final_color = mix(original_color.rgb, rarity_color, intensity * 0.3);
	COLOR = vec4(final_color, original_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
