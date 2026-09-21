# 🎮 QA Testing Guide: Haliya: Mask of Sorrows

This guide is designed for QA testers and playtesters to run, test, and report issues for **Haliya: Mask of Sorrows**.

---

## 🚀 1. Setup & How to Run

### System Requirements
* **Engine**: Godot Engine 4.3+ (Recommended: **Godot 4.7**)
* **Renderer**: Forward+ (or Compatibility mode for low-spec machines)
* **OS**: Windows, macOS, or Linux

### Launching the Project
1. **Clone the repository**:
   ```bash
   git clone https://github.com/<username>/<repo-name>.git
   cd <repo-name>
   ```
2. **Open in Godot**:
   - Open Godot Engine.
   - Click **Import** > browse to this project directory > select `project.godot`.
   - Click **Import & Edit**.
3. **Run the Game**:
   - Press **F5** (or click the **Play** button in the top-right corner).
   - Main scene starts at the Main Menu: `res://scenes/main_menu.tscn`.

---

## 🕹️ 2. Controls & Mechanics

| Action | Primary Key | Secondary / Mouse | Notes |
| :--- | :--- | :--- | :--- |
| **Move Left** | `A` | `Left Arrow` | Walk |
| **Move Right** | `D` | `Right Arrow` | Walk |
| **Sprint / Run** | `Shift` | — | Hold while moving |
| **Jump** | `Space` | `W` / `Up Arrow` | Has variable jump height |
| **Crouch** | `S` | `Down Arrow` | Lowers hurtbox |
| **Attack** | `J` | `Left Mouse Button` | Multi-hit melee attack chain |
| **Guard / Parry** | `K` | `Right Mouse Button` | Hold to block; reduces damage |
| **Dodge Roll** | `Alt` | `C` | Grants invulnerability frames (costs stamina) |
| **Interact** | `E` | — | Talk to Kapre NPC / interact with Mask Altars |
| **Restart / Respawn** | `R` | — | Resets current checkpoint / stage |
| **Pause / Resume** | `Escape` | — | Opens pause menu |

---

## ⚡ 3. QA Debug & Level-Skip Shortcuts

Use these built-in developer/QA hotkeys during gameplay to jump across levels or test isolated scenes quickly:

| Shortcut Key | Function |
| :--- | :--- |
| `1` or `Numpad 1` | **Jump directly to Forest** (Level 1-1: *Whispering Canopy*) |
| `2` or `Numpad 2` | **Jump directly to Rice Field** (Level 2-1: *Emerald Terraces*) |
| `3` or `Numpad 3` | **Jump directly to Rainy Forest** (Level 3-1: *Drenched Foothills*) |
| `N` or `PageDown` | **Skip to Next Level** |
| `P` or `PageUp` | **Skip to Previous Level** |
| `H` | **Toggle UI/HUD** (Hides HUD for clean visual inspections & screenshots) |
| `Escape` | **Toggle Pause Menu** |

---

## 🗺️ 4. Level List & Themes

| Index | Theme | Level Code | Level Title | Scene Path |
| :---: | :--- | :---: | :--- | :--- |
| 0 | Forest | Level 1-1 | *Whispering Canopy* | `res://scenes/forest/level_1_1.tscn` |
| 1 | Forest | Level 1-2 | *Ancient Balete Grove* | `res://scenes/forest/level_1_2.tscn` |
| 2 | Forest | Level 1-3 | *Corrupted Sentry Ridge* | `res://scenes/forest/level_1_3.tscn` |
| 3 | Rice Field | Level 2-1 | *Emerald Terraces* | `res://scenes/rice_field/level_2_1.tscn` |
| 4 | Rice Field | Level 2-2 | *Stilt Farmstead* | `res://scenes/rice_field/level_2_2.tscn` |
| 5 | Rice Field | Level 2-3 | *The Mayon Crossing* | `res://scenes/rice_field/level_2_3.tscn` |
| 6 | Rainy Forest | Level 3-1 | *Drenched Foothills* | `res://scenes/rainy_forest/level_3_1.tscn` |
| 7 | Rainy Forest | Level 3-2 | *Canopy Torrent* | `res://scenes/rainy_forest/level_3_2.tscn` |
| 8 | Rainy Forest | Level 3-3 | *The Flooded Ravine* | `res://scenes/rainy_forest/level_3_3.tscn` |
| 9 | Rainy Forest | Level 3-4 | *Moss-Veiled Ruins* | `res://scenes/rainy_forest/level_3_4.tscn` |
| 10 | Rainy Forest | Level 3-5 | *Eye of the Tempest* (Boss) | `res://scenes/rainy_forest/level_3_5.tscn` |

---

## 🤖 5. Running Automated Verification Scripts

Automated QA suites are available under `res://scratch/` to verify core mechanics headlessly or via editor:

* **Full HUD & Damage Verification**:
  - Run scene: `res://scratch/test_runner.tscn`
  - Validates HP bar tweens, stamina recharge, ghost bars, and kill counter labels.
* **Stage 3 & Weather Hazards**:
  - Run scene: `res://scratch/test_stage_3_details.tscn`
  - Validates lightning hazard timings, puddles, rain particle VFX.
* **World Progression Flow**:
  - Run scene: `res://scratch/test_world_progression.tscn`
  - Validates map transition triggers and level loading.

---

## 📋 6. QA Test Checklist

When testing a new release or branch, check off the following:

- [ ] **Menu Navigation**: Start game, open options/audio settings, pause/resume.
- [ ] **Movement & Physics**: Check ground collision, platform edge snapping, slopes, and fall recovery.
- [ ] **Combat & Feedback**:
  - [ ] Player attack chain deals damage to Aswang and Skeletons.
  - [ ] Guarding mitigates damage; guard break triggers when stamina depletes.
  - [ ] Dodge roll provides expected i-frames through enemy swipes.
- [ ] **NPC / Interactivity**:
  - [ ] Kapre NPC dialogue triggers on `E`.
  - [ ] Mask Altar claiming sequence finishes and updates player state.
- [ ] **Level Transitions**:
  - [ ] Walking past the right boundary (X ~ 5050) transitions cleanly to next level.
  - [ ] Debug level skip (`N` / `P`) does not crash or leave orphan nodes.
- [ ] **Stage 3-5 Boss Encounter**:
  - [ ] Boss health bar mounts to HUD.
  - [ ] Boss phase changes trigger without script errors.

---

## 🐛 7. Bug Reporting Template

When logging an issue on GitHub Issues:

```markdown
**Level/Area:** [e.g., Level 3-2 Canopy Torrent or Main Menu]
**Build / Git Commit:** [e.g., commit hash or branch name]

**Steps to Reproduce:**
1. Jump to level using shortcut '3'
2. Run towards first pit
3. Press dodge roll while falling

**Expected Behavior:**
Player completes dodge or falls with proper gravity.

**Actual Behavior:**
Player gets stuck floating or clips through terrain.

**Screenshots / Console Output:**
[Attach screenshot or Godot Debugger error log]
```
