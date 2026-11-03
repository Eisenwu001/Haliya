import numpy as np
from PIL import Image
from collections import deque
from scipy.ndimage import label

CANVAS_H = 360

# ═════════════════════════════════════════════════════════════════════════════
# 1. LAYER 4: MOUNT MAYON (100% SOLID, ZERO HOLES, RAZOR-SHARP)
# ═════════════════════════════════════════════════════════════════════════════
print("Processing Layer 4 (Mount Mayon)...")
raw_l4 = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\mayon_volcano_layer4_1791096068295.jpg")
arr_l4 = np.array(raw_l4)
h4, w4 = arr_l4.shape[:2] # 768, 1376

# Geometric skyline trace:
# Slope from peak (x=688, y=130) descending left to (0, 493) and right to (1375, 493)
slope_y = np.zeros(w4, dtype=int)
for x in range(w4):
    if x <= 688:
        for y in range(h4):
            if arr_l4[y, x].max() > 18:
                slope_y[x] = y
                break
    else:
        for y in range(125, h4):
            if arr_l4[y, x].max() > 18:
                slope_y[x] = y
                break

# Solid mask: everything at and below slope_y is 100% solid mountain/forest!
mask_l4 = np.zeros((h4, w4), dtype=bool)
for x in range(w4):
    mask_l4[slope_y[x]:, x] = True

# Add smoke plume above peak (y < 135, x between 640 and 820 where brightness > 25):
smoke = (arr_l4.max(axis=2) > 25) & (np.arange(h4)[:, None] < 135) & (np.arange(w4)[None, :] >= 640) & (np.arange(w4)[None, :] <= 820)
mask_l4 = mask_l4 | smoke

alpha_l4 = (mask_l4.astype(np.uint8)) * 255

rgba_l4 = np.zeros((h4, w4, 4), dtype=np.uint8)
rgba_l4[:, :, :3] = arr_l4
rgba_l4[:, :, 3] = alpha_l4

img_l4 = Image.fromarray(rgba_l4, "RGBA")

# Scale proportionally to height 360 with NEAREST for razor-sharp pixel art:
scale_4 = 360.0 / h4
w4_360 = int(round(w4 * scale_4)) # 645
l4_sharp = img_l4.resize((w4_360, 360), Image.Resampling.NEAREST)

# Ensure left edge and right edge match seamlessly:
arr4 = np.array(l4_sharp)
# Smooth 16-pixel blend at border:
for i in range(16):
    weight = 0.5 * (1.0 - np.cos(np.pi * (i + 1) / 17.0))
    xl = i
    xr = w4_360 - 16 + i
    col_l = arr4[:, xl].astype(float)
    col_r = arr4[:, xr].astype(float)
    blend = (1.0 - weight) * col_r + weight * col_l
    arr4[:, xl] = ((1.0 - weight) * col_l + weight * blend).astype(np.uint8)
    arr4[:, xr] = ((1.0 - weight) * blend + weight * col_r).astype(np.uint8)

l4_final = Image.fromarray(arr4, "RGBA")
l4_final.save(r"assets\bicol_bg\Rice_Field_Layer4.png")
print(f"Saved Rice_Field_Layer4.png ({w4_360}x360, ZERO holes).")


# ═════════════════════════════════════════════════════════════════════════════
# 2. LAYER 3: DISTANT TERRACED HILLS (SHARP, NATURAL ASPECT RATIO)
# ═════════════════════════════════════════════════════════════════════════════
print("Processing Layer 3 (Distant Terraced Hills)...")
raw_l3 = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\rice_terraces_hills_layer3_1791096044337.jpg")
arr_l3 = np.array(raw_l3)
h3, w3 = arr_l3.shape[:2]

# Trace skyline of hills:
hill_skyline = np.zeros(w3, dtype=int)
for x in range(w3):
    for y in range(h3):
        if arr_l3[y, x].max() > 20:
            hill_skyline[x] = y
            break

mask_l3 = np.zeros((h3, w3), dtype=bool)
for x in range(w3):
    mask_l3[hill_skyline[x]:, x] = True

alpha_l3 = (mask_l3.astype(np.uint8)) * 255
rgba_l3 = np.zeros((h3, w3, 4), dtype=np.uint8)
rgba_l3[:, :, :3] = arr_l3
rgba_l3[:, :, 3] = alpha_l3

img_l3 = Image.fromarray(rgba_l3, "RGBA")
w3_360 = int(round(w3 * (360.0 / h3))) # 645
l3_sharp = img_l3.resize((w3_360, 360), Image.Resampling.NEAREST)

arr3 = np.array(l3_sharp)
for i in range(16):
    weight = 0.5 * (1.0 - np.cos(np.pi * (i + 1) / 17.0))
    xl = i
    xr = w3_360 - 16 + i
    col_l = arr3[:, xl].astype(float)
    col_r = arr3[:, xr].astype(float)
    blend = (1.0 - weight) * col_r + weight * col_l
    arr3[:, xl] = ((1.0 - weight) * col_l + weight * blend).astype(np.uint8)
    arr3[:, xr] = ((1.0 - weight) * blend + weight * col_r).astype(np.uint8)

l3_final = Image.fromarray(arr3, "RGBA")
l3_final.save(r"assets\bicol_bg\Rice_Field_Layer3.png")
print(f"Saved Rice_Field_Layer3.png ({w3_360}x360).")


# ═════════════════════════════════════════════════════════════════════════════
# 3. LAYER 2: MIDGROUND RICE PADDIES & BAHAY KUBO (SHARP, NATURAL ASPECT RATIO)
# ═════════════════════════════════════════════════════════════════════════════
print("Processing Layer 2 (Midground Rice Paddies)...")
raw_l2 = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\rice_field_midground_layer2_1791096004300.jpg")
arr_l2 = np.array(raw_l2)
h2, w2 = arr_l2.shape[:2]

