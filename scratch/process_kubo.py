from PIL import Image
import numpy as np

im = Image.open('scratch/kubo_chromakey.png')
arr = np.array(im)
alpha = arr[:, :, 3]
ys, xs = np.where(alpha > 30)
print(f"Bahay Kubo tight bounds: x=({xs.min()}..{xs.max()}) w={xs.max()-xs.min()+1}, y=({ys.min()}..{ys.max()}) h={ys.max()-ys.min()+1}")

# Crop to tight bounds
crop = im.crop((xs.min(), ys.min(), xs.max() + 1, ys.max() + 1))
print("Cropped size:", crop.size)

# In Godot 640x360:
# A Bahay Kubo should be around 160-220px wide, and ~160-200px tall (a substantial stilt house that Haliya can run under and jump on top of).
# Let's see: if width is ~180px, height is ~180 * (crop.size[1] / crop.size[0]):
aspect = crop.size[1] / crop.size[0]
target_w = 192
target_h = int(target_w * aspect)
print(f"Target size in game: {target_w}x{target_h}")

kubo_game = crop.resize((target_w, target_h), Image.Resampling.LANCZOS)
# Clean any residual magenta fringe:
arr_k = np.array(kubo_game)
is_magenta_fringe = (arr_k[:, :, 0] > 180) & (arr_k[:, :, 1] < 80) & (arr_k[:, :, 2] > 180)
print("Magenta fringe pixels:", is_magenta_fringe.sum())
arr_k[is_magenta_fringe, 3] = 0

# Also check for pixels with high red and blue but low green on transparent boundaries:
fringe = (arr_k[:, :, 0] > 150) & (arr_k[:, :, 1] < 100) & (arr_k[:, :, 2] > 150) & (arr_k[:, :, 3] < 180)
arr_k[fringe, 3] = 0

clean_kubo = Image.fromarray(arr_k)
clean_kubo.save("assets/rice_field/bahay_kubo.png")
print("Saved assets/rice_field/bahay_kubo.png successfully!")
