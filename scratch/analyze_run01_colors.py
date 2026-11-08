from PIL import Image
from collections import Counter
import numpy as np

img = Image.open('assets/haliya/common_12_run01.png').convert('RGBA')
arr = np.array(img)

# Print color counts
counts = Counter([tuple(c) for c in arr.reshape(-1, 4) if c[3] > 0])
print('Original run01 colors:')
for col, cnt in counts.most_common(15):
    print(f'  {col}: {cnt}')
