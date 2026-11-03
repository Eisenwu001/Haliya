import math
from PIL import Image, ImageDraw

# ── 1. Moon Pearl Pickup (24x24 pixel art) ───────────────────────────────────
img_pearl = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
draw = ImageDraw.Draw(img_pearl)

# Outer celestial glow
for r in range(10, 5, -1):
    alpha = int(45 * (11 - r) / 5)
    draw.ellipse([12 - r, 12 - r, 12 + r, 12 + r], fill=(120, 220, 255, alpha))

# Pearl body
draw.ellipse([6, 6, 18, 18], fill=(225, 245, 255, 255), outline=(90, 160, 210, 255))
# Inner pearlescent shading
draw.ellipse([7, 8, 17, 18], fill=(185, 220, 245, 255))
draw.ellipse([8, 8, 16, 16], fill=(210, 235, 255, 255))
# Specular crescent gleam
draw.ellipse([8, 7, 13, 11], fill=(255, 255, 255, 255))
draw.point((10, 8), fill=(255, 255, 255, 255))
draw.point((14, 14), fill=(160, 205, 245, 255))

img_pearl.save("assets/props/pickup_moon_pearl.png")
print("Saved assets/props/pickup_moon_pearl.png")

# ── 2. Santelmo Spirit Flame Spritesheet (6 frames of 48x48 = 288x48) ────────
frame_w, frame_h = 48, 48
sheet = Image.new("RGBA", (frame_w * 6, frame_h), (0, 0, 0, 0))

for f in range(6):
    frame = Image.new("RGBA", (frame_w, frame_h), (0, 0, 0, 0))
    f_draw = ImageDraw.Draw(frame)
    phase = f * (math.pi / 3.0)
    cx, cy = 24, 26 + int(math.sin(phase) * 2.0)
    
    # Outer heat aura (soft cyan / teal)
    for r in range(18, 8, -1):
        alpha = int(35 * (19 - r) / 10)
        f_draw.ellipse([cx - r, cy - r - 2, cx + r, cy + r - 2], fill=(30, 140, 240, alpha))
    
    # Fire teardrop body
    for layer in range(5):
        scale_r = 12 - layer * 2
        flicker_y = int(math.sin(phase + layer) * 2.5)
        # Gradient colors from outer cyan to inner pure white
        col_outer = (40, 180, 255, 230)
        col_mid = (130, 230, 255, 245)
        col_core = (245, 255, 255, 255)
        
        c = col_core if layer >= 3 else (col_mid if layer >= 1 else col_outer)
        f_draw.ellipse([cx - scale_r, cy - scale_r + flicker_y, cx + scale_r, cy + scale_r + flicker_y], fill=c)
    
    # Flame tip licking upward
    tip_h = 8 + int(math.sin(phase * 2.0) * 4.0)
    tip_w = 4 + int(math.cos(phase) * 2.0)
    f_draw.polygon([
        (cx - tip_w, cy - 6),
        (cx + tip_w, cy - 6),
        (cx + int(math.sin(phase) * 3), cy - 14 - tip_h)
    ], fill=(120, 220, 255, 220))
    
    # Rising floating spirit ember particles
    for p in range(3):
        p_ang = phase + p * 2.1
        px = cx + int(math.cos(p_ang) * (8 + p * 3))
        py = cy - 8 - int(((f * 4 + p * 7) % 18))
        f_draw.ellipse([px - 1, py - 1, px + 1, py + 1], fill=(200, 245, 255, 220))
    
    sheet.paste(frame, (f * frame_w, 0))

sheet.save("assets/enemies/santelmo_spritesheet.png")
print("Saved assets/enemies/santelmo_spritesheet.png")
