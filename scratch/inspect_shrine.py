from PIL import Image

img = Image.open(r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\art\incoming\totem_shrine.png")
print("totem_shrine size:", img.size)
# inspect alpha bounding box
bbox = img.split()[-1].getbbox()
print("bbox:", bbox)

# inspect rows: find where the stone base / roots / candles start vs the totem trunk
for y in range(bbox[1], bbox[3], 20):
    row_px = [img.getpixel((x, y)) for x in range(bbox[0], bbox[2])]
    opaque = [p for p in row_px if p[3] > 128]
    if opaque:
        avg_r = sum(p[0] for p in opaque) // len(opaque)
        avg_g = sum(p[1] for p in opaque) // len(opaque)
        avg_b = sum(p[2] for p in opaque) // len(opaque)
        # find min and max x
        xs = [x for x in range(bbox[0], bbox[2]) if img.getpixel((x, y))[3] > 128]
        print(f"y={y:3d}: count={len(opaque):3d}, x_range=({min(xs):3d}..{max(xs):3d}, width={max(xs)-min(xs)+1:3d}), avg=({avg_r:3d}, {avg_g:3d}, {avg_b:3d})")
