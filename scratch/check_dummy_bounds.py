from PIL import Image
import numpy as np

im = Image.open('assets/props/training_dummy_sheet.png')
f0 = im.crop((0, 0, 96, 96))
arr = np.array(f0)
alpha = arr[:, :, 3]
ys, xs = np.where(alpha > 20)
print('Training dummy F0 bounds: Y in', ys.min(), ys.max(), 'X in', xs.min(), xs.max())
print('Height:', ys.max() - ys.min() + 1, 'Width:', xs.max() - xs.min() + 1)
print('Center offset from bottom:', 96 - ys.max())
