from PIL import Image
import numpy as np

im = Image.open('scratch/test_gate_structure.png')
arr = np.array(im)
alpha = arr[:, :, 3]

ys, xs = np.where(alpha > 10)
print('Y range:', ys.min(), ys.max(), 'X range:', xs.min(), xs.max())
cropped = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
print('Tight size:', cropped.size)
cropped.save('scratch/test_gate_tight.png')
