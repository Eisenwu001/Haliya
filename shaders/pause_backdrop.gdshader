shader_type canvas_item;

// pause_backdrop.gdshader
// Screen-reading backdrop shader for Haliya Pause Menu.
// Desaturates the frozen scene by 35% and overlays flat charcoal (#1e2420) at 65% opacity.

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest;

// Flat charcoal overlay (#1e2420 = rgb(0.117647, 0.141176, 0.12549)) at ~65% opacity
uniform vec4 overlay_color : source_color = vec4(0.117647, 0.141176, 0.12549, 0.65);
uniform float desaturation : hint_range(0.0, 1.0) = 0.35;

void fragment() {
	vec4 scn = texture(screen_texture, SCREEN_UV);
	float luma = dot(scn.rgb, vec3(0.299, 0.587, 0.114));

	// 1. Slight desaturation of the frozen game (~35%)
	vec3 desat = mix(scn.rgb, vec3(luma), desaturation);

	// 2. Flat dark charcoal overlay (~65% opacity)
	vec3 blended = mix(desat, overlay_color.rgb, overlay_color.a);

	COLOR = vec4(blended, 1.0);
}
