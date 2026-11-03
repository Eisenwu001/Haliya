import os
from PIL import Image, ImageDraw, ImageFont

art_dir = r"C:\Users\Lin\.gemini\antigravity\brain\6fd12419-defb-4ac8-a90b-58865f9d5a8a"
w, h = 1280, 720

# 1. Title Card Preview
img_title = Image.new("RGB", (w, h), (0, 0, 0))
draw = ImageDraw.Draw(img_title)

try:
    font_title = ImageFont.truetype("alagard.ttf", 56)
    font_lore = ImageFont.truetype("alagard.ttf", 24)
    font_prompt = ImageFont.truetype("alagard.ttf", 18)
except Exception:
    font_title = font_lore = font_prompt = ImageFont.load_default()

title_text = "THE LAST LIGHT"
lore_text = '"When the sacred moons are swallowed by the void, one masked guardian carries the dawn."'

# Draw Title
tb = draw.textbbox((0, 0), title_text, font=font_title)
tw, th = tb[2] - tb[0], tb[3] - tb[1]
tx = (w - tw) // 2
ty = h // 2 - 60

# shadow
draw.text((tx + 3, ty + 3), title_text, fill=(30, 15, 5), font=font_title)
draw.text((tx, ty), title_text, fill=(245, 230, 184), font=font_title)

# Draw Lore Text
lb = draw.textbbox((0, 0), lore_text, font=font_lore)
lw, lh = lb[2] - lb[0], lb[3] - lb[1]
lx = (w - lw) // 2
ly = ty + th + 35

draw.text((lx + 2, ly + 2), lore_text, fill=(10, 10, 10), font=font_lore)
draw.text((lx, ly), lore_text, fill=(217, 209, 189), font=font_lore)

title_out = os.path.join(art_dir, "title_card_cinematic_preview.png")
img_title.save(title_out)
print("Saved title card preview:", title_out)

# 2. Comic Panel 1 Full Screen Preview
comic_path = os.path.join("Haliya Story", "Haliya comic scene.png")
panel_img = Image.open(comic_path).convert("RGB")
pw, ph = panel_img.size

# Fit keeping aspect ratio
scale = min(w / pw, h / ph)
nw, nh = int(pw * scale), int(ph * scale)
scaled_panel = panel_img.resize((nw, nh), Image.Resampling.LANCZOS)

img_comic = Image.new("RGB", (w, h), (0, 0, 0))
px = (w - nw) // 2
py = (h - nh) // 2
img_comic.paste(scaled_panel, (px, py))

# Draw subtle HUD
draw_c = ImageDraw.Draw(img_comic)
p_text = "Press Space or Click to continue  •  [ESC] Skip"
pb = draw_c.textbbox((0, 0), p_text, font=font_prompt)
ptw, pth = pb[2] - pb[0], pb[3] - pb[1]
ptx = (w - ptw) // 2
pty = h - 42

draw_c.text((ptx + 1, pty + 1), p_text, fill=(0, 0, 0), font=font_prompt)
draw_c.text((ptx, pty), p_text, fill=(235, 225, 210), font=font_prompt)

page_text = "[ 1 / 9 ]"
page_b = draw_c.textbbox((0, 0), page_text, font=font_prompt)
pagew = page_b[2] - page_b[0]
draw_c.text((w - pagew - 35 + 1, pty + 1), page_text, fill=(0, 0, 0), font=font_prompt)
draw_c.text((w - pagew - 35, pty), page_text, fill=(210, 190, 130), font=font_prompt)

comic_out = os.path.join(art_dir, "comic_panel1_fullscreen_preview.png")
img_comic.save(comic_out)
print("Saved comic preview:", comic_out)
