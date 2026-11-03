from PIL import Image
import numpy as np

sheet = Image.open('assets/rice_field/corrupted_farmer_spritesheet.png')
arr = np.array(sheet)
w, h = sheet.size
fw, fh = 96, 96

# In Frame 18:
# It had 1128 white pixels because it was a white flash mask!
# Frame 19 is a great colored flinch/stagger frame!
# If we replace Frame 18 with a slightly leaned back pose of Frame 19 (e.g. initial recoil 1px forward or rotated slightly),
# then Frame 18 becomes a real colored flinch frame with 0 white pixels!
f19 = arr[3*fh:4*fh, 1*fw:2*fw].copy()
# Frame 18 is initial impact recoil:
f18_new = f19.copy()
# Shift f18 slightly down/right (initial impact compression):
f18_shifted = np.zeros_like(f18_new)
f18_shifted[1:, 1:] = f18_new[:-1, :-1]
arr[3*fh:4*fh, 0*fw:1*fw] = f18_shifted

# Now let's clean stray white guide/artifact pixels (R>230, G>230, B>230, A>0):
# These white pixels are unwanted artifact lines (like the tick at y=55..57 in f0, f2, f3, f4, f5, f17)
# Let's inspect where they are and replace them with local neighborhood color
w_mask = (arr[:, :, 0] > 230) & (arr[:, :, 1] > 230) & (arr[:, :, 2] > 230) & (arr[:, :, 3] > 0)
print(f"Total white pixels before cleanup: {w_mask.sum()}")

# In painting: for every white pixel, replace it with the median/average of its non-white opaque neighbors,
# or set alpha to 0 if surrounded by transparent pixels
H, W, _ = arr.shape
cleaned = arr.copy()
for y, x in zip(*np.where(w_mask)):
    neighbors = []
    for dy in [-1, 0, 1]:
        for dx in [-1, 0, 1]:
            ny, nx = y + dy, x + dx
            if 0 <= ny < H and 0 <= nx < W and not (dy == 0 and dx == 0):
                if arr[ny, nx, 3] > 20 and not w_mask[ny, nx]:
                    neighbors.append(arr[ny, nx, :3])
    if len(neighbors) >= 2:
        # Blend with neighbors
        cleaned[y, x, :3] = np.mean(neighbors, axis=0).astype(np.uint8)
    else:
        # Stray floating pixel on border, remove
        cleaned[y, x, 3] = 0

arr_check = np.array(cleaned)
w_after = (arr_check[:, :, 0] > 230) & (arr_check[:, :, 1] > 230) & (arr_check[:, :, 2] > 230) & (arr_check[:, :, 3] > 0)
print(f"Total white pixels after cleanup: {w_after.sum()}")

Image.fromarray(cleaned).save("assets/rice_field/corrupted_farmer_spritesheet.png")
print("Saved cleaned assets/rice_field/corrupted_farmer_spritesheet.png")
