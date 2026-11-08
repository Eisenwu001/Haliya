#!/usr/bin/env python3
"""
scratch/generate_alignment_test.py
Generates an image showing:
1. Side-by-side states of HP (Full, Damaged, Empty) and Shield (Intact, Cracked, Broken)
2. Stack overlay / diff of states to confirm 0px anchor jump
3. 4x pixel zoom view
"""

import os
from PIL import Image, ImageDraw, ImageFont

ui_dir = "assets/ui"
out_dir = "scratch"

hp_full = Image.open(f"{ui_dir}/hp_full.png").convert("RGBA")
hp_empty = Image.open(f"{ui_dir}/hp_empty.png").convert("RGBA")
hp_damaged = Image.open(f"{ui_dir}/hp_damaged.png").convert("RGBA")

sh_intact = Image.open(f"{ui_dir}/shield_intact.png").convert("RGBA")
sh_cracked = Image.open(f"{ui_dir}/shield_cracked.png").convert("RGBA")
sh_broken = Image.open(f"{ui_dir}/shield_broken.png").convert("RGBA")

# Canvas: 480 x 260 dark charcoal background
bg_color = (30, 36, 32, 255)
grid_color = (45, 54, 48, 255)
canvas = Image.new("RGBA", (520, 240), bg_color)
draw = ImageDraw.Draw(canvas)

# Draw subtle grid
for x in range(0, 520, 10):
    draw.line([(x, 0), (x, 240)], fill=grid_color)
for y in range(0, 240, 10):
    draw.line([(0, y), (520, y)], fill=grid_color)

# Paste HP trio (at 4x scale)
# HP is 23x29 -> 4x is 92x116
def paste_4x(im, x, y):
    ds = im.resize((im.width * 4, im.height * 4), Image.Resampling.NEAREST)
    canvas.paste(ds, (x, y), ds)

paste_4x(hp_full, 20, 30)
paste_4x(hp_damaged, 130, 30)
paste_4x(hp_empty, 240, 30)

# Paste Shield trio (at 4x scale)
# Shield is 24x30 -> 4x is 96x120
paste_4x(sh_intact, 20, 30 + 130) # wait, canvas height
# Let's make canvas larger: 680 x 360
canvas = Image.new("RGBA", (680, 360), bg_color)
draw = ImageDraw.Draw(canvas)
for x in range(0, 680, 16):
    draw.line([(x, 0), (x, 360)], fill=grid_color)
for y in range(0, 360, 16):
    draw.line([(0, y), (680, y)], fill=grid_color)

# Row 1: HP Icons
paste_4x(hp_full, 40, 40)
paste_4x(hp_damaged, 160, 40)
paste_4x(hp_empty, 280, 40)

# Stack overlay: Full + Damaged + Empty semi-transparent
overlay_hp = Image.new("RGBA", hp_full.size, (0, 0, 0, 0))
# Tint empty blue, damaged red, full bone
for x in range(hp_full.width):
    for y in range(hp_full.height):
        # Draw bounding boxes and stack
        pass
# Actually overlay composite:
overlay_hp.paste(hp_empty, (0, 0), hp_empty)
overlay_hp.paste(hp_damaged, (0, 0), hp_damaged)
overlay_hp.paste(hp_full, (0, 0), hp_full)
paste_4x(overlay_hp, 420, 40)

# Row 2: Shield Icons
paste_4x(sh_intact, 40, 190)
paste_4x(sh_cracked, 160, 190)
paste_4x(sh_broken, 280, 190)

overlay_sh = Image.new("RGBA", sh_intact.size, (0, 0, 0, 0))
overlay_sh.paste(sh_broken, (0, 0), sh_broken)
overlay_sh.paste(sh_cracked, (0, 0), sh_cracked)
overlay_sh.paste(sh_intact, (0, 0), sh_intact)
paste_4x(overlay_sh, 420, 190)

out_path = f"{out_dir}/icon_stack_alignment_test.png"
canvas.save(out_path)
print(f"Saved {out_path}")
