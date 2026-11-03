# Haliya: Mask of Sorrows — Agent Handout & Polish Reference

> **Status**: All Polish Phases, the **Hardcore Attrition & No Health Regen Overhaul**, **Stage 2 Rice Field Visual/Mechanical Redesign** (detailed AI-generated puddles & palay stalks, removal of houses/flumes, stone pilapil dikes, mud suction physics), and **18-Level Stage Expansion** are **COMPLETED & TESTED**.
> This document serves as the living architectural & asset reference so any agent or developer can continue expanding or tuning the game without rediscovering asset coordinates or scene wiring.

---

## 1. Project Architecture Overview

- **Engine**: Godot 4.7 (`640×360` viewport, `canvas_items` stretch mode, pixel-art + dynamic `PointLight2D` / `CanvasModulate` lighting).
- **Godot Executable Path**: `C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe`.
- **Entry Scene**: [`scenes/ui/main_menu.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/ui/main_menu.tscn) ([`scripts/main_menu.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main_menu.gd)) -> launches [`scenes/main.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/main.tscn) ([`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd)).
- **18-Stage Progression (`LEVELS_DATA` in [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd#L17-L109))**:
  - **Idx 0–2 (`Forest`)**: `level_1_1.tscn`, `level_1_2.tscn`, `level_1_3.tscn` (Miniboss: [`ForestBruteMiniboss`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/forest_brute_miniboss.gd)).
  - **Idx 3–5 (`Rice Field`)**: `level_2_1.tscn`, `level_2_2.tscn`, `level_2_3.tscn` (Miniboss: [`MayonVanguardMiniboss`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/mayon_vanguard_miniboss.gd)). Detailed reference: [Stage 2 Rice Field Polish Handout](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/docs/RICE_FIELD_POLISH_HANDOUT.md).
  - **Idx 6–10 (`Rainy Forest`)**: `level_3_1.tscn` .. `level_3_5.tscn` (Boss at `3-5`: [`AswangBoss`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/aswang_boss.gd) — *Sinag-Ulap, The Corrupted Matriarch*).
  - **Idx 11 (`Cave`)**: [`scenes/cave/level_4.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/cave/level_4.tscn) (*The Lapis Depths* — Full Hollow Knight multi-tiered platforming gauntlet).
  - **Idx 12 (`Cave Boss`)**: [`scenes/cave/level_5.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/cave/level_5.tscn) (*Bakunawa's Abyss* — Hollow Knight suspension ascent + multi-level boss sanctuary arena).

---

## 2. Hollow Knight Cave Platformer Architecture

### Dedicated Asset Pack (`assets/cave_platformer/`)

1. **`cave_rock_tiles.png` (`256×128`)**:
   - `Rect2(0, 0, 32, 32)`: Chiseled slate top-left edge cap with runic runes.
   - `Rect2(32, 0, 32, 32)`: Chiseled slate top-middle surface slab with glowing cyan rune inlays.
   - `Rect2(64, 0, 32, 32)`: Chiseled slate top-right edge cap.
   - `Rect2(128, 0, 128, 32)`: Chiseled masonry ashlar blocks (`32×32` alternating variations).
   - `Rect2(0, 32, 96, 32)`: Bedrock strata with embedded crystal veins.
   - `Rect2(0, 64, 96, 32)`: Tapered stalactite bottom edge / underbelly.
   - `Rect2(96, 0, 32, 96)`: Carved Ancient Ruin Pillar (capital, fluted runic shaft, plinth base).
2. **`cave_platforms.png` (`256×160`)**:
   - `Rect2(0, 0, 128, 64)` (`"island_lg"`): Large suspended cavern island with iron chain shackles and tapered stalactite underbelly with cyan crystal veins.
   - `Rect2(128, 0, 96, 56)` (`"island_md"`): Medium suspended cavern island.
   - `Rect2(0, 64, 128, 40)` (`"bridge"`): Ornate wrought-iron & carved stone ruin suspension bridge with gothic arch trusses.
   - `Rect2(128, 64, 96, 48)` (`"crumble"`): Crumbling ancient stone ledge with glowing violet-cyan fissures.
   - `Rect2(0, 104, 160, 56)` (`"sanctuary"`): Wide Boss Arena Sanctuary Platform with glowing cyan rune trim and dual chain shackles.
3. **`cave_props.png` (`256×160`)**:
   - `Rect2(0, 0, 64, 96)` (`"streetlamp"`): Hollow Knight-style Lumafly / Spirit Lantern Streetlamp with glowing glass cage.
   - `Rect2(64, 0, 32, 128)` (`"chain"`): Hanging wrought-iron chain with heavy iron links.
   - `Rect2(96, 0, 64, 48)` (`"pogo_crystal"`): Resonant Pogo Crystal Bloom with crystalline facets and floating orbital motes.
   - `Rect2(160, 0, 96, 32)` (`"spikes"`): Subterranean Crystal Spike Hazard Bed.
   - `Rect2(96, 48, 64, 112)` (`"lore_stele"`): Ancient Lunar Lore Stele / Soul Totem.
   - `Rect2(160, 32, 96, 128)` (`"ceiling_stalactite"`): Massive ceiling stalactite cluster.

### Interactive Gameplay Scripts

- [`CaveAssets`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/cave_assets.gd):
  - Provides cached `get_rock_tiles_tex()`, `get_platforms_tex()`, and `get_props_tex()` with reliable runtime `Image.load_from_file` fallback so textures display immediately even before editor `.ctex` import.
- [`CavePogoCrystal`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/cave_pogo_crystal.gd):
  - Group: `"pogo_crystals"`.
  - Resonant floating crystal bloom with cyan-magenta `PointLight2D` and rising ambient motes.
  - When struck with an aerial/ground attack in [`Player.check_attack_hit_enemies()`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/player.gd#L1323-L1338) or landed on while airborne, launches Haliya upward (`velocity.y = -465.0`), clears fall speed (`max_fall_velocity = 0.0`), restores `24.0` stamina, squashes/stretches elastically, flashes bright cyan-white, and bursts with crystal spark particles.
- [`CaveCrumbleLedge`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/cave_crumble_ledge.gd):
  - Suspended stone ledge that detects when the player lands on top.
  - Shudders horizontally for `0.60s` while shedding dust particles, collapses by disabling collision and fading downward, then reforms `2.2s` later with a cyan rune flash.
- [`CaveSpikeHazard`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/cave_spike_hazard.gd):
  - Subterranean crystal spike pit. When touched by the player, deals `1` damage and calls [`Player.respawn_at_safe_ledge()`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/player.gd#L1356-L1369), respawning Haliya onto the adjacent stone ledge rather than killing her immediately.
- [`Player`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/player.gd):
  - Implemented **Hollow Knight aerial slash pogo recoil**: striking any enemy or Bakunawa while airborne from above (`is_air_attack` and `dy > 8.0`) applies an upward bounce (`velocity.y = min(velocity.y, -335.0)`), allowing players to chain airborne slashes!

---

## 3. Level 4 & Level 5 Scene Breakdowns

### Level 4: The Lapis Depths ([`scenes/cave/level_4.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/cave/level_4.tscn))
- **5 Ground Segments**: `x = 0..864` (`y = 292`), `x = 1120..1920` (`y = 256`), `x = 2368..3232` (`y = 228`), `x = 3744..4320` (`y = 264`), `x = 4480..5120` (`y = 280`).
- **4 Crystal Spike Chasms**:
  - `x = 864..1120` (`w = 256`): Bridged by 2 Pogo Crystals (`x = 945, 1045`) + Upper Crumbling Ledge (`x = 880`).
  - `x = 1920..2368` (`w = 448`): The Crumbling Viaduct Gorge with 2 Crumbling Ledges (`x = 1970, 2190`) and 2 Pogo Crystals (`x = 2125, 2315`).
  - `x = 3232..3744` (`w = 512`): The Abyssal Pogo Ascent with mid-chasm Floating Island (`x = 3400`), Crumbling Ledge (`x = 3575`), and 2 Pogo Crystals (`x = 3325, 3695`).
  - `x = 4320..4480` (`w = 160`): Deep Sanctum Breach bridged by Wrought-Iron Bridge (`x = 4336`) and Pogo Crystal (`x = 4400`).
- **18 Elevated Platforms**: Mix of `island_lg`, `island_md`, `bridge`, and `crumble`.
- **7 Resonant Pogo Crystals**: Positioned over chasms for rhythmic aerial traversal.
- **Atmospheric Props**: 7 Lumafly Streetlamps, 4 Ancient Lunar Lore Steles, 6 Ceiling Stalactites, 6 Ores, 8 Torches, 5 Breakable Pots.

### Level 5: Bakunawa's Abyss ([`scenes/cave/level_5.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/cave/level_5.tscn))
- **Section 1: The Abyssal Ascent & Suspension Gauntlet (`x = 0..3750`)**:
  - 3 Ground Segments (`x = 0..928`, `x = 1184..2080`, `x = 2432..3328`) separated by 3 Spike Chasms (`x = 928..1184`, `x = 2080..2432`, `x = 3328..3520`).
  - Crossed by chain-suspended islands, wrought-iron bridges, crumbling ledges, and 3 pogo crystals.
  - **Ancestral Checkpoint Shrine**: Placed at `x = 3620.0, y = 280.0` on the solid pre-arena terrace with twin flanking Lumafly Streetlamps (`x = 3555`, `x = 3685`) and a healing/stamina Palayok Pot (`x = 3580`).
- **Section 2: Multi-Tiered Bakunawa Boss Arena (`x = 3760..5080`)**:
  - 5 Elevated Sanctuary Platforms:
    - Left Sanctuary Platform (`160×56`) at `x = 3900, y = 212` (reachable with a single jump!).
    - Left High Island (`96×56`) at `x = 4145, y = 156`.
    - Central Eclipse Sanctuary Bridge (`160×56`) at `x = 4340, y = 188` (directly under the Seventh Moon!).
    - Right High Island (`96×56`) at `x = 4595, y = 156`.
    - Right Sanctuary Platform (`160×56`) at `x = 4760, y = 212`.
  - **Twin Arena Flank Pogo Crystals**:
    - Left Arena Pogo Crystal at `x = 3825, y = 236`: allows immediate aerial launch to dodge Bakunawa's sweeping charge and strike from above.
    - Right Arena Pogo Crystal at `x = 4985, y = 236`: allows evasive aerial maneuvers on the right boundary.

---

---

## 4. Subterranean Dynamic Lighting & Atmospheric Architecture

- **Subterranean Ambient Modulate (`CanvasModulate`)**:
  - Sets deep moody indigo-slate ambient lighting: `Color(0.24, 0.34, 0.46, 1.0)` for Cave (*The Lapis Depths*) and `Color(0.20, 0.28, 0.40, 1.0)` for Cave Boss (*Bakunawa's Abyss*).
  - This replaces flat, washed-out grey ambient light and provides authentic metroidvania contrast where illuminated zones glow radiantly.
- **Haliya Spirit Lantern Light (`CaveSpiritLight`)**:
  - Automatically attached to the player upon entering any cave stage via `update_player_environment_lighting()` in [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd):
  - `PointLight2D` (`color = Color(0.58, 0.90, 1.0, 0.92)`, `energy = 0.95`, `texture_scale = 0.46`), casting a soft bioluminescent aura around Haliya that illuminates terrain, platforms, and enemies.
  - Automatically cleaned up when transitioning back to Forest or Rice Field stages.
- **Multi-Tier Lumafly Streetlamps**:
  - Inner Core Light positioned at `Vector2(12.0, -12.0)` inside the glass bell jar (`energy = 1.45`, `scale = 0.42`, `color = Color(0.42, 0.94, 1.0, 1.0)`) with smooth breathing sine pulse tween (`1.28` to `1.62`).
  - Outer Ambient Halo (`OuterHalo`) with soft falloff (`energy = 0.65`, `scale = 0.82`, `color = Color(0.12, 0.58, 0.88, 0.65)`).
  - Rising Lumafly sparkle particles (`LumaflyMotes`) hovering around the lantern housing.
- **Resonant Pogo Crystal Illumination**:
  - `PointLight2D` (`color = Color(0.35, 0.92, 1.0, 1.0)`, `energy = 1.35`, `texture_scale = 0.42`) with dynamic pulse oscillation (`1.02` to `1.58`) synchronized with floating bob movement, plus 12 glowing ambient motes.
- **Ancient Lunar Lore Steles**:
  - `PointLight2D` (`color = Color(0.28, 0.85, 1.0, 0.88)`, `energy = 0.85`, `scale = 0.36`) and ethereal rune shimmer tween.
- **Seventh Moon Eclipse Centerpiece (Level 5)**:
  - Dual celestial lighting: Core Eclipse Light (`energy = 1.35`, `scale = 0.95`, `color = Color(0.45, 0.82, 1.0, 1.0)`) plus wide ambient moonbeam aura (`MoonAmbientGlow`: `energy = 0.85`, `scale = 1.65`, `color = Color(0.28, 0.72, 1.0, 0.65)`) illuminating the entire boss sanctuary arena.

---

## 5. Verification & Testing Commands

To run headless validation of scenes, lighting, and integration scripts:
```powershell
# Run the automated Cave Visuals & Lighting verification suite
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless -s "res://scratch/test_cave_visuals_and_lighting.gd"

# Run the automated Rice Field integration & mechanics verification suite
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless --script scripts/test_rice_field_complete.gd

# Run the Rice Field animations and props audit suite
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless --script scratch/test_rice_field_animations_and_props.gd

# Validate Level 4 scene
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless "res://scenes/cave/level_4.tscn" --quit-after 50

# Validate Level 5 scene
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless "res://scenes/cave/level_5.tscn" --quit-after 50

# Validate full game loop
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless "res://scenes/main.tscn" --quit-after 60
```

---

## 6. Roguelite Progression & Monster Escalation System

### Overview
- **Progression Trigger**: At the conclusion of each cleared stage, the **Ancestral Lunar Shrine** ([`scripts/upgrade_select_ui.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/upgrade_select_ui.gd)) drafts 3 random blessings from [`UpgradeManager`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/upgrade_manager.gd).
- **Core RPG Stats**:
  - `moonstone_vitality`: +1 Max HP (and heals 1 HP immediately).
  - `balaraw_edge`: +1 Slash & Kick attack damage.
  - `breeze_of_mayon`: +35% Stamina Regen Rate & -25% Dodge Stamina Drain.
  - `amihan_swiftness`: +16% Movement & Dash Speed.
  - `lunar_aegis`: Guarding completely negates chip damage; +0.05s parry window.
- **Combat Blessings**:
  - `vampiric_riposte`: Executing a Perfect Parry or Riposte countersiphon restores 1 full HP.
  - `lunar_shockwave`: Heavy combo finisher & flying kick loose a piercing crescent energy wave ([`scripts/lunar_shockwave.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/lunar_shockwave.gd)).
  - `ghost_dash`: Dashing leaves behind a silver spectral afterimage ([`scripts/ghost_dash_decoy.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/ghost_dash_decoy.gd)) that shocks passing enemies for 1 damage and staggers them.
  - `eclipse_pogo`: Downward slash pogo bounce generates a radial lunar pulse (2 dmg, 80px) and catapults Haliya higher.
- **Dynamic Monster Horde Escalation**:
  - **Horde Density**: `UpgradeManager.get_extra_spawn_count()` spawns extra patrol packs along the 5120px terrain (+25% to +50% monster density).
  - **Health Scaling**: Enemy base HP scales progressively (`+14%` per stage tier).
  - **Corrupted Elites**: 20% to 45% of monsters mutate into Corrupted Elites with an eerie dark crimson/violet lunar aura, +50% HP, +20% move speed, and rapid aggression.
- **Classic Permadeath Loop**:
  - Upon falling in battle (`HP <= 0`), [`GameOverUI`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/game_over_ui.gd) displays run statistics (Deepest Realm, Blessings Acquired, Nightmares Vanquished, Survival Time).
  - Choosing **"Rise Again"** resets upgrades, clears ascension tier, and restarts fresh at Level 1-1.
- **Endless Loop / New Game+**:
  - Conquering Bakunawa (Level 5) offers **"The Infinite Eclipse (Loop 2+)"**, carrying over all acquired upgrades while enemy density and lethality jump significantly.

### Automated Test Command
```powershell
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless --script scripts/test_progression_system.gd
```


---

## 7. Cultural Features, Baybayin System, Authentic Audio, Game Settings & Meta-Progression

### 1. Baybayin Typography & Animated Translation System
- **Font**: [`assets/fonts/NotoSansTagalog-Regular.ttf`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/fonts/NotoSansTagalog-Regular.ttf) (SIL Open Font License, all 23 historical Unicode glyphs `U+1700..U+171F`).
- **Transliterator Engine**: [`scripts/baybayin_text.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/baybayin_text.gd):
  - Pre-colonial Filipino dictionary mappings (e.g. *Haliya* -> `ᜑᜎᜒᜌ`, *Bakunawa* -> `ᜊᜃᜓᜈᜏ`, *Bahay Kubo* -> `ᜊᜑᜌ᜔ ᜃᜓᜊᜓ`, *Berdeng Palayan* -> `ᜊᜒᜇ᜔ᜇᜒ ᜉᜎᜌᜈ᜔`).
  - Algorithmic syllable-parser parsing Tagalog syllables into base characters + *kudlit* diacritics + *virama* vowel-killers.
- **Animated Component**: [`scripts/baybayin_label.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/baybayin_label.gd):
  - `play_decode_sequence(english_str, custom_baybayin, font_size_en)`:
    - Phase 1: Radiant golden Baybayin runes burst into view with luminous celestial moonlight.
    - Phase 2: Dramatic rune pause while the runes pulse.
    - Phase 3: English title text smoothly decodes beneath while runes recede into an ancient celestial header.
  - Deployed in: Main Menu title header, Step 3 Press Start screen, Area Discovery Banners across all stages ([`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd)), Act 1 Bahay Kubo Hub ([`scripts/act1_bahay_kubo.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/act1_bahay_kubo.gd)), and the Lore Codex.

### 2. Authentic Philippine Kulintang Archival Music
- **Archival Master Recordings** (Curated from World Kulintang Institute archives):
  - **Exploration & Homestead BGM**: [`assets/audio/music/kulintang_exploration.mp3`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/audio/music/kulintang_exploration.mp3) (Traditional *Binalig* piece, 109s loop, melodic gongs, dabakan, and agung).
  - **Battle & Climax BGM**: [`assets/audio/music/kulintang_battle.mp3`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/audio/music/kulintang_battle.mp3) (Traditional *Tidtu* piece, 109s loop, fast rhythmic ceremonial tempo).
- **Dynamic Manager Hooks**: [`scripts/procedural_audio.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/procedural_audio.gd):
  - `get_kulintang_exploration_bgm()`: automatically streamed in Main Menu, Act 1 Hub, and Rice Field levels.
  - `get_kulintang_battle_bgm()`: automatically streamed during boss battles and intense climaxes.

### 3. Settings & Options Infrastructure
- **Settings Manager**: [`scripts/game_settings.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/game_settings.gd):
  - Master, Music, and SFX volume sliders connected directly to Godot's `AudioServer` buses with logarithmic decibel conversion (`linear_to_db`).
  - Screen Shake intensity slider (`0%` to `200%`, scaling all camera trauma in [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd)).
  - Fullscreen toggle (`DisplayServer.window_set_mode`), floating damage numbers toggle, and language selector.
  - Persistent save/load via `user://game_settings.cfg`.
- **Settings Modal UI**: [`scripts/settings_menu.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/settings_menu.gd):
  - Styled dark fantasy dialog with Baybayin runic header `✦ ᜉᜄ᜔ᜉᜒᜉᜒᜎᜒ ✦` (*Pagpipili* / Options).
  - Accessible from the Main Menu ("SETTINGS") and in-game Pause Menu ([`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd)).

### 4. New Mythological Enemy: Santelmo (St. Elmo's Fire)
- **Asset**: [`assets/enemies/santelmo_spritesheet.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/enemies/santelmo_spritesheet.png) (6-frame `48×48` dancing ethereal flame sprite).
- **Behavior & Combat**: [`scripts/santelmo.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/santelmo.gd):
  - Sinusoidal floating patrol above terraces and flooded waters.
  - Cyan `PointLight2D` casting a dynamic light aura.
  - **Flame Flare Attack**: Telegraphs by glowing white-hot, then bursts with flame damage.
  - **Pogo & Parry Interactions**: Striking from above executes a Hollow Knight-style aerial slash bounce; executing a perfect parry instantly extinguishes and deflects the spirit!
  - **Drops**: Always drops iridescent **Moon Pearls** upon defeat.
  - Naturally spawned in Rice Field stages (Levels 3..5) and Subterranean Ravines.

### 5. Meta-Progression & Hub (The Bahay Kubo Homestead)
- **Currency (Moon Pearls)**: [`assets/props/pickup_moon_pearl.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/props/pickup_moon_pearl.png) (24×24 iridescent lunar pearl). Earned by vanquishing foes and clearing realms.
- **Progression Persistence**: [`scripts/meta_progression.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/meta_progression.gd) (persists to `user://meta_progression.cfg`).
- **Ancestral Altar Perks**:
  - `Vitality Blessing`: +1 Permanent Starting Max HP per rank (Rank 1..3).
  - `Stamina Reservoir`: +15 Permanent Starting Max Stamina per rank (Rank 1..3).
  - `Sharp Moonblade`: +1 Permanent Base Attack Damage per rank (Rank 1..2).
  - `Fortune's Shimmer`: +25% Moon Pearl Drops from foes per rank (Rank 1..3).
  - Dynamically wired into [`Player.get_max_hp()`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/player.gd), [`Player.get_max_stamina()`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/player.gd), and attack calculations.
- **Mythological Lore Bestiary Codex**: [`scripts/bestiary_codex_ui.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/bestiary_codex_ui.gd):
  - 8 Authentic Philippine mythological entries (*Aswang*, *Manananggal*, *Tikbalang*, *Santelmo*, *Sigbin*, *Corrupted Farmer*, *Mayon Vanguard*, *Bakunawa*).
  - Entries unlock permanently when the player defeats each creature in combat.
  - Features Baybayin headers, English names, and rich dark fantasy folklore descriptions.
  - Accessible via Main Menu ("LORE CODEX & ALTAR"), Pause Menu, and communion with the Ancestral Altar in the Bahay Kubo Hub.

### Automated Test Command
```powershell
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless --script scripts/test_cultural_and_settings_features.gd
```

### 6. Aesthetic Polish, Unified Alagard Typography & 32x32 Relic Icons (Latest Update)
- **Modal Centering Fix**: Resolved offset bug in [`scripts/settings_menu.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/settings_menu.gd) and [`scripts/bestiary_codex_ui.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/bestiary_codex_ui.gd) by setting anchor presets and symmetrical negative margins (`offset_left = -240, offset_right = 240, offset_top = -150, offset_bottom = 150`), perfectly centering all modals in the 640x360 viewport.
- **Unified Alagard Typography**: Removed Baybayin UI text from headers, menus, and banners per user directive to ensure 100% visual consistency with the 16-bit dark fantasy Alagard font.
- **Star Icon (✦) Removal**: Completely removed all `✦` star/diamond symbols from headers, category tags, modal titles, and action prompts across all scenes.
- **Bespoke Philippine Mythology Upgrade Icons (`assets/ui/icons/`)**:
  - Replaced raw emojis with dedicated 32×32 pixel-art relics bordered in antique brass/silver filigree:
    1. `icon_vitality.png`: Moonstone Anting-Anting amulet with pulsing heart ruby core.
    2. `icon_damage.png`: Pre-colonial Balaraw winged leaf-bladed dagger.
    3. `icon_stamina.png`: Mayon volcanic gale and ember spiral talisman.
    4. `icon_swiftness.png`: Sacred celestial Sarimanok wind feather.
    5. `icon_aegis.png`: Hardwood Kalasag war shield with carved silver lunar crescent boss.
    6. `icon_riposte.png`: Cursed Mandaya ritual wavy blood blade.
    7. `icon_shockwave.png`: Crescent lunar sickle releasing radiant shockwave ripples.
    8. `icon_ghost_dash.png`: Spectral silver Mask of Haliya with trailing phantom soul motes.
    9. `icon_eclipse_pogo.png`: Total eclipse celestial sigil with downward thrust spear.
- **Stage 2 (Emerald Terraces) 16-Bit Pixel-Art Props**:
  - Re-authored [`assets/rice_field/bahay_kubo.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/rice_field/bahay_kubo.png) and [`assets/rice_field/bamboo_flume.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/rice_field/bamboo_flume.png) in authentic 16-bit pixel art using the exact palette, outlines, and resolution of `Floor Tiles1.png` and `Decor.png`.
  - Added overgrown grass roots to stilts and tripod trestles that embed naturally into the terrain tiles.


---

## 7. Hardcore Attrition, Stage Mechanics, & 18-Level Expansion (Latest Overhaul)

### Core Hardcore Attrition Pillars
1. **Zero Automatic Health Regeneration**:
   - In [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd) (`advance_to_next_level()`), `player.reset_combat_state(false)` is now called with `restore_hp = false`.
   - Damage sustained carries over between battles and across rooms.
   - Full health restoration occurs ONLY upon respawning after death at a checkpoint or through Ancestral Shrine blessings / healing perks.
2. **Scarce & Earned Healing Economy**:
   - In [`scripts/palayok_pot.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/palayok_pot.gd), smashed breakable pots have a **25% chance** to drop a single healing herbal salve (*Dahon ng Gugo*, +1 HP), a 35% chance to drop stamina talismans, and 40% terracotta dust.
   - High-skill parry healing via *Vampiric Riposte* (+1 HP per perfect parry).
3. **Pulsating Low-HP Desperation Vignette**:
   - In [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd), when `player.current_hp == 1`, a rhythmic dark crimson vignette envelopes the viewport, intensifying with player tension.
4. **Combat Lethality & Punishing Recovery**:
   - **Reduced I-Frames**: Player post-hit invulnerability window reduced from `1.20s` down to `0.40s` in [`scripts/player.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/player.gd).
   - **Guard-Break Stun**: Guarding without sufficient stamina triggers a `0.75s` staggered vulnerability window with minimal i-frames.
   - **Punishing Damage**: Corrupted farmer scythe cleaves, stalactites, and Bakunawa bites deal **2 damage** (40% of base HP).

### Stage 2 (Emerald Terraces) Visual & Mechanical Redesign
1. **Removal of House & Flume Deco**:
   - Completely removed all instances of the Bahay Kubo stilt house and bamboo water flumes from `level_2_1.tscn`, `level_2_2.tscn`, and `level_2_3.tscn` per user design directive.
2. **Detailed Mud Puddle Assets & Suction Physics**:
   - Generated authentic 16-bit reflective mud puddles (`assets/rice_field/mud_puddle_detailed.png` and `mud_puddle_medium.png`) featuring dark loam earthen banks, water ripples, and floating rice seedlings.
   - Implemented [`scripts/mud_puddle_hazard.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/mud_puddle_hazard.gd):
     - Wading in flooded mud applies a **40% movement speed slow** (`target_speed * 0.60`).
     - **Doubles dodge stamina cost** (`20.0 -> 40.0`).
     - Emits dynamic mud splash particles on movement.
3. **Detailed Palay (Rice / Wheat) Stalks**:
   - Generated rich 16-bit golden-amber rice clumps (`assets/rice_field/palay_stalks_detailed.png` and `palay_cluster_wide.png`) with emerald bases and drooping ripe grain panicles.
   - Updated [`scripts/swaying_rice_stalks.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/swaying_rice_stalks.gd) with wind sway, physical bending when passed through, and golden chaff particle burst.
4. **Terraced Stone & Earthen Dikes (Pilapil)**:
   - Implemented [`scripts/pilapil_dike_prop.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/pilapil_dike_prop.gd) (`assets/rice_field/pilapil_dike.png`):
     - Raised stone retaining dikes with one-way collision, rewarding skilled platforming across terraces to avoid mud suction.

### 18-Level Stage Expansion
The game has been expanded from 15 scenes to **18 distinct gauntlets** in [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd):
1. **Level 2-4: The Caldera Foothills** ([`scenes/rice_field/level_2_4.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/rice_field/level_2_4.tscn)):
   - Steep terraced ascent toward Mt. Mayon with elevated stone pilapils, deep mud pools, and aggressive farmer sentries.
2. **Level 2-5: The Burning Kiln Village** ([`scenes/rice_field/level_2_5.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/rice_field/level_2_5.tscn)):
   - Ruined pottery village with lines of Palayok pots, mud pits, elite scythe wielders, and the Mayon Vanguard Miniboss guarding the tempest threshold.
3. **Level 4-4: The Chasm of Devoured Moons** ([`scenes/cave/level_4_4.tscn`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scenes/cave/level_4_4.tscn)):
   - Brutal subterranean void platforming gauntlet with falling stalactite traps, brittle crystal ledges, and flying aswang swarms over the abyss before Bakunawa.

### Verification Test Suite
Command to run:
`Godot_v4.7-stable_win64_console.exe --headless --script scratch/test_hardcore_and_stages.gd`
