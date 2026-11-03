from PIL import Image

shrine = Image.open("assets/art/incoming/totem_shrine.png")
# inspect rows from y=350 to y=430
for y in range(360, 430, 5):
    row = [shrine.getpixel((x, y)) for x in range(shrine.width)]
    # count pixels with alpha > 128
    opaque = [(x, p) for x, p in enumerate(row) if p[3] > 128]
    if opaque:
        min_x = min(x for x, p in opaque)
        max_x = max(x for x, p in opaque)
        # check if it's the wooden pole (width ~140) or the stone mound spreading out (width > 300)
        print(f"y={y}: opaque count={len(opaque)}, x_span={min_x}..{max_x} (width={max_x - min_x + 1})")
