# Stage 2: Rice Field (Levels 2-1 to 2-5) — Overhaul & Polish Handout

> **Status**: **COMPLETED & VERIFIED (All 5 Levels 2-1 to 2-5 Production-Ready)**  
> **Target Viewport**: `640×360` (2D pixel-art platformer, integer scaling, dynamic `PointLight2D` / `CanvasModulate`)  
> **Engine**: Godot 4.7 (`C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe`)  
> **Levels Covered**:
> - **Level 2-1**: *Emerald Terraces* (`res://scenes/rice_field/level_2_1.tscn`) — Sunlit morning paddies, Carabaos, bamboo flumes, pilapil dikes, introductory terraces.
> - **Level 2-2**: *Stilt Farmstead* (`res://scenes/rice_field/level_2_2.tscn`) — Golden afternoon village with 4 multi-tier jumpable **Bahay Kubo** stilt houses, granary platforms, and lantern-lit decks.
> - **Level 2-3**: *The Mayon Crossing* (`res://scenes/rice_field/level_2_3.tscn`) — Sunset irrigation gorge with stepped pilapil dikes, mud puddle hazards, Carabaos, and Santelmo spirit wisps (no duplicate boss).
> - **Level 2-4**: *The Caldera Foothills* (`res://scenes/rice_field/level_2_4.tscn`) — Volcanic dusk ascent with steep 3-tier terraces (`Row 8`, `Row 7`, `Row 6`), Santelmo spirit wisps, and Corrupted Villagers.
> - **Level 2-5**: *The Burning Kiln Village* (`res://scenes/rice_field/level_2_5.tscn`) — Ash-swept village approaches leading into the locked **Mayon Flame Vanguard** climax arena (`x = 4050..5080`) with Ancestral Checkpoint Shrine at `x = 3620`.

---

## 1. Progress Tracker (Completed Checklist)

