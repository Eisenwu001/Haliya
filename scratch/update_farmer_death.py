from PIL import Image, ImageEnhance
import numpy as np

sheet = Image.open('assets/rice_field/corrupted_farmer_spritesheet.png')
w, h = sheet.size
fw, fh = 96, 96

# Frame 21 is at row 3, col 3:
f21 = sheet.crop((3 * fw, 3 * fh, 4 * fw, 4 * fh))
arr_f21 = np.array(f21)

# Build Frame 22: Body starts dissolving, dark purple corruption aura/particles rising
arr_f22 = arr_f21.copy()
# Reduce body alpha slightly (e.g. 75% opacity) and tint towards corrupted purple
mask_body = arr_f22[:, :, 3] > 20
arr_f22[mask_body, 3] = (arr_f22[mask_body, 3] * 0.75).astype(np.uint8)
# Shift color slightly purple:
arr_f22[mask_body, 0] = np.clip(arr_f22[mask_body, 0].astype(int) + 30, 0, 255).astype(np.uint8)
arr_f22[mask_body, 2] = np.clip(arr_f22[mask_body, 2].astype(int) + 40, 0, 255).astype(np.uint8)

# Add rising purple smoke / corruption wisps above the body (rows 50..65, cols 35..65):
np.random.seed(42)
for y in range(48, 65):
    for x in range(35, 65):
        if np.random.rand() < 0.28:
            # purple smoke pixel
            arr_f22[y, x] = [170, 40, 210, np.random.randint(140, 230)]
        elif np.random.rand() < 0.15:
            # bright magenta core
            arr_f22[y, x] = [230, 80, 250, np.random.randint(160, 255)]

# Build Frame 23: Body mostly dissolved (35% opacity), smoke drifting higher (rows 40..60)
arr_f23 = arr_f21.copy()
# Faint dissolving silhouette:
arr_f23[mask_body, 3] = (arr_f23[mask_body, 3] * 0.35).astype(np.uint8)
arr_f23[mask_body, 0] = np.clip(arr_f23[mask_body, 0].astype(int) + 45, 0, 255).astype(np.uint8)
arr_f23[mask_body, 2] = np.clip(arr_f23[mask_body, 2].astype(int) + 60, 0, 255).astype(np.uint8)

# Rising ethereal embers:
for y in range(38, 62):
    for x in range(30, 70):
        if np.random.rand() < 0.20:
            arr_f23[y, x] = [160, 30, 220, np.random.randint(90, 180)]
        elif np.random.rand() < 0.08:
            arr_f23[y, x] = [240, 100, 255, np.random.randint(120, 220)]

# Paste updated frames back into spritesheet:
sheet_new = sheet.copy()
sheet_new.paste(Image.fromarray(arr_f22), (4 * fw, 3 * fh))
sheet_new.paste(Image.fromarray(arr_f23), (5 * fw, 3 * fh))

sheet_new.save('assets/rice_field/corrupted_farmer_spritesheet.png')
print("Successfully updated Corrupted Farmer death dissolution frames in assets/rice_field/corrupted_farmer_spritesheet.png!")
