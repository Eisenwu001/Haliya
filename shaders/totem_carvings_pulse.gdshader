shader_type canvas_item;
render_mode blend_mix;

// Glowing carvings shader for HALIYA Totem
// Pulses a subtle muted teal (#3f6b66) on the totem's lighter chiseled patterns.
// Keeps the original artwork completely intact.

uniform vec4 pulse_color : source_color = vec4(0.247, 0.420, 0.400, 1.0); // Muted teal #3f6b66
uniform float pulse_intensity : hint_range(0.0, 1.0) = 0.25;             // Max 25% intensity
uniform float pulse_speed : hint_range(0.1, 5.0) = 1.047;                 // 2 * PI / 6.0 ~= 1.047 (6-second period)
uniform float lum_threshold : hint_range(0.0, 1.0) = 0.38;               // Lighter chiseled patterns
uniform bool reduce_motion = false;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	if (tex.a < 0.1) {
		COLOR = vec4(0.0);
	} else {
		float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
		if (lum > lum_threshold) {
			float wave = 0.0;
			if (!reduce_motion) {
				// Sine wave smoothly oscillating between 0.0 and 1.0 over 6 seconds
				wave = (sin(TIME * pulse_speed) + 1.0) * 0.5;
			}
			float strength = wave * pulse_intensity; // 0.0 to 0.25
			// Gently tint lighter carved patterns with teal
			vec3 blended = mix(tex.rgb, pulse_color.rgb, strength);
			COLOR = vec4(blended, tex.a);
		} else {
			COLOR = tex;
		}
	}
}
