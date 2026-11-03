extends SceneTree

const PlayerScript = preload("res://scripts/player.gd")
const MetaProgression = preload("res://scripts/meta_progression.gd")

func _init() -> void:
	print("[TEST] Testing Player stats and MetaProgression integration...")
	MetaProgression.perk_vitality_rank = 2
	MetaProgression.perk_stamina_rank = 1
	MetaProgression.perk_damage_rank = 1
	
	var player = PlayerScript.new()
	assert(player.get_max_hp() == 5 + 2, "Max HP should include vitality perk (+2)")
	assert(player.get_max_stamina() == 100.0 + 15.0, "Max Stamina should include stamina perk (+15)")
	assert(player.get_attack_damage_bonus() == 1, "Attack damage bonus should include damage perk (+1)")
	print("[TEST PASS] Player perks successfully applied! HP: %d, Stamina: %.1f, Bonus Dmg: %d" % [player.get_max_hp(), player.get_max_stamina(), player.get_attack_damage_bonus()])
	
	# Clean up
	MetaProgression.perk_vitality_rank = 0
	MetaProgression.perk_stamina_rank = 0
	MetaProgression.perk_damage_rank = 0
	player.free()
	quit(0)
