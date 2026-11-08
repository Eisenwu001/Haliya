from PIL import Image
import numpy as np

# Frame: Idle A01
base = Image.open('assets/haliya/common_00_idle_stand_A01.png').convert('RGBA')
wm_k = Image.open('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_A01.png')
wom_k = Image.open('Haliya with clothes/Haliya/Idle/w-o Mask/v3/kampilan/haliya_idle_A01.png')

# In Option 3: what is the cloth layer?
# Let's see: what pixels in wom_fist differ from base?
# In wom_fist, the character has no mask and no weapon.
# If we extract only the cloth:
# In the Aseprite file haliya_idle_B01.ase, layer 1 was "Clothes Copy".
# Let's see how "Clothes Copy" looks composited over base B01:
layer1_cloth = Image.open('scratch/layer_1_Clothes_Copy.png')
base_b01 = Image.open('assets/haliya/common_00_idle_stand_B01.png').convert('RGBA')

comp_cloth_only = Image.alpha_composite(base_b01, layer1_cloth)
comp_cloth_only.save('scratch/test_comp_cloth_only_b01.png')

# Save side-by-side of B01:
# 1. Base B01
# 2. Base B01 + cloth only
# 3. Full w-o Mask + Kampilan B01
# 4. Full w- Mask + Kampilan B01
full_wm_k_b01 = Image.open('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_B01.png')
full_wom_k_b01 = Image.open('Haliya with clothes/Haliya/Idle/w-o Mask/v3/kampilan/haliya_idle_B01.png')

crop_box = (60, 115, 175, 250)
crops = [
    ('Base B01', base_b01.crop(crop_box)),
    ('Base + Cloth Layer', comp_cloth_only.crop(crop_box)),
    ('Full w-o Mask + Kampilan', full_wom_k_b01.crop(crop_box)),
    ('Full w- Mask + Kampilan', full_wm_k_b01.crop(crop_box)),
]

cw, ch = crops[0][1].size
grid = Image.new('RGBA', (cw * len(crops), ch + 40), (25, 25, 35, 255))
from PIL import ImageDraw
draw = ImageDraw.Draw(grid)
for i, (name, crp) in enumerate(crops):
    grid.paste(crp, (i * cw, 35), crp)
    draw.text((i * cw + 5, 10), name, fill=(220, 220, 220, 255))
grid.save('scratch/compare_b01_detailed.png')
print("Saved scratch/compare_b01_detailed.png")
