from PIL import Image
import numpy as np

im = Image.open('scratch/test_gate_tight.png')
arr = np.array(im)
alpha = arr[:, :, 3]

# Check columns across middle
print('Alpha across width at y=100 (halfway down):')
for x in range(0, im.size[0], 5):
    print(f'x={x:3d}: alpha={alpha[100, x]}')
