from PIL import Image

im = Image.open('assets/platform_assets/Floor Tiles2.png')

print("Floor Tiles2 details:")
for r in range(18):
    desc = []
    for c in range(9):
        tile = im.crop((c*32, r*32, (c+1)*32, (r+1)*32))
        ext = tile.getextrema()
        if len(ext) == 4 and ext[3][1] > 0:
            desc.append(f"({c},{r})")
    print(f"Row {r:02d}: {len(desc)} tiles -> {' '.join(desc[:5])}...")

im_other = Image.open('assets/platform_assets/Other Tiles2.png')
print("\nOther Tiles2 details:")
for r in range(7):
    desc = []
    for c in range(9):
        tile = im_other.crop((c*32, r*32, (c+1)*32, (r+1)*32))
        ext = tile.getextrema()
        if len(ext) == 4 and ext[3][1] > 0:
            desc.append(f"({c},{r})")
    print(f"Row {r:02d}: {len(desc)} tiles -> {' '.join(desc[:5])}...")

im_ores = Image.open('assets/platform_assets/Ores.png')
print(f"\nOres details: {im_ores.size}")
