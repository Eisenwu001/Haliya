class_name LensRainOverlay
extends Control

# Camera lens droplets are deactivated to preserve clean 2D pixel-art aesthetics
var droplets: Array[Dictionary] = []
var is_active: bool = false
var intensity: float = 0.0

func _ready() -> void:
	set_anchors_preset(PRESET_FULL_RECT)
	mouse_filter = MOUSE_FILTER_IGNORE

func set_storm_active(active: bool, storm_intensity: float = 1.0) -> void:
	is_active = active
	intensity = storm_intensity
	clear_all_droplets()

func clear_all_droplets() -> void:
	for d in droplets:
		if d.has("sprite") and is_instance_valid(d["sprite"]):
			d["sprite"].queue_free()
	droplets.clear()

func _process(_delta: float) -> void:
	if not droplets.is_empty():
		clear_all_droplets()
