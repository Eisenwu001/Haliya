class_name UpgradeManager
extends RefCounted

## UpgradeManager
## Central singleton for Roguelite progression, upgrade drafting, and monster escalation.

const CATALOG: Dictionary = {
	"moonstone_vitality": {
		"id": "moonstone_vitality",
		"name": "Moonstone Vitality",
		"category": "CORE STAT",
		"icon": "❤",
		"icon_path": "res://assets/ui/icons/icon_vitality.png",
		"description": "+1 Max Health (up to 10). Instantly replenishes 1 vitality pip.",
		"max_stacks": 5,
		"rarity": "Common",
		"color": Color(0.35, 0.90, 0.50, 1.0)
	},
	"balaraw_edge": {
		"id": "balaraw_edge",
		"name": "Balaraw Edge",
		"category": "CORE STAT",
		"icon": "⚔",
		"icon_path": "res://assets/ui/icons/icon_damage.png",
		"description": "+1 Slash and Kick Attack Damage. Slices through demonic hides with lethal force.",
		"max_stacks": 3,
		"rarity": "Common",
		"color": Color(1.0, 0.45, 0.40, 1.0)
	},
	"breeze_of_mayon": {
		"id": "breeze_of_mayon",
		"name": "Breeze of Mayon",
		"category": "CORE STAT",
		"icon": "⚡",
		"icon_path": "res://assets/ui/icons/icon_stamina.png",
		"description": "+35% Stamina Regen Rate and -25% Dodge Stamina Drain.",
		"max_stacks": 3,
		"rarity": "Common",
		"color": Color(0.95, 0.85, 0.35, 1.0)
	},
	"amihan_swiftness": {
		"id": "amihan_swiftness",
		"name": "Amihan's Swiftness",
		"category": "CORE STAT",
		"icon": "🍃",
		"icon_path": "res://assets/ui/icons/icon_swiftness.png",
		"description": "+16% Movement & Dash Speed. Grants fluid agile evasion across treacherous terrain.",
		"max_stacks": 3,
		"rarity": "Common",
		"color": Color(0.40, 0.85, 0.95, 1.0)
	},
	"lunar_aegis": {
		"id": "lunar_aegis",
		"name": "Lunar Aegis",
		"category": "CORE STAT",
		"icon": "🛡",
		"icon_path": "res://assets/ui/icons/icon_aegis.png",
		"description": "Guarding negates 100% chip damage. Parry window extended by +0.05s.",
		"max_stacks": 1,
		"rarity": "Rare",
		"color": Color(0.80, 0.80, 1.0, 1.0)
	},
	"vampiric_riposte": {
		"id": "vampiric_riposte",
		"name": "Vampiric Riposte",
		"category": "BLESSING",
		"icon": "🩸",
		"icon_path": "res://assets/ui/icons/icon_riposte.png",
		"description": "Executing a Perfect Parry or Riposte countersiphon restores 1 full HP pip.",
		"max_stacks": 1,
		"rarity": "Legendary",
		"color": Color(1.0, 0.25, 0.60, 1.0)
	},
	"lunar_shockwave": {
		"id": "lunar_shockwave",
		"name": "Lunar Shockwave",
		"category": "BLESSING",
		"icon": "🌙",
		"icon_path": "res://assets/ui/icons/icon_shockwave.png",
		"description": "Combo finisher and flying kick loose a piercing crescent wave (2 dmg, 220px reach).",
		"max_stacks": 2,
		"rarity": "Rare",
		"color": Color(0.65, 0.85, 1.0, 1.0)
	},
	"ghost_dash": {
		"id": "ghost_dash",
		"name": "Ghost Dash",
		"category": "BLESSING",
		"icon": "👻",
		"icon_path": "res://assets/ui/icons/icon_ghost_dash.png",
		"description": "Dodge leaves a silver spectral afterimage that damages (1 dmg) and staggers foes.",
		"max_stacks": 1,
		"rarity": "Rare",
		"color": Color(0.85, 0.70, 1.0, 1.0)
	},
	"eclipse_pogo": {
		"id": "eclipse_pogo",
		"name": "Eclipse Pogo",
		"category": "BLESSING",
		"icon": "💫",
		"icon_path": "res://assets/ui/icons/icon_eclipse_pogo.png",
		"description": "Air downward slash pogo generates a radial lunar pulse (2 dmg, 80px) and leaps higher.",
		"max_stacks": 1,
		"rarity": "Rare",
		"color": Color(1.0, 0.80, 0.35, 1.0)
	},
	"bathalas_aegis": {
		"id": "bathalas_aegis",
		"name": "Bathala's Aegis",
		"category": "DEFENSIVE",
		"icon": "🛡",
		"icon_path": "res://assets/ui/icons/icon_aegis.png",
		"description": "+1 Maximum Armor shield capacity. Instantly replenishes 1 armor ward.",
		"max_stacks": 3,
		"rarity": "Rare",
		"color": Color(0.85, 0.70, 0.25, 1.0)
	},
	"celestial_respite": {
		"id": "celestial_respite",
		"name": "Celestial Respite",
		"category": "DEFENSIVE",
		"icon": "⏳",
		"icon_path": "res://assets/ui/icons/icon_stamina.png",
		"description": "Reduces armor shield regeneration delay from 3.0s down to 2.0s.",
		"max_stacks": 1,
		"rarity": "Uncommon",
		"color": Color(0.40, 0.75, 1.0, 1.0)
	},
	"iron_constitution": {
		"id": "iron_constitution",
		"name": "Iron Constitution",
		"category": "STAMINA",
		"icon": "⚡",
		"icon_path": "res://assets/ui/icons/icon_stamina.png",
		"description": "Reduces stamina exhaustion lockout from 2.0s to 1.3s, and exhaustion slow duration from 1.0s to 0.5s.",
		"max_stacks": 1,
		"rarity": "Uncommon",
		"color": Color(1.0, 0.65, 0.20, 1.0)
	},
	"parry_fortification": {
		"id": "parry_fortification",
		"name": "Bulawan Ward",
		"category": "DEFENSIVE",
		"icon": "✨",
		"icon_path": "res://assets/ui/icons/icon_riposte.png",
		"description": "Performing a perfect parry instantly restores +1 armor ward.",
		"max_stacks": 1,
		"rarity": "Rare",
		"color": Color(0.95, 0.85, 0.35, 1.0)
	}
}

