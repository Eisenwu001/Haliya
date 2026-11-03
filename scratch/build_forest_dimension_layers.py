import numpy as np
from PIL import Image
from scipy.ndimage import label

USER_IMG = 'C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/.user_uploaded/media_1791102244648.png'
RAW_L2 = 'C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/rice_field_midground_layer2_1791096004300.jpg'
RAW_L3 = 'C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/rice_terraces_hills_layer3_1791096044337.jpg'
RAW_L4 = 'C:/Users/Lin/.gemini/antigravity/brain/92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2/mayon_volcano_layer4_1791096068295.jpg'

TARGET_W = 4256
TARGET_H = 720
HALF_W = 2128 # 4256 // 2

print("=== Building Layer 1 (4256x720) ===")
# 1. Load user image
img1 = Image.open(USER_IMG)
arr1 = np.array(img1)

# Clean alpha
arr1[arr1[:, :, 3] <= 3, 3] = 0
arr1[arr1[:, :, 3] >= 225, 3] = 255

# Pad 1 row of soil to make 360h
canvas_360 = np.zeros((360, 1024, 4), dtype=np.uint8)
canvas_360[:359] = arr1
canvas_360[359] = arr1[358]

# 2x integer scale -> 2128x720
img_360 = Image.fromarray(canvas_360)
tile_2128 = img_360.resize((HALF_W, TARGET_H), Image.Resampling.NEAREST)

# Assemble 4256x720 layer with 2 identical 2128 tiles
layer1_4256 = Image.new('RGBA', (TARGET_W, TARGET_H))
layer1_4256.paste(tile_2128, (0, 0))
layer1_4256.paste(tile_2128, (HALF_W, 0))
layer1_4256.save('assets/bicol_bg/Rice_Field_Layer1.png')
print("Saved Layer 1 (4256x720): assets/bicol_bg/Rice_Field_Layer1.png")

print("\n=== Building Layer 4: Mount Mayon (4256x720) ===")
# Load raw Mayon (1376x768)
img4_raw = Image.open(RAW_L4)
# Resize to height 720
w4_720 = int(img4_raw.width * TARGET_H / img4_raw.height) # ~1290
img4_720 = img4_raw.resize((w4_720, TARGET_H), Image.Resampling.LANCZOS)
arr4 = np.array(img4_720)
h4, w4, _ = arr4.shape

# Zero-hole skyline extraction
brightness4 = arr4.max(axis=2)
skyline4 = np.zeros(w4, dtype=int)
for col in range(w4):
    fg_indices = np.where(brightness4[:, col] > 20)[0]
    if len(fg_indices) > 0:
        skyline4[col] = fg_indices.min()
    else:
        skyline4[col] = h4

# Build solid alpha mask
alpha4 = np.zeros((h4, w4), dtype=np.uint8)
for col in range(w4):
    y_start = skyline4[col]
    alpha4[y_start:, col] = 255

# Clean plume top and stray specks
# Cloud puff at peak: cols ~600 to 760, rows 0 to 140
for r in range(0, 30):
    for c in range(600, 780):
        # Naturally round the top of the cloud puff
        dist = ((r - 28)**2 + ((c - 710)*0.7)**2)**0.5
        if dist > 28:
            alpha4[r, c] = 0

# Remove stray dark marks beside plume
for r in range(40, 90):
    for c in range(730, 770):
        if brightness4[r, c] < 50:
            alpha4[r, c] = 0

# Remove isolated tiny specks in sky
labeled4, num_features = label(alpha4 > 0)
for i in range(1, num_features + 1):
    comp_mask = labeled4 == i
    if np.count_nonzero(comp_mask) < 200:
        alpha4[comp_mask] = 0

rgba4 = np.dstack((arr4[:, :, :3], alpha4))
mayon_sprite = Image.fromarray(rgba4)

# Create 4256x720 layer with 2 centered Mayon volcanoes (one at center of each half)
layer4_4256 = Image.new('RGBA', (TARGET_W, TARGET_H), (0, 0, 0, 0))

pos1_x = (HALF_W - w4) // 2
pos2_x = HALF_W + pos1_x

layer4_4256.paste(mayon_sprite, (pos1_x, 0), mayon_sprite)
layer4_4256.paste(mayon_sprite, (pos2_x, 0), mayon_sprite)

