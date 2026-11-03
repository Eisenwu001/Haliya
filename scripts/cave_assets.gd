class_name CaveAssets
extends RefCounted

const ROCK_TILES_PATH := "res://assets/cave_platformer/cave_rock_tiles.png"
const PLATFORMS_PATH := "res://assets/cave_platformer/cave_platforms.png"
const PROPS_PATH := "res://assets/cave_platformer/cave_props.png"
const TILESET_ATLAS_PATH := "res://assets/cave_platformer/cave_tileset_atlas.png"
const CEILING_PATH := "res://assets/cave_platformer/cavern_ceiling_modular.png"
const POGO_STALACTITE_PATH := "res://assets/cave_platformer/pogo_stalactite_resonant.png"
const STRUT_PATH := "res://assets/cave_platformer/plat_basalt_strut.png"
const VIGNETTE_PATH := "res://assets/vfx/cave_dark_vignette.png"

static var _cached_rock_tiles: Texture2D = null
static var _cached_platforms: Texture2D = null
static var _cached_props: Texture2D = null
static var _cached_tileset_atlas: Texture2D = null
static var _cached_ceiling: Texture2D = null
static var _cached_pogo_stalactite: Texture2D = null
static var _cached_strut: Texture2D = null
static var _cached_vignette: Texture2D = null


static func _load_png_reliable(res_path: String) -> Texture2D:
	var abs_path := ProjectSettings.globalize_path(res_path)
	if FileAccess.file_exists(abs_path):
		var img := Image.load_from_file(abs_path)
		if img and not img.is_empty():
			var tex := ImageTexture.create_from_image(img)
			tex.resource_name = res_path
			return tex
	if ResourceLoader.exists(res_path):
		var loaded = load(res_path)
		if loaded is Texture2D:
			return loaded
	return null


static func get_rock_tiles_tex() -> Texture2D:
	if _cached_rock_tiles == null:
		_cached_rock_tiles = _load_png_reliable(ROCK_TILES_PATH)
	return _cached_rock_tiles


static func get_platforms_tex() -> Texture2D:
	if _cached_platforms == null:
		_cached_platforms = _load_png_reliable(PLATFORMS_PATH)
	return _cached_platforms


static func get_props_tex() -> Texture2D:
	if _cached_props == null:
		_cached_props = _load_png_reliable(PROPS_PATH)
	return _cached_props


static func get_tileset_atlas_tex() -> Texture2D:
	if _cached_tileset_atlas == null:
		_cached_tileset_atlas = _load_png_reliable(TILESET_ATLAS_PATH)
	return _cached_tileset_atlas


static func get_ceiling_tex() -> Texture2D:
	if _cached_ceiling == null:
		_cached_ceiling = _load_png_reliable(CEILING_PATH)
	return _cached_ceiling


static func get_pogo_stalactite_tex() -> Texture2D:
	if _cached_pogo_stalactite == null:
		_cached_pogo_stalactite = _load_png_reliable(POGO_STALACTITE_PATH)
	return _cached_pogo_stalactite


static func get_strut_tex() -> Texture2D:
	if _cached_strut == null:
		_cached_strut = _load_png_reliable(STRUT_PATH)
	return _cached_strut


static func get_vignette_tex() -> Texture2D:
	if _cached_vignette == null:
		_cached_vignette = _load_png_reliable(VIGNETTE_PATH)
	return _cached_vignette


