shader_type canvas_item;

uniform float wind_speed : hint_range(0.1, 5.0) = 1.6;
uniform float wind_strength : hint_range(0.0, 30.0) = 4.0;
uniform float wind_detail : hint_range(0.5, 10.0) = 2.0;

void vertex() {
	// Trees and rice stalks are anchored at bottom (UV.y = 1.0), so top (UV.y = 0.0) sways maximum
	float world_x = MODEL_MATRIX[3].x;
	float sway_factor = pow(clamp(1.0 - UV.y, 0.0, 1.0), 1.2);
	float wave = sin(TIME * wind_speed + (world_x + VERTEX.x) * 0.015) 
	           + 0.35 * sin(TIME * wind_speed * wind_detail + (world_x + VERTEX.x) * 0.035);
	VERTEX.x += wave * wind_strength * sway_factor;
}
