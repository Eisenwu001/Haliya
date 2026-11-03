from PIL import Image

im = Image.open('assets/platform_assets/Floor Tiles1.png')
w, h = im.size
tw, th = 32, 32
cols = w // tw
rows = h // th

print(f"Floor Tiles1.png: {cols} cols, {rows} rows")

# Let's crop a sample grid with grid lines and labels so we know what every tile is!
annotated = im.copy()
from PIL import ImageDraw
draw = ImageDraw.Draw(annotated)
for r in range(rows):
    for c in range(cols):
        draw.rectangle((c*tw, r*th, (c+1)*tw, (r+1)*th), outline=(255, 0, 0, 128))
        draw.text((c*tw+2, r*th+2), f"{c},{r}", fill=(255, 255, 255, 255))

annotated.save("scratch/floor_tiles1_indexed.png")
print("Saved scratch/floor_tiles1_indexed.png")
