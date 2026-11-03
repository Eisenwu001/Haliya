from PIL import Image
import numpy as np

im = Image.open('assets/platform_assets/Floor Tiles1.png')

# Let's inspect the 3x3 Wang / autotile blocks in Floor Tiles1.png
# Let's print out what tiles are in row 0..5, col 0..8
print("Checking transparent edges of tiles:")
for r in range(6):
    for c in range(9):
        tile = np.array(im.crop((c*32, r*32, (c+1)*32, (r+1)*32)))
        top_trans = (tile[0, :, 3] == 0).sum()
        bot_trans = (tile[31, :, 3] == 0).sum()
        left_trans = (tile[:, 0, 3] == 0).sum()
        right_trans = (tile[:, 31, 3] == 0).sum()
        total_nonz = (tile[:, :, 3] > 0).sum()
        if total_nonz > 0:
            print(f"({c}, {r}): nonz={total_nonz} L_trans={left_trans} R_trans={right_trans} T_trans={top_trans} B_trans={bot_trans}")
