from PIL import Image
import numpy as np

# Let's compare frame A01 of Idle
base_idle = Image.open('assets/haliya/common_00_idle_stand_A01.png').convert('RGBA')
wm_kamp = Image.open('Haliya with clothes/Haliya/Idle/w- Mask/v3/kampilan/haliya_idle_A01.png')
wom_kamp = Image.open('Haliya with clothes/Haliya/Idle/w-o Mask/v3/kampilan/haliya_idle_A01.png')

# Let's also extract the clothes layer for A01
# Remember: wom_kamp - base (or wom_fist)
wom_fist = Image.open('Haliya with clothes/Haliya/Idle/w-o Mask/v3/fist/haliya_idle_A01.png')
wm_fist = Image.open('Haliya with clothes/Haliya/Idle/w- Mask/v3/fist/haliya_idle_A01.png')
# In haliya_idle_B01.ase, we extracted layer 1 (Clothes Copy).
# For A01, let's see how cloth looks when overlaid on base_idle

# Let's save a visual comparison of:
# 1. Base Idle
# 2. wom_kamp (new clothes, without mask, kampilan)
# 3. wm_kamp (new clothes, with mask, kampilan)
# 4. wom_fist (new clothes, without mask, fist)
# 5. wm_fist (new clothes, with mask, fist)

crop_box = (50, 115, 170, 250)
crops = [
    ('1. Base Original', base_idle.crop(crop_box)),
    ('2. New: w-o Mask + Kampilan', wom_kamp.crop(crop_box)),
    ('3. New: w- Mask + Kampilan', wm_kamp.crop(crop_box)),
    ('4. New: w-o Mask + Fist', wom_fist.crop(crop_box)),
    ('5. New: w- Mask + Fist', wm_fist.crop(crop_box)),
]

cw, ch = crops[0][1].size
grid = Image.new('RGBA', (cw * len(crops), ch + 40), (25, 25, 35, 255))
from PIL import ImageDraw
draw = ImageDraw.Draw(grid)

for i, (name, crp) in enumerate(crops):
    grid.paste(crp, (i * cw, 35), crp)
    draw.text((i * cw + 5, 10), name, fill=(220, 220, 220, 255))

grid.save('scratch/compare_idle_options.png')
print("Saved scratch/compare_idle_options.png")
