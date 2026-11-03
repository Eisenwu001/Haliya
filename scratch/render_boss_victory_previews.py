import os
from PIL import Image, ImageDraw, ImageFont

art_dir = r"C:\Users\Lin\.gemini\antigravity\brain\6fd12419-defb-4ac8-a90b-58865f9d5a8a"
w, h = 1280, 720

# 1. FOE VANQUISHED Banner Preview
img_foe = Image.new("RGB", (w, h), (12, 10, 14))
draw_f = ImageDraw.Draw(img_foe)

# Ambient dark backdrop
for y in range(h):
    alpha = int(18 + 15 * (1.0 - abs(y - h/2) / (h/2)))
    draw_f.line([(0, y), (w, y)], fill=(alpha, int(alpha * 0.8), int(alpha * 0.6)))

# Center Dark Obsidian Band
band_top = h // 2 - 65
band_bot = h // 2 + 65
draw_f.rectangle([(0, band_top), (w, band_bot)], fill=(6, 5, 8))

# Golden Hairlines
draw_f.line([(0, band_top), (w, band_top)], fill=(235, 204, 107), width=3)
draw_f.line([(0, band_bot), (w, band_bot)], fill=(235, 204, 107), width=3)

try:
    font_banner = ImageFont.truetype("alagard.ttf", 64)
    font_reward = ImageFont.truetype("alagard.ttf", 24)
    font_title = ImageFont.truetype("alagard.ttf", 20)
    font_badge = ImageFont.truetype("alagard.ttf", 16)
except Exception:
    font_banner = font_reward = font_title = font_badge = ImageFont.load_default()

# Text: FOE VANQUISHED
text_banner = "FOE VANQUISHED"
tb = draw_f.textbbox((0, 0), text_banner, font=font_banner)
tw, th = tb[2] - tb[0], tb[3] - tb[1]
tx = (w - tw) // 2
ty = band_top + 22

# Drop shadow & deep outline
draw_f.text((tx + 3, ty + 3), text_banner, fill=(50, 20, 5), font=font_banner)
draw_f.text((tx, ty), text_banner, fill=(250, 230, 175), font=font_banner)

# Text: +1,500 MOON PEARLS CLAIMED
text_reward = "+1,500 MOON PEARLS CLAIMED"
rb = draw_f.textbbox((0, 0), text_reward, font=font_reward)
rw, rh = rb[2] - rb[0], rb[3] - rb[1]
rx = (w - rw) // 2
ry = ty + th + 14

draw_f.text((rx + 2, ry + 2), text_reward, fill=(0, 0, 0), font=font_reward)
draw_f.text((rx, ry), text_reward, fill=(175, 230, 255), font=font_reward)

foe_out = os.path.join(art_dir, "foe_vanquished_banner_preview.png")
img_foe.save(foe_out)
print("Saved FOE VANQUISHED banner preview:", foe_out)


# 2. Enraged Boss Health Bar Preview
img_bar = Image.new("RGB", (w, 240), (10, 8, 12))
draw_b = ImageDraw.Draw(img_bar)

cx = w // 2
by = 120

# Title: HIGANTENG GUBAT — ENRAGED TIMBER COLOSSUS
title_str = "HIGANTENG GUBAT — ENRAGED TIMBER COLOSSUS"
draw_b.text((cx - 260, by - 45), title_str, fill=(255, 90, 90), font=font_title)

# Badge: [ ENRAGED ]
draw_b.rectangle([(cx + 210, by - 48), (cx + 310, by - 24)], fill=(40, 10, 10), outline=(255, 200, 50), width=1)
draw_b.text((cx + 220, by - 46), "[ ENRAGED ]", fill=(255, 70, 70), font=font_badge)

# Health Bar Frame (width = 760, height = 30)
bx0 = cx - 380
bx1 = cx + 380
by0 = by - 12
by1 = by + 18

draw_b.rectangle([(bx0 - 3, by0 - 3), (bx1 + 3, by1 + 3)], fill=(12, 14, 18), outline=(184, 153, 90), width=2)

# End diamond jewels
for side in [-1, 1]:
    dx = bx0 if side < 0 else bx1
    dy = by0 + 15
    pts = [(dx - 7, dy), (dx, dy - 7), (dx + 7, dy), (dx, dy + 7)]
    draw_b.polygon(pts, fill=(235, 199, 107))

# Channel background
draw_b.rectangle([(bx0, by0), (bx1, by0 + 30)], fill=(32, 10, 15))

# Primary HP fill (pulsing crimson-flame)
draw_b.rectangle([(bx0, by0), (bx0 + 640, by0 + 30)], fill=(245, 55, 55))

# 10% Notch (bx0 + 76)
draw_b.line([(bx0 + 76, by0 - 4), (bx0 + 76, by0 + 34)], fill=(255, 220, 115), width=3)
draw_b.polygon([(bx0 + 73, by0 - 4), (bx0 + 76, by0 - 8), (bx0 + 79, by0 - 4), (bx0 + 76, by0)], fill=(255, 235, 120))

# Numeric readout: 84%
pct_str = "84%"
pb = draw_b.textbbox((0, 0), pct_str, font=font_title)
pw = pb[2] - pb[0]
draw_b.text((cx - pw // 2, by0 + 4), pct_str, fill=(255, 255, 255), font=font_title)

bar_out = os.path.join(art_dir, "enraged_boss_health_bar_preview.png")
img_bar.save(bar_out)
print("Saved Enraged Boss Health Bar preview:", bar_out)
