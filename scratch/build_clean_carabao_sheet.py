import os
from PIL import Image
import numpy as np

raw = Image.open('assets/rice_field/carabao_raw.png')

FRAME_W = 120
FRAME_H = 84
TOTAL_FRAMES = 5

# Target scale:
target_h = 52
aspect = raw.size[0] / raw.size[1]
target_w = int(target_h * aspect) # ~70px
base_scaled = raw.resize((target_w, target_h), Image.Resampling.LANCZOS)

x_pos = (FRAME_W - target_w) // 2 # 25
y_pos = 12

# Frame 0: Clean Neutral Base
f0 = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
f0.paste(base_scaled, (x_pos, y_pos))

# Frame 1: Flank breathing rise (chest & flank gently rise 1px)
arr_base = np.array(f0)
arr_f1 = arr_base.copy()
for y in range(14, 46):
    factor = np.sin((y - 14) / (46 - 14) * np.pi)
    if factor > 0.4:
        arr_f1[y - 1, :, :] = arr_base[y, :, :]
arr_f1[48:, :, :] = arr_base[48:, :, :]
f1 = Image.fromarray(arr_f1)

# Frame 2: Ear flick & horn tilt
arr_f2 = arr_base.copy()
for y in range(12, 30):
    for x in range(25, 45):
        if arr_base[y, x, 3] > 20:
            arr_f2[y - 1, max(0, x - 1), :] = arr_base[y, x, :]
f2 = Image.fromarray(arr_f2)

# Frame 3: Cud chew / tail flick
arr_f3 = arr_base.copy()
for y in range(30, 46):
    for x in range(25, 40):
        if arr_base[y, x, 3] > 20:
            arr_f3[y, min(FRAME_W - 1, x + 1), :] = arr_base[y, x, :]
for y in range(30, 50):
    for x in range(78, 95):
        if arr_base[y, x, 3] > 20:
            arr_f3[y, min(FRAME_W - 1, x + 1), :] = arr_base[y, x, :]
f3 = Image.fromarray(arr_f3)

# Frame 4: Squish reaction
squish_h = target_h - 3 # 49px
squish_w = target_w + 3 # 73px
squish_scaled = raw.resize((squish_w, squish_h), Image.Resampling.LANCZOS)
f4_x = (FRAME_W - squish_w) // 2
f4_y = 64 - squish_h
f4 = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
f4.paste(squish_scaled, (f4_x, f4_y))

# Combine into sheet
sheet = Image.new("RGBA", (FRAME_W * TOTAL_FRAMES, FRAME_H), (0, 0, 0, 0))
sheet.paste(f0, (0 * FRAME_W, 0))
sheet.paste(f1, (1 * FRAME_W, 0))
sheet.paste(f2, (2 * FRAME_W, 0))
sheet.paste(f3, (3 * FRAME_W, 0))
sheet.paste(f4, (4 * FRAME_W, 0))

out_path = 'assets/rice_field/carabao_spritesheet.png'
sheet.save(out_path)
print(f"Saved {out_path}")

arr_sheet = np.array(sheet)
for i in range(TOTAL_FRAMES):
    sub = arr_sheet[:, i*FRAME_W:(i+1)*FRAME_W, :]
    ys, xs = np.where(sub[:, :, 3] > 20)
    s_ys, _ = np.where(sub[:, 40:80, 3] > 20)
    print(f"Frame {i}: COM=({xs.mean():.1f}, {ys.mean():.1f}), x range=({xs.min()}..{xs.max()}), y range=({ys.min()}..{ys.max()}), spine top y={s_ys.min()}, hooves y={ys.max()}")
