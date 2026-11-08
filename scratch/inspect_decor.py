from PIL import Image

im = Image.open('assets/platform_assets/Decor.png')
# Decor.png is 416x544 -> 13 cols x 17 rows of 32x32 tiles!
print('Decor.png cols:', im.size[0]//32, 'rows:', im.size[1]//32)

# Save an image with grid labels so we can see what each tile looks like
grid = im.copy()
from PIL import ImageDraw
draw = ImageDraw.Draw(grid)
for x in range(0, im.size[0], 32):
    draw.line([(x, 0), (x, im.size[1])], fill=(255, 0, 0, 128))
for y in range(0, im.size[1], 32):
    draw.line([(0, y), (im.size[0], y)], fill=(255, 0, 0, 128))
grid.save('scratch/decor_grid.png')
print('Saved scratch/decor_grid.png')