# ── Active Run State ───────────────────────────────────────────────────────────
static var current_tier: int = 1
static var loop_count: int = 1
static var active_upgrades: Dictionary = {} # id -> int stacks
static var total_kills_this_run: int = 0
static var levels_cleared_this_run: int = 0
static var run_start_time_msec: int = 0
static var deepest_level_title: String = "Level 1-1"


static func init_run() -> void:
	current_tier = 1
	loop_count = 1
	active_upgrades.clear()
	total_kills_this_run = 0
	levels_cleared_this_run = 0
	run_start_time_msec = Time.get_ticks_msec()
	deepest_level_title = "Level 1-1"


static func reset_run() -> void:
	init_run()


static func has_upgrade(id: String) -> bool:
	return active_upgrades.get(id, 0) > 0


static func get_upgrade_stacks(id: String) -> int:
	return active_upgrades.get(id, 0)


static func draft_upgrades(count: int = 3) -> Array[Dictionary]:
	var eligible: Array[Dictionary] = []
	for key in CATALOG.keys():
		var info = CATALOG[key].duplicate()
		var cur_stacks = active_upgrades.get(key, 0)
		if cur_stacks < info["max_stacks"]:
			info["current_stacks"] = cur_stacks
			eligible.append(info)
	
	eligible.shuffle()
	
	var drafted: Array[Dictionary] = []
	for i in range(mini(count, eligible.size())):
		drafted.append(eligible[i])
	return drafted


static func apply_upgrade(id: String, player: CharacterBody2D = null) -> void:
	if not CATALOG.has(id):
		return
	
	var cur_stacks = active_upgrades.get(id, 0)
	active_upgrades[id] = cur_stacks + 1
	
	if is_instance_valid(player):
		sync_player_stats(player)
		# Immediate effect for Moonstone Vitality: replenish 1 HP
		if id == "moonstone_vitality" and player.has_method("heal"):
			player.heal(1)
		# Immediate effect for Bathala's Aegis: replenish 1 Armor
		if id == "bathalas_aegis":
			player.set("current_armor", mini(int(player.get("current_armor")) + 1, int(player.call("get_max_armor"))))
			if player.has_signal("armor_changed"):
				player.emit_signal("armor_changed", player.get("current_armor"), player.call("get_max_armor"))


