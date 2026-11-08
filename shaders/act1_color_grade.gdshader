shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Tone targets matched to Haliya tribal main menu palette
uniform vec3 shadow_teal : source_color = vec3(0.12, 0.22, 0.24); // #1e383d deep teal
uniform float shadow_tint_amount : hint_range(0.0, 1.0) = 0.28;
uniform float cool_temperature : hint_range(0.0, 1.0) = 0.16;
uniform float midtone_darken : hint_range(0.0, 1.0) = 0.12;

// Light vignette controls
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.36;
uniform float vignette_radius : hint_range(0.0, 2.0) = 0.90;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.50;

void fragment() {
	vec4 scn = texture(screen_texture, SCREEN_UV);
	float luma = dot(scn.rgb, vec3(0.299, 0.587, 0.114));

	// 1. Darken midtones slightly to bring forest closer to main menu's nocturnal depth
	vec3 col = scn.rgb * (1.0 - midtone_darken * (1.0 - luma * 0.5));

	// 2. Cooler tone: subtle reduction of warm red, subtle boost to cyan/blue
	col.r *= (1.0 - cool_temperature * 0.45);
	col.b *= (1.0 + cool_temperature * 0.25);

	// 3. Teal-tinted shadows (blend shadow_teal into dark areas)
	float shadow_mask = 1.0 - smoothstep(0.08, 0.55, luma);
	col = mix(col, col + shadow_teal * shadow_mask, shadow_tint_amount);

	// 4. Light vignette
	vec2 uv_dist = (SCREEN_UV - vec2(0.5)) * vec2(1.0, 0.5625);
	float dist = length(uv_dist);
	float vig = smoothstep(vignette_radius - vignette_softness, vignette_radius, dist) * vignette_strength;
	col *= (1.0 - vig);

	COLOR = vec4(clamp(col, vec3(0.0), vec3(1.0)), 1.0);
}