# Flood fill outer sky from top row and upper sides:
brightness_l2 = arr_l2.max(axis=2)
bg_mask_l2 = np.zeros((h2, w2), dtype=bool)
q2 = deque([(x, 0) for x in range(w2) if brightness_l2[0, x] <= 20])
for x, y in q2:
    bg_mask_l2[y, x] = True
while q2:
    cx, cy = q2.popleft()
    for dx, dy in ((-1,0), (1,0), (0,-1), (0,1)):
        nx, ny = cx + dx, cy + dy
        if 0 <= nx < w2 and 0 <= ny < h2:
            if not bg_mask_l2[ny, nx] and brightness_l2[ny, nx] <= 20:
                bg_mask_l2[ny, nx] = True
                q2.append((nx, ny))

# Also clear trapped black sky pockets between bamboo stalks / palm trunks above paddies (y < 460):
trapped_sky_l2 = (brightness_l2 <= 20) & (np.arange(h2)[:, None] < 460)
bg_mask_l2 = bg_mask_l2 | trapped_sky_l2

alpha_l2 = np.ones((h2, w2), dtype=np.uint8) * 255
alpha_l2[bg_mask_l2] = 0

rgba_l2 = np.zeros((h2, w2, 4), dtype=np.uint8)
rgba_l2[:, :, :3] = arr_l2
rgba_l2[:, :, 3] = alpha_l2

img_l2 = Image.fromarray(rgba_l2, "RGBA")
w2_360 = int(round(w2 * (360.0 / h2))) # 645
l2_sharp = img_l2.resize((w2_360, 360), Image.Resampling.NEAREST)

arr2 = np.array(l2_sharp)
for i in range(16):
    weight = 0.5 * (1.0 - np.cos(np.pi * (i + 1) / 17.0))
    xl = i
    xr = w2_360 - 16 + i
    col_l = arr2[:, xl].astype(float)
    col_r = arr2[:, xr].astype(float)
    blend = (1.0 - weight) * col_r + weight * col_l
    arr2[:, xl] = ((1.0 - weight) * col_l + weight * blend).astype(np.uint8)
    arr2[:, xr] = ((1.0 - weight) * blend + weight * col_r).astype(np.uint8)

l2_final = Image.fromarray(arr2, "RGBA")
l2_final.save(r"assets\bicol_bg\Rice_Field_Layer2.png")
print(f"Saved Rice_Field_Layer2.png ({w2_360}x360).")


# ═════════════════════════════════════════════════════════════════════════════
# 4. LAYER 1: FOREGROUND USER ARTWORK (BIT-EXACT 1:1 NATIVE PIXEL ART)
# ═════════════════════════════════════════════════════════════════════════════
print("Processing Layer 1 (User Original Artwork)...")
raw_l1 = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\.user_uploaded\media_1791088885584.png")
arr_l1 = np.array(raw_l1)
h1, w1 = arr_l1.shape[:2] # 341, 1024

# Extract alpha cleanly from black sky:
brightness_l1 = arr_l1[:, :, :3].max(axis=2)
bg_mask_l1 = np.zeros((h1, w1), dtype=bool)
q1 = deque([(x, 0) for x in range(w1) if brightness_l1[0, x] <= 20])
for x, y in q1:
    bg_mask_l1[y, x] = True
while q1:
    cx, cy = q1.popleft()
    for dx, dy in ((-1,0), (1,0), (0,-1), (0,1)):
        nx, ny = cx + dx, cy + dy
        if 0 <= nx < w1 and 0 <= ny < h1:
            if not bg_mask_l1[ny, nx] and brightness_l1[ny, nx] <= 20:
                bg_mask_l1[ny, nx] = True
                q1.append((nx, ny))

trapped_sky_l1 = (brightness_l1 <= 20) & (np.arange(h1)[:, None] < 270)
bg_mask_l1 = bg_mask_l1 | trapped_sky_l1

alpha_l1 = np.ones((h1, w1), dtype=np.uint8) * 255
alpha_l1[bg_mask_l1] = 0

# Native 1024x360: NO RESIZING OF PIXELS!
rgba_l1 = np.zeros((CANVAS_H, w1, 4), dtype=np.uint8)
# Keep original 341 rows untouched at top:
rgba_l1[:h1, :, :3] = arr_l1[:, :, :3]
rgba_l1[:h1, :, 3] = alpha_l1
# Pad the bottom 19 rows with soil cross section:
for y in range(h1, CANVAS_H):
    rgba_l1[y, :, :3] = arr_l1[h1 - 1, :, :3]
    rgba_l1[y, :, 3] = 255

# 8-pixel seam wrap on fence/soil:
for i in range(8):
    weight = 0.5 * (1.0 - np.cos(np.pi * (i + 1) / 9.0))
    xl = i
    xr = w1 - 8 + i
    col_l = rgba_l1[:, xl].astype(float)
    col_r = rgba_l1[:, xr].astype(float)
    blend = (1.0 - weight) * col_r + weight * col_l
    rgba_l1[:, xl] = ((1.0 - weight) * col_l + weight * blend).astype(np.uint8)
    rgba_l1[:, xr] = ((1.0 - weight) * blend + weight * col_r).astype(np.uint8)

l1_final = Image.fromarray(rgba_l1, "RGBA")
l1_final.save(r"assets\bicol_bg\Rice_Field_Layer1.png")
print(f"Saved Rice_Field_Layer1.png (1024x360, 100% BIT-EXACT 1:1 PIXEL ART).")

print("ALL 4 LAYERS SUCCESSFULLY BUILT AND DEPLOYED!")
