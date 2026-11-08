shader_type canvas_item;

// Color grading parameters
uniform float desaturation : hint_range(0.0, 1.0) = 0.35;
uniform vec3 tint_slate : source_color = vec3(0.227, 0.290, 0.361); // #3a4a5c
uniform vec3 tint_teal : source_color = vec3(0.247, 0.420, 0.400);  // #3f6b66
uniform float tint_amount : hint_range(0.0, 1.0) = 0.32;

// Vignette parameters
uniform float vignette_radius : hint_range(0.0, 2.0) = 0.88;
uniform float vignette_softness : hint_range(0.0, 1.0) = 0.42;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.80;

// Dissolve transition
uniform float dissolve_progress : hint_range(0.0, 1.0) = 1.0;

// 4x4 Bayer matrix
const mat4 bayer4 = mat4(
	vec4( 0.0/16.0,  8.0/16.0,  2.0/16.0, 10.0/16.0),
	vec4(12.0/16.0,  4.0/16.0, 14.0/16.0,  6.0/16.0),
	vec4( 3.0/16.0, 11.0/16.0,  1.0/16.0,  9.0/16.0),
	vec4(15.0/16.0,  7.0/16.0, 13.0/16.0,  5.0/16.0)
);

float get_bayer(vec2 coord) {
	ivec2 p = ivec2(mod(coord, 4.0));
	return bayer4[p.x][p.y];
}

void fragment() {
	// Bayer dither dissolve
	vec2 pixel_coord = floor(UV * vec2(640.0, 360.0));
	float b_val = get_bayer(pixel_coord);
	if (dissolve_progress < 1.0) {
		if (dissolve_progress < b_val) {
			discard;
		}
	}

	vec4 tex_color = texture(TEXTURE, UV);
	if (tex_color.a <= 0.001) {
		discard;
	}

	// 1. Desaturation ~35%
	float luma = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
	vec3 graded = mix(tex_color.rgb, vec3(luma), desaturation);

	// 2. Tint toward slate (shadows) and teal (midtones)
	vec3 split_tint = mix(tint_slate * 1.8, tint_teal * 2.2, smoothstep(0.25, 0.65, luma));
	graded = mix(graded, graded * split_tint, tint_amount);

	// 3. Dithered vignette
	vec2 uv_offset = (UV - vec2(0.5)) * vec2(1.0, 0.5625);
	float dist = length(uv_offset);
	float vig = smoothstep(vignette_radius - vignette_softness, vignette_radius, dist) * vignette_strength;
	// Ordered dither for vignette edge
	float dither_vig = step(b_val, vig) * vig;
	vec3 shadow_color = vec3(0.04, 0.06, 0.06); // Dark charcoal-slate
	graded = mix(graded, shadow_color, dither_vig);

	// 4. Faint pixel-dither overlay (~2.5% subtle filmic texture)
	float faint_dither = (b_val - 0.5) * 0.035;
	graded += faint_dither;

	COLOR = vec4(clamp(graded, vec3(0.0), vec3(1.0)), tex_color.a * COLOR.a);
}
