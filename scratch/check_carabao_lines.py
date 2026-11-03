from PIL import Image
import numpy as np

sheet = Image.open('assets/rice_field/carabao_spritesheet.png')
arr = np.array(sheet)
w, h = sheet.size
fw = w // 5

for f in range(5):
    f_arr = arr[:, f*fw:(f+1)*fw, :]
    # Let's check for any pixels that stand out:
    # E.g. bright pixels (R>200, G>200, B>200) or pure white or strange seams:
    bright = (f_arr[:, :, 0] > 180) & (f_arr[:, :, 1] > 180) & (f_arr[:, :, 2] > 180) & (f_arr[:, :, 3] > 100)
    print(f"Frame {f}: bright pixels count = {np.count_nonzero(bright)}")
    if np.count_nonzero(bright) > 0:
        ys, xs = np.where(bright)
        print(f"  bright y range: {ys.min()}..{ys.max()}, x range: {xs.min()}..{xs.max()}")
        print(f"  sample bright pixel RGBA: {f_arr[ys[0], xs[0]]}")
