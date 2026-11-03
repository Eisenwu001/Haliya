from PIL import Image
import numpy as np

# Let's inspect the transition at col 21->22 in level_2_1
# Let's generate an image rendering the actual tiles of cols 19..25, rows 7..12
import base64, struct, re

with open("scenes/rice_field/level_2_1.tscn", "r", encoding="utf-8") as f:
    text = f.read()

m = re.search(r'name="BaseGround"[\s\S]*?PackedByteArray\("([^"]+)"\)', text)
data = base64.b64decode(m.group(1))

cells = {}
for i in range(2, len(data), 12):
    col, row, src, ax, ay, alt = struct.unpack('<hhhhhh', data[i:i+12])
    cells[(col, row)] = (ax, ay)

tileset_img = Image.open('assets/platform_assets/Floor Tiles1.png')

# Let's render cols 18..26, rows 6..13
canvas = Image.new("RGBA", (9 * 32, 8 * 32), (0, 0, 0, 0))
for c_idx, c in enumerate(range(18, 27)):
    for r_idx, r in enumerate(range(6, 14)):
        if (c, r) in cells:
            ax, ay = cells[(c, r)]
            tile = tileset_img.crop((ax * 32, ay * 32, (ax + 1) * 32, (ay + 1) * 32))
            canvas.paste(tile, (c_idx * 32, r_idx * 32))

canvas.save("scratch/transition_render_21_22.png")
print("Saved scratch/transition_render_21_22.png")
