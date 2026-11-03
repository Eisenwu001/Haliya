from PIL import Image
import numpy as np

f0 = np.array(Image.open('scratch_carabao_f0.png'))
f1 = np.array(Image.open('scratch_carabao_f1.png'))
f2 = np.array(Image.open('scratch_carabao_f2.png'))
f3 = np.array(Image.open('scratch_carabao_f3.png'))
f4 = np.array(Image.open('scratch_carabao_f4.png'))

for i, f in enumerate([f1, f2, f3, f4], start=1):
    diff = np.abs(f.astype(int) - f0.astype(int))
    diff_alpha = diff[:, :, 3]
    diff_color = diff[:, :, :3].sum(axis=2)
    print(f"Diff Frame {i} vs Frame 0:")
    print(f"  max pixel diff: {diff.max()}")
    print(f"  pixels with diff > 0: {(diff > 0).any(axis=2).sum()}")
    print(f"  alpha diff > 0: {(diff_alpha > 0).sum()}")
    # Where are the differences located?
    ys, xs = np.where((diff > 0).any(axis=2))
    if len(xs) > 0:
        print(f"  x range: {xs.min()}..{xs.max()}, y range: {ys.min()}..{ys.max()}")
