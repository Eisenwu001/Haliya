from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im, dtype=float)
H, W, _ = arr.shape

# In bahay_kubo:
# Background is magenta/purple (high R, high B, low G)
# Hut itself is wood, sawali bamboo, thatch (amber, golden, brown, green)
# Let's check G channel vs (R+B)/2:
diff = ((arr[:, :, 0] + arr[:, :, 2]) / 2.0) - arr[:, :, 1]
# For magenta bg: R~255, B~255, G~10 => diff ~ 245
# For thatch/wood: R~150, B~60, G~100 => (R+B)/2 ~ 105, G~100 => diff ~ 5
# For dark shadow in wood: R~30, G~20, B~15 => diff ~ 2
# So diff > 50 AND arr[:, :, 1] < 100 identifies the magenta background flawlessly!

is_bg = (diff > 50) & (arr[:, :, 1] < 90)
print("Background percentage:", is_bg.sum() / is_bg.size * 100)

alpha = np.where(is_bg, 0, 255).astype(np.uint8)

# Check bounds of foreground:
ys, xs = np.where(~is_bg)
print(f"Foreground bounds: x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")

rgba = np.zeros((H, W, 4), dtype=np.uint8)
rgba[:, :, :3] = np.clip(arr, 0, 255).astype(np.uint8)
rgba[:, :, 3] = alpha

# Crop tightly:
crop = Image.fromarray(rgba).crop((xs.min(), ys.min(), xs.max()+1, ys.max()+1))

# Scale to target platformer size:
# In Godot 640x360:
# Ground is at y=288.0.
# A Bahay Kubo height of ~160px and width of ~192px fits beautifully on the paddy terrace!
target_w = 192
aspect = crop.size[1] / crop.size[0]
target_h = int(target_w * aspect)
kubo_clean = crop.resize((target_w, target_h), Image.Resampling.LANCZOS)

# Check white pixels:
arr_k = np.array(kubo_clean)
w_px = (arr_k[:, :, 0] > 240) & (arr_k[:, :, 1] > 240) & (arr_k[:, :, 2] > 240) & (arr_k[:, :, 3] > 0)
print(f"White pixels in clean Bahay Kubo: {np.count_nonzero(w_px)}")

kubo_clean.save("assets/rice_field/bahay_kubo.png")
print(f"Saved assets/rice_field/bahay_kubo.png ({kubo_clean.size}) successfully!")
