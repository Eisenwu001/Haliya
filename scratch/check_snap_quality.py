from PIL import Image
import numpy as np

for name in ['scratch/verify_new_kubo_farmstead.png', 'scratch/verify_new_level_2_2.png']:
    im = Image.open(name)
    arr = np.array(im)
    print(f"=== {name} ({im.size}) ===")
    print("  RGB mean:", arr.mean(axis=(0, 1)).astype(int))
    # Check bottom 50 rows (dirt fill):
    h, w, _ = arr.shape
    bot = arr[h-50:h, :, :]
    is_pure_black = (bot[:, :, 0] == 0) & (bot[:, :, 1] == 0) & (bot[:, :, 2] == 0)
    print(f"  Bottom 50 rows pure black percentage: {is_pure_black.sum() / is_pure_black.size * 100:.2f}%")
