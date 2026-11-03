from PIL import Image
import numpy as np

im = Image.open('scratch/test_arch_preview.png')
small = im.resize((48, 20), Image.Resampling.BILINEAR)
s_arr = np.array(small)
for r in range(20):
    line = ''
    for c in range(48):
        if s_arr[r, c, 3] < 50:
            line += ' '
        else:
            lum = int(0.299 * s_arr[r, c, 0] + 0.587 * s_arr[r, c, 1] + 0.114 * s_arr[r, c, 2])
            chars = ' .:-=+*#%@'
            line += chars[lum * (len(chars) - 1) // 255]
    print(line)
