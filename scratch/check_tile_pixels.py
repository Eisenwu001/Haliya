from PIL import Image

im = Image.open('assets/platform_assets/Floor Tiles1.png')

# Let's inspect the layout of Floor Tiles1.png:
# Typically in 2D platformer tilesets:
# (0,0)=top-left corner, (1,0)=top edge, (2,0)=top-right corner
# (0,1)=left edge, (1,1)=center fill, (2,1)=right edge
# (0,2)=bottom-left corner, (1,2)=bottom edge, (2,2)=bottom-right corner

# Let's verify what pixels are in these tiles:
for r in range(4):
    for c in range(4):
        tile = im.crop((c*32, r*32, (c+1)*32, (r+1)*32))
        # check alpha and average color
        import numpy as np
        arr = np.array(tile)
        nonz = np.count_nonzero(arr[:, :, 3] > 10)
        print(f"({c}, {r}): nonz={nonz}")
