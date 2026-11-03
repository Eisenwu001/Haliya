from PIL import Image
import numpy as np

for i in range(1, 5):
    path = f"assets/bicol_bg/Rice_Field_Layer{i}.png"
    im = Image.open(path)
    arr = np.array(im)
    alpha = arr[:, :, 3]
    nonz = (alpha > 10).sum()
    total = arr.shape[0] * arr.shape[1]
    print(f"Layer {i}: size={im.size}, non-zero alpha={nonz}/{total} ({nonz/total*100:.1f}%)")
    if nonz > 0:
        ys, xs = np.where(alpha > 10)
        print(f"  y range: {ys.min()}..{ys.max()}, x range: {xs.min()}..{xs.max()}")
