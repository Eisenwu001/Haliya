from PIL import Image
import numpy as np

im = Image.open('scratch/test_gate_structure.png')
arr = np.array(im)
print('Shape:', arr.shape)
print('Corner pixels (0,0):', arr[0,0], ' (0, end):', arr[0, -1], ' (end, 0):', arr[-1, 0])
print('Min alpha:', arr[:, :, 3].min(), 'Max alpha:', arr[:, :, 3].max())
