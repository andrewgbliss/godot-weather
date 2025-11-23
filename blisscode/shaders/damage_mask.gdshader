shader_type canvas_item;

uniform sampler2D DamageTexture : filter_nearest, hint_default_black;
uniform float DamageAmount : hint_range(0, 100) = 0;
uniform vec2 TextureSize = vec2(16.0, 16.0); // Size of the sprite in pixels
uniform vec4 DamageColor : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Color tint that increases with damage

void fragment() {
	vec4 base_tex = texture(TEXTURE, UV);
	vec4 damage_tex = texture(DamageTexture, UV);

	// Snap UV to pixel grid
	vec2 pixel_uv = floor(UV * TextureSize) / TextureSize + (0.5 / TextureSize);
	
	// Calculate distance from center using snapped coordinates
	vec2 centered_uv = pixel_uv - vec2(0.5);
	float distance_from_center = length(centered_uv);
	
	// Normalize to 0-1 range (max distance is ~0.707 for corners)
	float normalized_distance = distance_from_center / 0.707;
	
	// Normalize DamageAmount to 0-1 range
	float damage_threshold = DamageAmount / 100.0;
	
	// Show damage where distance is less than threshold (from center outward)
	float mask = step(normalized_distance, damage_threshold);

	// Show base texture with damage texture overlaid where mask is active
	vec3 damage_blend = mix(base_tex.rgb, damage_tex.rgb, mask * damage_tex.a);
	
	// Apply damage color tint based on damage amount (max 80%)
	COLOR.rgb = mix(damage_blend, DamageColor.rgb, damage_threshold * DamageColor.a * 0.8);
	COLOR.a = base_tex.a;
}