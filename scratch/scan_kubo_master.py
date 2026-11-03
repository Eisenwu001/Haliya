import numpy as np
from PIL import Image

im = Image.open('assets/bahay_kubo/bahay_kubo_master_sheet.png')
arr = np.array(im)
alpha = arr[:, :, 3]

# Split into 4x3 grid or similar to see where content is
rows, cols = 4, 4
h, w = im.size[1] // rows, im.size[0] // cols
for r in range(rows):
    for c in range(cols):
        block = alpha[r*h:(r+1)*h, c*w:(c+1)*w]
        cnt = np.sum(block > 50)
        print(f'Grid ({r},{c}) at x=[{c*w}..{(c+1)*w}], y=[{r*h}..{(r+1)*h}]: {cnt} px')
