shader_type canvas_item;

uniform float shimmer_speed : hint_range(0.5, 6.0) = 2.4;
uniform float lightning_flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_tint : source_color = vec4(0.72, 0.90, 1.0, 1.0);

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);
	
	// Preserve transparency of the organic puddle edge
	if (base_color.a < 0.03) {
		discard;
	}
	
	// Subtle pixel-art surface shimmer in discrete steps (matches retro FPS/timing)
	float stepped_time = floor(TIME * 6.0) / 6.0;
	float shimmer = sin(UV.x * 8.0 + stepped_time * shimmer_speed) * 0.035;
	
	// Only apply shimmer to the inner reflective water body, not the feathered grass edges
	if (base_color.a > 0.45) {
		base_color.rgb += vec3(shimmer * 0.8, shimmer * 1.0, shimmer * 1.3);
	}
	
	// Lightning reflection response: flash with specular reflection and dissolve cleanly
	if (lightning_flash > 0.01) {
		vec3 flash_glow = flash_tint.rgb * lightning_flash;
		base_color.rgb = mix(base_color.rgb, flash_glow, lightning_flash * 0.65);
		base_color.rgb += flash_tint.rgb * (lightning_flash * 0.45);
		base_color.a = min(1.0, base_color.a + lightning_flash * 0.2);
	}
	
	COLOR = base_color;
}
