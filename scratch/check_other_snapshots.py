from PIL import Image
import numpy as np

for name in ['snapshot_rice_field_2_2.png', 'snapshot_rice_field_2_3.png']:
    im = Image.open(name)
    arr = np.array(im)
    h, w, _ = arr.shape
    bottom_strip = arr[h - 100:h, :, :]
    is_pure_black = (bottom_strip[:, :, 0] == 0) & (bottom_strip[:, :, 1] == 0) & (bottom_strip[:, :, 2] == 0)
    print(f"{name}: Bottom 100 rows pure black fraction: {is_pure_black.sum() / is_pure_black.size * 100:.2f}%, avg color: {bottom_strip.mean(axis=(0, 1))}")
