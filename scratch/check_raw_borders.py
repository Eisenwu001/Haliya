from PIL import Image
import numpy as np

raw = Image.open('assets/rice_field/carabao_raw.png')
arr = np.array(raw)

# Check top row (y=0), bottom row (y=655), left col (x=0), right col (x=881)
for side, line, is_x in [("Top", arr[0, :, :], False),
                          ("Bottom", arr[-1, :, :], False),
                          ("Left", arr[:, 0, :], True),
                          ("Right", arr[:, -1, :], True)]:
    nonz_indices = np.where(line[:, 3] > 0)[0]
    print(f"{side}: {len(nonz_indices)} non-zero pixels, range: {nonz_indices.min() if len(nonz_indices) else None}..{nonz_indices.max() if len(nonz_indices) else None}")
    if len(nonz_indices) > 0:
        sample = line[nonz_indices[0]]
        print(f"  sample pixel: {sample}")
