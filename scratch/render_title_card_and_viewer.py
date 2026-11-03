import os
from PIL import Image, ImageDraw, ImageFont

# 1. Render Title Card
w = 1280
h = 720
title_img = Image.new("RGBA", (w, h), (3, 2, 4, 255))
draw = ImageDraw.Draw(title_img)

try:
    font_main = ImageFont.truetype("alagard.ttf", 52)
    font_sub = ImageFont.truetype("alagard.ttf", 22)
    font_hint = ImageFont.truetype("alagard.ttf", 16)
except Exception:
    font_main = ImageFont.load_default()
    font_sub = ImageFont.load_default()
    font_hint = ImageFont.load_default()

# Shadow & Title
draw.text((w // 2 + 3, h // 2 - 30 + 3), "THE LAST LIGHT", fill=(90, 15, 20, 255), font=font_main, anchor="mm")
draw.text((w // 2, h // 2 - 30), "THE LAST LIGHT", fill=(245, 210, 112, 255), font=font_main, anchor="mm")

draw.text((w // 2 + 1, h // 2 + 25 + 1), "A Tale of the Masked Moon Goddess", fill=(0, 0, 0, 255), font=font_sub, anchor="mm")
draw.text((w // 2, h // 2 + 25), "A Tale of the Masked Moon Goddess", fill=(210, 215, 225, 220), font=font_sub, anchor="mm")

# Bottom Minimalist Prompt
draw.text((w // 2, h - 35), "Press Space or Click to continue  •  [ESC] Skip", fill=(225, 215, 200, 200), font=font_hint, anchor="mm")

out_title = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/cinematic_title_card_preview.png"
title_img.save(out_title)
print("Saved title card preview to:", out_title)