- [x] Audit Stage 2 problems (cloned 2-3/2-4/2-5 bosses, missing Bahay Kubo/Flumes, broken `KEY_3..KEY_5` hotkeys, missing ledge detection, mud puddle overlap bug).
- [x] **Phase 1: AI Pixel-Art Asset Generation & Spritesheet Processing**
  - [x] Overhauled **Corrupted Bicolano Villager / Farmer** ([`assets/rice_field/corrupted_farmer_spritesheet.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/rice_field/corrupted_farmer_spritesheet.png), `576×384`, 6×4 grid of `96×96` frames) with 24 distinct, fluid animation frames (6-frame breathing idle, 6-frame stalking locomotion cycle with curved *karit* sickle held in every frame, 6-frame overhead windup & wide crimson-violet crescent lunge cleave, 2-frame hit/parried stagger, and 4-frame collapse & cursed ash dissolution).
  - [x] Generated & processed **Mayon Flame Vanguard Miniboss** ([`assets/miniboss/mayon_vanguard/mayon_vanguard_spritesheet.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/miniboss/mayon_vanguard/mayon_vanguard_spritesheet.png), `2048×1024`, 8×4 grid of `256×256` frames) with volcanic basalt armor, glowing lava fissures, Kalasag shield, Kampilan greatsword, and consistent foot baseline (`y = 240`).
  - [x] Installed & Polished **Custom User-Provided 4-Layer Bicol Rice Field Parallax Backgrounds** ([`assets/bicol_bg/Rice_Field_Layer1.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/bicol_bg/Rice_Field_Layer1.png) through [`Rice_Field_Layer4.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/bicol_bg/Rice_Field_Layer4.png), `1024×360`):
    - **Clarity & Sharpness Polish**: Resolved blurry, smeared painterly textures using unsharp masking (`radius=1.2, percent=185-195`), contrast enhancement, and pixel-art edge clarity so terraces, bunds, and mountains match the sharp 16-bit foreground.
    - **Artifact & Black Cutout Removal**: Completely eliminated the black box cut into Mount Mayon's plume and filtered out the floating black artifact on the left via connected-component analysis.
    - **Integrated Golden Sunrise Sky (Layer 4)**: Built a warm amber sunrise sky directly into Layer 4 matching Mayon's amber volcanic lighting, and hid the cyan forest sky during Stage 2 so no cold blue leaks through.
    - **Seamless Mirroring**: Removed the fractional `1.001` scale multiplier in [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd) and applied symmetric smoothstep edge matching, eliminating all vertical seam lines.
    - Cleaned up and removed all legacy/obsolete background artifacts (`.bak`, `_orig.png`, `_thumb.png`).
  - [x] Removed `BahayKuboProp` and broken `prop_lantern_small.png` from all 5 Stage 2 levels per user request, grounding breakable pots firmly onto terrain floors.
  - [x] Rebuilt **Tileset-Integrated Mud Puddles** ([`mud_puddle_detailed.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/rice_field/mud_puddle_detailed.png), [`mud_puddle_medium.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/rice_field/mud_puddle_medium.png), [`mud_puddle.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/rice_field/mud_puddle.png)) using the exact pixel palette of [`Floor Tiles1.png`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/assets/platform_assets/Floor%20Tiles1.png) (`#a6b553`, `#76943d`, `#3e4222`, `#312b26`, `#221f19`) and embedded them flush into the top of the ground tilemap (`offset = Vector2(0, 6)`, `z_index = 1`).
- [x] **Phase 2: Enemy, Boss & Hazard Code Overhaul**
  - [x] Overhauled [`scripts/corrupted_farmer.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/corrupted_farmer.gd):
    - Added `LedgeRay` (`RayCast2D`) cliff/ledge detection so elevated terrace sentries never walk or lunge blindly off drop-offs.
    - Added `_apply_smooth_procedural_flow(delta)` for organic breathing, walk stride lean, and attack squash-and-stretch.
    - Added ranged `State.SICKLE_TOSS` (`_spawn_corrupted_sickle_wave`) firing a spinning violet crescent projectile at mid-range (`135..235 px`).
    - Emits both `farmer_died` and `aswang_died` signals for clean telemetry.
  - [x] Overhauled [`scripts/mayon_vanguard_miniboss.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/mayon_vanguard_miniboss.gd):
    - Upgraded `spawn_molten_flame_wave` to spawn active `Area2D` (`MoltenFlamePillar_*`) hitboxes that persist across the pillar eruption lifetime.
    - Added Phase 2 Enraged (`<= 50% HP`) 4-pillar forward eruption + rear backdraft pillar (`-dir * 44.0`) to punish back-camping.
  - [x] Fixed [`scripts/mud_puddle_hazard.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/mud_puddle_hazard.gd):
    - Added `"mud_puddle_hazards"` group overlap verification on `_on_body_exited` so leaving one adjacent mud pool while still standing in another never prematurely clears `player.is_wading_in_mud`.
    - Replaced per-step particle node allocation with a reusable `CPUParticles2D` (`splash_particles`).
  - [x] Aligned 2D platformer one-way collision shapes in [`scripts/bahay_kubo_prop.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/bahay_kubo_prop.gd) (3 jumpable tiers at `y = -44`, `y = -92`, `y = -134`), [`scripts/bamboo_flume_prop.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/bamboo_flume_prop.gd) (`y = -50`), and [`scripts/pilapil_dike_prop.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/pilapil_dike_prop.gd) (`y = -28`).
- [x] **Phase 3: 5-Level Stage Architecture & `main.gd` Integration**
  - [x] Updated and executed [`scripts/build_rice_field_levels.py`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/build_rice_field_levels.py) to generate all **5 distinct levels** (`level_2_1.tscn` through `level_2_5.tscn`) with unique platforming layouts, restored `BahayKuboProp`, `BambooFlumeProp`, `PilapilDikeProp`, `MudPuddleHazard`, zero duplicate node names, and **Mayon Vanguard Miniboss exclusively in Level 2-5**.
  - [x] Updated [`scripts/main.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/main.gd):
    - Fixed QA debug hotkeys (`1` -> 1-1 [idx 0], `2` -> 2-1 [idx 3], `3` -> 3-1 [idx 8], `4` -> 4-1 [idx 13], `5` -> Boss [idx 17]).
    - Configured progressive 5-step time-of-day lighting (`CanvasModulate`, `sky_sprite`, `rice_field_parallax_layers`) and atmospheric particles across Levels `2-1` to `2-5`.
    - Fixed Boss Checkpoint Shrine indices (`[2, 7, 12, 16, 17]`) so the Ancestral Shrine spawns at `x = 3620` in **Level 2-5** (index 7).
    - Added 2 floating `Santelmo` volcanic spirit wisps to Levels `2-3` and `2-4` in `wire_scene_enemies`.
- [x] **Phase 4: Automated Headless Verification**
  - [x] Updated and ran [`scripts/test_rice_field_scenes.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/test_rice_field_scenes.gd) and [`scripts/test_rice_field_complete.gd`](file:///c:/Users/Lin/OneDrive/Pictures/Camera%20Roll/Documents/project-1-test/scripts/test_rice_field_complete.gd) across all 5 levels (`2-1` to `2-5`) — **100% PASS**.

---

## 2. Five-Level Design Specification

| Level | Index | Title | Time of Day / Mood | Key Platforming & Architectural Features | Enemies & Encounters |
| :--- | :---: | :--- | :--- | :--- | :--- |
| **2-1** | `3` | *Emerald Terraces* | Sunlit Golden Morning | Stepped green paddies, 3 wallowing Carabaos (one-way platform backs at `y = -52`), 2 Bamboo Flumes (`y = -50`), 2 Pilapil Dikes (`y = -28`), 1 outpost Bahay Kubo (`y = -44/-92/-134`), 2 Mud Hazards. | 5 Corrupted Villagers + 2 Aswangs (**7 total**) |
| **2-2** | `4` | *Stilt Farmstead* | Warm Afternoon Breeze | Authentic farming village: **4 Bahay Kubo stilt houses** creating a multi-tiered rooftop & porch highway (`y = -44`, `y = -92`, `y = -134`), linked by 2 Bamboo Flumes and 3 Pilapil Dikes over 3 Mud Hazards. | 6 Corrupted Villagers + 3 Aswangs (**9 total**) |
| **2-3** | `5` | *The Mayon Crossing* | Sunset Violet-Gold Dusk | Wide flooded irrigation channels bridged by 4 Pilapil stone dikes, 3 Bamboo Flumes, 3 Carabaos stationed in deep mud crossings, and 2 Bahay Kubos. | 6 Corrupted Villagers + 4 Aswangs + 2 Santelmos (**12 total**) |
| **2-4** | `6` | *The Caldera Foothills* | Crimson Volcanic Twilight | High-altitude multi-tiered terraces (`Row 8`, `Row 7`, `Row 6` at `y = 192`), 4 Mud Hazards below, 3 Bamboo Flume bridges, 4 Pilapil Dikes, and 2 Bahay Kubos. | 7 Corrupted Villagers + 4 Aswangs + 2 Santelmos (**13 total**) |
| **2-5** | `7` | *The Burning Kiln Village* | Smoldering Ash & Magma Glow | Fortified kiln village ascent (`x = 0..3600`), Ancestral Shrine Checkpoint (`x = 3620`), Palayok healing cache (`x = 3680`), and the locked **Mayon Vanguard Arena** (`x = 4050..5080`). | 5 Corrupted Villagers + 4 Aswangs + **Mayon Vanguard Miniboss** (**10 total**) |

---

## 3. How to Regenerate or Re-Verify Stage 2

```powershell
# 1. Regenerate all 5 Rice Field .tscn scenes (2-1 to 2-5):
python scripts/build_rice_field_levels.py

# 2. Run Scene Structure & Prop Uniqueness Verification:
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless --script scripts/test_rice_field_scenes.gd

# 3. Run Full Stage 2 Combat, Boss, Prop & Progression Integration Suite:
& "C:\Users\Lin\OneDrive\Desktop\Godot\Godot_v4.7-stable_win64_console.exe" --headless --script scripts/test_rice_field_complete.gd
```
