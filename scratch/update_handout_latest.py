with open("docs/AGENT_HANDOUT.md", "r", encoding="utf-8") as f:
    handout = f.read()

update_note = """
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
"""

handout += update_note

with open("docs/AGENT_HANDOUT.md", "w", encoding="utf-8") as f:
    f.write(handout)

print("Updated docs/AGENT_HANDOUT.md with latest polish pass!")
