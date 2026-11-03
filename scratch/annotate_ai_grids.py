import numpy as np
from PIL import Image

im2 = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_cave_platforms_spritesheet_1792544043909.jpg")
print("Image 2 format:", im2.size)

# Let's inspect where the objects are in im2
# It has width 1376, height 768.
# Let's do horizontal and vertical projection profiles to find clusters
arr = np.array(im2)
# Background is dark: let's see min/max and dark threshold
print("Arr min/max:", arr.min(), arr.max())
dark_bg = np.percentile(arr, 15)
print("Dark threshold ~:", dark_bg)

# Let's save a visual labeled grid of 1376x768 with coordinate markers
im_annotated = im2.copy()
from PIL import ImageDraw
draw = ImageDraw.Draw(im_annotated)
for x in range(0, 1376, 100):
    draw.line([(x, 0), (x, 768)], fill=(100, 100, 100))
    draw.text((x + 2, 5), str(x), fill=(255, 255, 0))
for y in range(0, 768, 100):
    draw.line([(0, y), (1376, y)], fill=(100, 100, 100))
    draw.text((5, y + 2), str(y), fill=(255, 255, 0))

im_annotated.save("scratch/im2_annotated_grid.png")
print("Saved scratch/im2_annotated_grid.png")

# Do the same for im1 (1024x1024)
im1 = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_subterranean_cave_tileset_1792544013682.jpg")
im1_annotated = im1.copy()
draw1 = ImageDraw.Draw(im1_annotated)
for x in range(0, 1024, 100):
    draw1.line([(x, 0), (x, 1024)], fill=(100, 100, 100))
    draw1.text((x + 2, 5), str(x), fill=(255, 255, 0))
for y in range(0, 1024, 100):
    draw1.line([(0, y), (1024, y)], fill=(100, 100, 100))
    draw1.text((5, y + 2), str(y), fill=(255, 255, 0))
im1_annotated.save("scratch/im1_annotated_grid.png")
print("Saved scratch/im1_annotated_grid.png")

# Do the same for im3 (1024x1024)
im3 = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\cave_tileset_spritesheet_1792544092516.jpg")
im3_annotated = im3.copy()
draw3 = ImageDraw.Draw(im3_annotated)
for x in range(0, 1024, 100):
    draw3.line([(x, 0), (x, 1024)], fill=(100, 100, 100))
    draw3.text((x + 2, 5), str(x), fill=(255, 255, 0))
for y in range(0, 1024, 100):
    draw3.line([(0, y), (1024, y)], fill=(100, 100, 100))
    draw3.text((5, y + 2), str(y), fill=(255, 255, 0))
im3_annotated.save("scratch/im3_annotated_grid.png")
print("Saved scratch/im3_annotated_grid.png")
