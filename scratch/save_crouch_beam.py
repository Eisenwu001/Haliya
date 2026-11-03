from PIL import Image
import numpy as np

im = Image.open('scratch/test_gate_beam_crop.png')
arr = np.array(im)
alpha = arr[:, :, 3]

ys, xs = np.where(alpha > 20)
print('Y range:', ys.min(), ys.max(), 'X range:', xs.min(), xs.max())
tight = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
print('Tight size:', tight.size)
tight.save('assets/bahay_kubo/prop_crouch_beam.png')
print('Saved to assets/bahay_kubo/prop_crouch_beam.png!')