# Fill background horizon between and around the volcanoes with tropical rainforest treeline
arr4_full = np.array(layer4_4256)
for col in range(TARGET_W):
    empty_rows = np.where(arr4_full[620:720, col, 3] == 0)[0]
    if len(empty_rows) > 0:
        sample_c = (col * 3) % w4
        for r_offset in range(100):
            r = 620 + r_offset
            if arr4_full[r, col, 3] == 0 and rgba4[r, sample_c, 3] > 0:
                arr4_full[r, col] = rgba4[r, sample_c]

layer4_4256 = Image.fromarray(arr4_full)
layer4_4256.save('assets/bicol_bg/Rice_Field_Layer4.png')
print("Saved Layer 4 (4256x720): assets/bicol_bg/Rice_Field_Layer4.png")

print("\n=== Building Layer 3: Terraced Ridges (4256x720) ===")
img3_raw = Image.open(RAW_L3)
w3_720 = int(img3_raw.width * TARGET_H / img3_raw.height)
img3_720 = img3_raw.resize((w3_720, TARGET_H), Image.Resampling.LANCZOS)
arr3 = np.array(img3_720)
h3, w3, _ = arr3.shape

brightness3 = arr3.max(axis=2)
skyline3 = np.zeros(w3, dtype=int)
for col in range(w3):
    fg_indices = np.where(brightness3[:, col] > 20)[0]
    skyline3[col] = fg_indices.min() if len(fg_indices) > 0 else h3

alpha3 = np.zeros((h3, w3), dtype=np.uint8)
for col in range(w3):
    alpha3[skyline3[col]:, col] = 255

rgba3 = np.dstack((arr3[:, :, :3], alpha3))
img3_clean = Image.fromarray(rgba3)

tile3_2128 = img3_clean.resize((HALF_W, TARGET_H), Image.Resampling.LANCZOS)
arr3_t = np.array(tile3_2128)
for c in range(32):
    factor = c / 32.0
    arr3_t[:, c, :3] = (arr3_t[:, c, :3] * factor + arr3_t[:, HALF_W - 32 + c, :3] * (1.0 - factor)).astype(np.uint8)
tile3_2128 = Image.fromarray(arr3_t)

layer3_4256 = Image.new('RGBA', (TARGET_W, TARGET_H))
layer3_4256.paste(tile3_2128, (0, 0))
layer3_4256.paste(tile3_2128, (HALF_W, 0))
layer3_4256.save('assets/bicol_bg/Rice_Field_Layer3.png')
print("Saved Layer 3 (4256x720): assets/bicol_bg/Rice_Field_Layer3.png")

print("\n=== Building Layer 2: Midground Terraced Paddies (4256x720) ===")
img2_raw = Image.open(RAW_L2)
w2_720 = int(img2_raw.width * TARGET_H / img2_raw.height)
img2_720 = img2_raw.resize((w2_720, TARGET_H), Image.Resampling.LANCZOS)
arr2 = np.array(img2_720)
h2, w2, _ = arr2.shape

brightness2 = arr2.max(axis=2)
alpha2 = np.zeros((h2, w2), dtype=np.uint8)
for col in range(w2):
    fg = np.where(brightness2[:, col] > 22)[0]
    if len(fg) > 0:
        y_top = fg.min()
        alpha2[y_top:, col] = 255

trapped_sky = (brightness2 <= 20) & (np.arange(h2)[:, None] < 500)
alpha2[trapped_sky] = 0

labeled2, num_features = label(alpha2 > 0)
for i in range(1, num_features + 1):
    comp_mask = labeled2 == i
    if np.count_nonzero(comp_mask) < 200:
        alpha2[comp_mask] = 0

rgba2 = np.dstack((arr2[:, :, :3], alpha2))
img2_clean = Image.fromarray(rgba2)

tile2_2128 = img2_clean.resize((HALF_W, TARGET_H), Image.Resampling.LANCZOS)
arr2_t = np.array(tile2_2128)
for c in range(32):
    factor = c / 32.0
    arr2_t[:, c, :3] = (arr2_t[:, c, :3] * factor + arr2_t[:, HALF_W - 32 + c, :3] * (1.0 - factor)).astype(np.uint8)
tile2_2128 = Image.fromarray(arr2_t)

layer2_4256 = Image.new('RGBA', (TARGET_W, TARGET_H))
layer2_4256.paste(tile2_2128, (0, 0))
layer2_4256.paste(tile2_2128, (HALF_W, 0))
layer2_4256.save('assets/bicol_bg/Rice_Field_Layer2.png')
print("Saved Layer 2 (4256x720): assets/bicol_bg/Rice_Field_Layer2.png")

print("\nAll 4 layers built successfully at 4256x720!")
