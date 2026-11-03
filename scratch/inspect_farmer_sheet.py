from PIL import Image
import numpy as np

im = Image.open('assets/rice_field/corrupted_farmer_spritesheet.png')
print("farmer spritesheet size:", im.size)
w, h = im.size
# 576x384 => 6 cols x 4 rows of 96x96
fw, fh = 96, 96
cols = w // fw
rows = h // fh
print(f"grid: {cols}x{rows}, total frames={cols*rows}")

arr = np.array(im)
for r in range(rows):
    for c in range(cols):
        idx = r * cols + c
        f_arr = arr[r*fh:(r+1)*fh, c*fw:(c+1)*fw, :]
        alpha = f_arr[:, :, 3]
        nonz = np.count_nonzero(alpha > 10)
        if nonz > 0:
            ys, xs = np.where(alpha > 10)
            print(f"Frame {idx:02d} (row {r}, col {c}): nonz={nonz:5d}, x=({xs.min():2d}..{xs.max():2d}), y=({ys.min():2d}..{ys.max():2d}), COM=({xs.mean():.1f}, {ys.mean():.1f})")
        else:
            print(f"Frame {idx:02d} (row {r}, col {c}): EMPTY (0 pixels)")
