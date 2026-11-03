from PIL import Image
import numpy as np

path = r'C:\Users\Lin\.gemini\antigravity\brain\affaaa51-5c2e-4029-96b6-27d506de5489\bahay_kubo_1792799770439.jpg'
im = Image.open(path)
arr = np.array(im, dtype=float)

# Background is purple/magenta: high red, high blue, low green
# Green channel is very low in the background, while in the hut (wood, thatch, sawali, bamboo) green/yellow/brown has G >= 60-150 and R ~ B is FALSE!
# Notice: Wood and thatch are golden/brown/bamboo: R is high, G is medium, B is LOW!
# Magenta background: R is high, B is high, G is LOW!
is_purple_bg = (arr[:, :, 1] < 100) & (arr[:, :, 0] > 40) & (arr[:, :, 2] > 40) & (np.abs(arr[:, :, 0] - arr[:, :, 2]) < 60)
print("Is purple bg fraction:", is_purple_bg.sum() / (arr.shape[0] * arr.shape[1]))

# What about the border pixels?
for name, strip in [("row 0", is_purple_bg[0, :]), ("row -1", is_purple_bg[-1, :]), ("col 0", is_purple_bg[:, 0]), ("col -1", is_purple_bg[:, -1])]:
    print(f"{name}: purple bg = {strip.sum()} / {len(strip)}")
