from PIL import Image
import numpy as np

im = Image.open('scratch/test_gate_structure.png')
arr = np.array(im)

# Rows 0..80: find where horizontal beam runs
print('Beam rows in test_gate_structure.png:')
alpha = arr[:, :, 3]
for y in range(20, 80, 2):
    cnt = np.sum(alpha[y, :] > 50)
    print(f'y={y:2d}: {cnt} solid pixels across')
