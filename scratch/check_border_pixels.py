from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im)
# Is there a 1-pixel frame or border line around the JPG?
# Let's check col 0, row 0, col -1, row -1:
for name, strip in [("row 0", arr[0, :, :]), ("row -1", arr[-1, :, :]), ("col 0", arr[:, 0, :]), ("col -1", arr[:, -1, :])]:
    is_mag = (strip[:, 0] > 170) & (strip[:, 2] > 170) & (strip[:, 1] < 80)
    print(f"{name}: total {len(is_mag)}, magenta {is_mag.sum()}, non-magenta {len(is_mag) - is_mag.sum()}")
    if is_mag.sum() < len(is_mag):
        non_mag_indices = np.where(~is_mag)[0]
        print(f"  sample non-magenta at index {non_mag_indices[0]}: {strip[non_mag_indices[0]]}")
