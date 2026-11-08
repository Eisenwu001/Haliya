#!/usr/bin/env python3
"""
scratch/crop_and_prepare_artifacts.py
Crops the HUD cluster region (0, 0, 185, 115) from the verification screenshots,
scales by 2x nearest-neighbor for high-DPI artifact inspection,
and copies all screenshots and crops to the artifact directory.
"""

import os
import shutil
from PIL import Image

ARTIFACT_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\05720c77-b99a-4c60-83a4-4db33122788b"
os.makedirs(ARTIFACT_DIR, exist_ok=True)

# Copy icon stack alignment test
align_src = "scratch/icon_stack_alignment_test.png"
if os.path.exists(align_src):
    shutil.copy(align_src, os.path.join(ARTIFACT_DIR, "icon_stack_alignment_test.png"))
    print("Copied icon_stack_alignment_test.png")

# Also copy raw and imported PNGs for inspection
imported_files = [
    "assets/ui/hp_full.png",
    "assets/ui/hp_empty.png",
    "assets/ui/hp_damaged.png",
    "assets/ui/shield_intact.png",
    "assets/ui/shield_cracked.png",
    "assets/ui/shield_broken.png",
    "assets/ui/stamina_frame.png",
    "assets/ui/stamina_frame_left.png",
    "assets/ui/stamina_frame_mid.png",
    "assets/ui/stamina_frame_right.png",
]
for f in imported_files:
    if os.path.exists(f):
        shutil.copy(f, os.path.join(ARTIFACT_DIR, os.path.basename(f)))

screenshots = [
    "hud_bright_100.png",
    "hud_bright_50.png",
    "hud_bright_0.png",
    "hud_bright_exhausted.png",
    "hud_dark_100.png",
    "hud_dark_50.png",
    "hud_dark_0.png",
    "hud_dark_exhausted.png",
    "hud_hp_damaged_slot.png",
]

# Crop region for 2560x1440 resolution (4x scale of 640x360):
# (8*4, 6*4, 180*4, 107*4) = (32, 24, 720, 428)
crop_box = (32, 24, 720, 428)

for s in screenshots:
    if not os.path.exists(s):
        print(f"Warning: {s} not found")
        continue

    # Copy full screenshot
    shutil.copy(s, os.path.join(ARTIFACT_DIR, s))

    # Generate tight HUD crop (native 4x window capture)
    im = Image.open(s)
    crop_4x = im.crop(crop_box)
    crop_name = "crop_" + s
    crop_4x.save(os.path.join(ARTIFACT_DIR, crop_name))

    # Also save 1x base pixel art resolution version
    w_1x = crop_4x.width // 4
    h_1x = crop_4x.height // 4
    crop_1x = crop_4x.resize((w_1x, h_1x), Image.Resampling.NEAREST)
    crop_1x_name = "crop_1x_" + s
    crop_1x.save(os.path.join(ARTIFACT_DIR, crop_1x_name))
    print(f"Processed and copied {s}, {crop_name}, {crop_1x_name}")

print("All HUD artifacts prepared successfully!")
