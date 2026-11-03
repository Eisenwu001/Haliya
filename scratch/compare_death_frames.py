from PIL import Image
import numpy as np

f20 = np.array(Image.open('scratch/farmer_f20.png'))
f21 = np.array(Image.open('scratch/farmer_f21.png'))
f22 = np.array(Image.open('scratch/farmer_f22.png'))
f23 = np.array(Image.open('scratch/farmer_f23.png'))

print("f20 vs f21 diff pixels:", (f20 != f21).any(axis=2).sum())
print("f21 vs f22 diff pixels:", (f21 != f22).any(axis=2).sum())
print("f22 vs f23 diff pixels:", (f22 != f23).any(axis=2).sum())
