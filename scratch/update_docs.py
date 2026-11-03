with open("docs/AGENT_HANDOUT.md", "r", encoding="utf-8") as f:
    content = f.read()

section_7 = """

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
& "C:\\Users\\Lin\\OneDrive\\Desktop\\Godot\\Godot_v4.7-stable_win64_console.exe" --headless --script scripts/test_cultural_and_settings_features.gd
```
"""

content += section_7

with open("docs/AGENT_HANDOUT.md", "w", encoding="utf-8") as f:
    f.write(content)

print("docs/AGENT_HANDOUT.md successfully updated!")
