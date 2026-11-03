with open("docs/AGENT_HANDOUT.md", "r", encoding="utf-8") as f:
    text = f.read()

# Update status at top
old_status = """> **Status**: All 4 Polish Phases (**Cave Overhaul**, **Final Boss Bakunawa Overhaul**, **VFX/Glitch Fixes**, and **Complete Game Loop Polish**) AND the **Hollow Knight Cave Platformer Overhaul** are **COMPLETED & TESTED**."""

new_status = """> **Status**: All Polish Phases, the **Hardcore Attrition & No Health Regen Overhaul**, **Stage 2 Rice Field Visual/Mechanical Redesign** (detailed AI-generated puddles & palay stalks, removal of houses/flumes, stone pilapil dikes, mud suction physics), and **18-Level Stage Expansion** are **COMPLETED & TESTED**."""

if old_status in text:
    text = text.replace(old_status, new_status)

text = text.replace("- **13-Stage Progression (`LEVELS_DATA`", "- **18-Stage Progression (`LEVELS_DATA`")

section_7 = """

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
"""

text = text + section_7

with open("docs/AGENT_HANDOUT.md", "w", encoding="utf-8") as f:
    f.write(text)

print("Updated docs/AGENT_HANDOUT.md successfully!")
