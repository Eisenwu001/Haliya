class_name EnemyHealthPips
extends Node2D

const PIP_WIDTH: float = 7.0
const PIP_HEIGHT: float = 4.0
const PIP_GAP: float = 3.0

var max_hp: int = 3
var current_hp: int = 3
var is_vulnerable: bool = false
var fade_timer: float = 0.0
var pulse_time: float = 0.0

func _ready() -> void:
	z_index = 40
	modulate.a = 0.0 # Initially hidden until engaged or damaged

func update_health(cur: int, max_val: int, vulnerable: bool = false) -> void:
	current_hp = clampi(cur, 0, max_val)
	max_hp = maxi(max_val, 1)
	is_vulnerable = vulnerable
	fade_timer = 4.0
	modulate.a = 1.0
	queue_redraw()

func set_vulnerable(vulnerable: bool) -> void:
	is_vulnerable = vulnerable
	if is_vulnerable:
		fade_timer = 4.0
		modulate.a = 1.0
	queue_redraw()

func _process(delta: float) -> void:
	if is_vulnerable and modulate.a > 0.05:
		pulse_time += delta * 12.0
		queue_redraw()
	
	if fade_timer > 0.0:
		fade_timer -= delta
		if fade_timer <= 0.8:
			modulate.a = clampf(fade_timer / 0.8, 0.0, 1.0)
		else:
			modulate.a = 1.0
	elif modulate.a > 0.0:
		modulate.a = 0.0
		queue_redraw()

func _draw() -> void:
	if modulate.a <= 0.01:
		return
		
	var total_w = max_hp * PIP_WIDTH + (max_hp - 1) * PIP_GAP
	var start_x = -total_w * 0.5
	
	for i in range(max_hp):
		var x = start_x + i * (PIP_WIDTH + PIP_GAP)
		var pip_rect = Rect2(x, -PIP_HEIGHT * 0.5, PIP_WIDTH, PIP_HEIGHT)
		
		# Background/Border
		draw_rect(pip_rect.grow(1.0), Color(0.04, 0.04, 0.05, 0.95), true)
		
		if i < current_hp:
			if is_vulnerable:
				# Pulsing luminous gold for riposte opening
				var glow = 0.75 + 0.25 * sin(pulse_time)
				var gold_col = Color(1.0 * glow, 0.85 * glow, 0.2 * glow, 1.0)
				draw_rect(pip_rect, gold_col, true)
			else:
				# Resilient dark crimson fill
				draw_rect(pip_rect, Color(0.88, 0.16, 0.16, 1.0), true)
				# 1px top highlight
				draw_line(Vector2(x, -PIP_HEIGHT * 0.5), Vector2(x + PIP_WIDTH, -PIP_HEIGHT * 0.5), Color(1.0, 0.45, 0.45, 0.8), 1.0)
		else:
			# Depleted hollow pip
			draw_rect(pip_rect, Color(0.18, 0.08, 0.08, 0.6), true)
