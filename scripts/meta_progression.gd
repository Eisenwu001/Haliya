class_name MetaProgression
extends RefCounted

## MetaProgression
## Manages persistent meta-currency (Moon Pearls), permanent ancestral blessings, and lore codex.

const META_SAVE_PATH: String = "user://haliya_meta.cfg"

static var moon_pearls: int = 0
static var total_pearls_ever: int = 0
static var unlocked_bestiary: Dictionary = {}

# All perks removed - stats remain pure baseline
static var perk_vitality_rank: int = 0
static var perk_stamina_rank: int = 0
static var perk_damage_rank: int = 0
static var perk_fortune_rank: int = 0

const BESTIARY_DATA: Dictionary = {
	"aswang": {
		"name": "Aswang (Ghoulish Stalker)",
		"baybayin": "ᜀᜐ᜔ᜏᜅ᜔",
		"lore": "Nocturnal winged prowler of the Bicol forest canopy, ravenous for the blood of travelers traversing the moonlit paths."
	},
	"corrupted_farmer": {
		"name": "Corrupted Farmer (Magbubukid)",
		"baybayin": "ᜋᜄ᜔ᜊᜓᜊᜓᜃᜒᜇ᜔",
		"lore": "A gentle rice grower twisted by the dark miasma weeping from Mount Mayon's fissures during the eclipse of the sixth moon."
	},
	"skeleton": {
		"name": "Runic Skeleton (Bungo)",
		"baybayin": "ᜊᜓᜅᜓ",
		"lore": "Ancient terracotta guard animated by subterranean lapis crystal frequencies within the cavern depths."
	},
	"santelmo": {
		"name": "Santelmo (Spiritual St. Elmo's Fire)",
		"baybayin": "ᜐᜈ᜔ᜆᜒᜎ᜔ᜋᜓ",
		"lore": "Dancing spheres of spirit fire born from souls adrift in flooded rice terraces. Can be deflected and extinguished with a precise parry."
	},
	"forest_brute": {
		"name": "Forest Brute (Higanteng Gubat)",
		"baybayin": "ᜑᜒᜄᜈ᜔ᜆᜒ",
		"lore": "A colossal sentinel wielding an ancient uprooted balete limb, guarding the sentry ridge before the emerald terraces."
	},
	"mayon_vanguard": {
		"name": "Mayon Vanguard (Bantay ng Mayon)",
		"baybayin": "ᜊᜈ᜔ᜆᜌ᜔",
		"lore": "An elite spear-bearer sworn to protect the sacred crossing beneath the volcano, armored in volcanic basalt and tempered bronze."
	},
	"sinag_ulap": {
		"name": "Sinag-Ulap (The Corrupted Matriarch)",
		"baybayin": "ᜐᜒᜈᜄ᜔ ᜂᜎᜉ᜔",
		"lore": "Matriarch of the tempest storm in the rainforest canopy, commanding torrents of rain, phantom bat swarms, and shadow dives."
	},
	"bakunawa": {
		"name": "Bakunawa (The Moon Devourer)",
		"baybayin": "ᜊᜃᜓᜈᜏ",
		"lore": "The primordial leviathan serpent of the abyssal trenches that swallowed the six sacred moons, plunging Ibalong into shadow."
	}
}


static func load_meta() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(META_SAVE_PATH) == OK:
		moon_pearls = int(cfg.get_value("currency", "moon_pearls", 0))
		total_pearls_ever = int(cfg.get_value("currency", "total_pearls", 0))
		unlocked_bestiary = cfg.get_value("lore", "bestiary", {})
	perk_vitality_rank = 0
	perk_stamina_rank = 0
	perk_damage_rank = 0
	perk_fortune_rank = 0


static func save_meta() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("currency", "moon_pearls", moon_pearls)
	cfg.set_value("currency", "total_pearls", total_pearls_ever)
	cfg.set_value("lore", "bestiary", unlocked_bestiary)
	cfg.save(META_SAVE_PATH)


static func get_moon_pearls() -> int:
	return moon_pearls


static func add_moon_pearls(amount: int) -> void:
	moon_pearls += amount
	total_pearls_ever += amount
	save_meta()


static func spend_moon_pearls(amount: int) -> bool:
	if moon_pearls >= amount:
		moon_pearls -= amount
		save_meta()
		return true
	return false


static func unlock_bestiary(creature_id: String) -> void:
	if BESTIARY_DATA.has(creature_id) and not unlocked_bestiary.get(creature_id, false):
		unlocked_bestiary[creature_id] = true
		save_meta()
