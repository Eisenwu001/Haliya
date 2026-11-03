from PIL import Image

# Let's test different sizes: 100px wide (as in prompt table) vs 110px
# Prompt: "about 100 px wide | Top-left corner, bleeding slightly off the top and left edges."
raw = Image.open("assets/art/incoming/corner_fronds_left.png")
# If target size is 100 px wide:
scale = 100.0 / raw.width
scaled_h = round(raw.height * scale)
scaled_100 = raw.resize((100, scaled_h), Image.Resampling.NEAREST)
print(f"100px wide version size: 100x{scaled_h}")

# Check overlap if placed with bleed: e.g. pos = (-12, -18)
for pos_x, pos_y in [(-10, -18), (-16, -24), (-20, -28), (-24, -32)]:
    overlaps = 0
    for y in range(scaled_100.height):
        for x in range(scaled_100.width):
            if scaled_100.getpixel((x, y))[3] > 128:
                screen_x = x + pos_x
                screen_y = y + pos_y
                # Title box is x=26..200, y=48..90; Menu is x=26..200, y=100..340
                if 26 <= screen_x <= 200 and 48 <= screen_y <= 340:
                    overlaps += 1
    print(f"At position ({pos_x}, {pos_y}): overlaps with title/menu = {overlaps} pixels")
