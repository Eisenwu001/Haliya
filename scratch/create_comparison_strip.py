from PIL import Image
import numpy as np

# 1. Run comparison (6 frames x 2 rows: Top = Original, Bottom = Clothed Prototype)
w, h = 256, 256
run_strip = Image.new('RGBA', (w * 6, h * 2), (28, 30, 36, 255))

for i in range(1, 7):
    name = f'common_12_run{i:02d}.png'
    orig = Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA')
    proto = Image.open(f'assets/haliya/{name}').convert('RGBA')
    run_strip.paste(orig, ((i - 1) * w, 0), orig)
    run_strip.paste(proto, ((i - 1) * w, h), proto)

run_strip.save('scratch/run_strip_comparison.png')

# 2. Crop to the relevant region (x around 50 to 180, y around 110 to 250)
# Region width = 140, height = 150
crop_w, crop_h = 140, 150
crop_strip = Image.new('RGBA', (crop_w * 6, crop_h * 2), (28, 30, 36, 255))

for i in range(1, 7):
    name = f'common_12_run{i:02d}.png'
    orig = Image.open(f'assets/haliya_backup_originals/{name}').convert('RGBA').crop((50, 110, 190, 260))
    proto = Image.open(f'assets/haliya/{name}').convert('RGBA').crop((50, 110, 190, 260))
    crop_strip.paste(orig, ((i - 1) * crop_w, 0), orig)
    crop_strip.paste(proto, ((i - 1) * crop_w, crop_h), proto)

crop_strip.save('scratch/run_strip_crop_1x.png')

# 3x scale of crop strip for crystal clear viewing
crop_3x = crop_strip.resize((crop_strip.width * 3, crop_strip.height * 3), Image.NEAREST)
crop_3x.save('scratch/run_strip_crop_3x.png')

print('Saved run_strip_comparison.png and run_strip_crop_3x.png!')