static func sync_player_stats(player: CharacterBody2D) -> void:
	if not is_instance_valid(player):
		return
	
	# 1. Moonstone Vitality: +1 Max HP per stack
	var hp_stacks = get_upgrade_stacks("moonstone_vitality")
	player.set("bonus_max_hp", hp_stacks)
	
	# 2. Bathala's Aegis: +1 Max Armor per stack
	var armor_stacks = get_upgrade_stacks("bathalas_aegis")
	player.set("bonus_max_armor", armor_stacks)
	if player.has_method("refresh_max_stats"):
		player.refresh_max_stats()
	
	# 3. Balaraw Edge: +1 attack damage per stack
	var edge_stacks = get_upgrade_stacks("balaraw_edge")
	player.set("bonus_attack_damage", edge_stacks)
	
	# 4. Breeze of Mayon: +35% stamina regen, -25% dash stamina cost
	var breeze_stacks = get_upgrade_stacks("breeze_of_mayon")
	player.set("stamina_regen_bonus", breeze_stacks * 0.35)
	player.set("dodge_cost_reduction", breeze_stacks * 0.25)
	
	# 5. Amihan's Swiftness: +16% move & dash speed per stack
	var swift_stacks = get_upgrade_stacks("amihan_swiftness")
	player.set("move_speed_multiplier", 1.0 + (swift_stacks * 0.16))
	
	# 6. Lunar Aegis: 100% chip negation, +0.05s parry window
	player.set("has_lunar_aegis", has_upgrade("lunar_aegis"))
	
	# 7. Combat Blessings & Defense Upgrades
	player.set("has_vampiric_riposte", has_upgrade("vampiric_riposte"))
	player.set("has_lunar_shockwave", has_upgrade("lunar_shockwave"))
	player.set("lunar_shockwave_stacks", get_upgrade_stacks("lunar_shockwave"))
	player.set("has_ghost_dash", has_upgrade("ghost_dash"))
	player.set("has_eclipse_pogo", has_upgrade("eclipse_pogo"))
	player.set("has_celestial_respite", has_upgrade("celestial_respite"))
	player.set("has_iron_constitution", has_upgrade("iron_constitution"))
	player.set("has_parry_fortification", has_upgrade("parry_fortification"))


static func advance_tier(level_title: String = "") -> void:
	current_tier += 1
	levels_cleared_this_run += 1
	if level_title != "":
		deepest_level_title = level_title


static func begin_new_loop() -> void:
	loop_count += 1
	current_tier += 4 # Significant escalation jump on NG+


# ── Monster Escalation Multipliers ───────────────────────────────────────────
static func get_enemy_hp_multiplier() -> float:
	# Escalates by +14% per cleared stage, +75% per NG+ loop
	var base_mult = 1.0 + (current_tier - 1) * 0.14
	var loop_mult = (loop_count - 1) * 0.75
	return base_mult + loop_mult


static func get_enemy_speed_multiplier() -> float:
	# Caps at +30% maximum speed to preserve fair read telegraphs
	var speed_boost = minf(0.30, (current_tier - 1) * 0.025 + (loop_count - 1) * 0.15)
	return 1.0 + speed_boost


static func get_extra_spawn_count() -> int:
	# Extra patrol enemies sprinkled along the 5120px terrain
	if current_tier <= 2:
		return 0
	elif current_tier <= 5:
		return 1 + (loop_count - 1) * 2
	elif current_tier <= 9:
		return 2 + (loop_count - 1) * 2
	else:
		return 3 + (loop_count - 1) * 3


static func get_elite_chance() -> float:
	# Chance for any non-boss enemy to mutate into Corrupted Elite
	if current_tier <= 1:
		return 0.0 # No elites on first stage
	var chance = 0.12 + (current_tier - 1) * 0.03 + (loop_count - 1) * 0.20
	return clampf(chance, 0.0, 0.65)
