import os
from PIL import Image, ImageDraw, ImageFont

# Screen dimensions 1280x720
w, h = 1280, 720
img = Image.new("RGBA", (w, h), (10, 14, 22, 255))
draw = ImageDraw.Draw(img)

# Dim backdrop
bg_tint = Image.new("RGBA", (w, h), (4, 6, 12, 240))
img = Image.alpha_composite(img, bg_tint)
draw = ImageDraw.Draw(img)

# Modal Panel dimensions
pw, ph = 840, 560
px = (w - pw) // 2
py = (h - ph) // 2

# Draw Panel Background and Gold Border
draw.rounded_rectangle([px, py, px + pw, py + ph], radius=10, fill=(10, 16, 28, 250), outline=(215, 185, 95, 230), width=2)

try:
    font_header = ImageFont.truetype("alagard.ttf", 32)
    font_sub = ImageFont.truetype("alagard.ttf", 18)
    font_tally = ImageFont.truetype("alagard.ttf", 16)
    font_name = ImageFont.truetype("alagard.ttf", 20)
    font_bay = ImageFont.truetype("alagard.ttf", 16)
    font_lore = ImageFont.truetype("alagard.ttf", 14)
    font_btn = ImageFont.truetype("alagard.ttf", 16)
except Exception:
    font_header = ImageFont.load_default()
    font_sub = ImageFont.load_default()
    font_tally = ImageFont.load_default()
    font_name = ImageFont.load_default()
    font_bay = ImageFont.load_default()
    font_lore = ImageFont.load_default()
    font_btn = ImageFont.load_default()

# Header: LORE CODEX
draw.text((w // 2, py + 36), "LORE CODEX", fill=(250, 225, 130, 255), font=font_header, anchor="mm")
draw.text((w // 2, py + 68), "— ❖ — MYTHOLOGICAL BESTIARY OF IBALONG — ❖ —", fill=(195, 185, 160, 220), font=font_sub, anchor="mm")
draw.text((w // 2, py + 94), "LUNAR PEARLS DISCOVERED: 22", fill=(235, 220, 150, 230), font=font_tally, anchor="mm")

# Divider line
draw.line([(px + 40, py + 115), (px + pw - 40, py + 115)], fill=(80, 70, 50, 160), width=1)

# Sample Bestiary Cards
cards = [
    {
        "name": "Aswang (Ghoulish Stalker)",
        "bay": "[ᜀᜐ᜔ᜏᜅ᜔]",
        "lore": "Nocturnal winged prowler of the Bicol forest canopy, ravenous for the blood of travelers traversing the moonlit paths."
    },
    {
        "name": "Santelmo (Spiritual St. Elmo's Fire)",
        "bay": "[ᜐᜈ᜔ᜆᜒᜎ᜔ᜋᜓ]",
        "lore": "Dancing spheres of spirit fire born from souls adrift in flooded rice terraces. Can be deflected and extinguished with a precise parry."
    },
    {
        "name": "Forest Brute (Higanteng Gubat)",
        "bay": "[ᜑᜒᜄᜈ᜔ᜆᜒ]",
        "lore": "A colossal sentinel wielding an ancient uprooted balete limb, guarding the sentry ridge before the emerald terraces."
    }
]

cy = py + 130
for c in cards:
    draw.rounded_rectangle([px + 30, cy, px + pw - 30, cy + 90], radius=6, fill=(16, 24, 40, 230), outline=(100, 130, 180, 160), width=1)
    draw.text((px + 45, cy + 18), c["name"], fill=(250, 230, 165, 255), font=font_name)
    draw.text((px + 45 + 320, cy + 20), c["bay"], fill=(150, 200, 250, 210), font=font_bay)
    draw.text((px + 45, cy + 48), c["lore"], fill=(200, 215, 235, 220), font=font_lore)
    cy += 105

# Close Button
draw.rounded_rectangle([w // 2 - 90, py + ph - 55, w // 2 + 90, py + ph - 18], radius=4, fill=(28, 36, 52, 255), outline=(140, 120, 80, 200), width=1)
draw.text((w // 2, py + ph - 36), "CLOSE [Esc]", fill=(240, 230, 210, 240), font=font_btn, anchor="mm")

out_path = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/lore_codex_preview.png"
img.save(out_path)
print("Saved lore codex preview to:", out_path)
