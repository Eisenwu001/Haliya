import os
from PIL import Image, ImageDraw, ImageFont

cutscene_files = [
    {
        "path": "assets/cutscenes/stage1_boss_encounter.jpg",
        "title": "STAGE 1 ENCOUNTER: HIGANTENG GUBAT",
        "desc": "Corrupted Forest Sentinel Awakens in the Ancient Rainforest"
    },
    {
        "path": "assets/cutscenes/stage1_boss_defeat.jpg",
        "title": "STAGE 1 DEFEAT: SENTINEL VANQUISHED",
        "desc": "The Colossus Dissolves into Blooming Lunar Moss and Ascending Moon Pearls"
    },
    {
        "path": "assets/cutscenes/stage2_boss_encounter.jpg",
        "title": "STAGE 2 ENCOUNTER: MAYON VANGUARD",
        "desc": "Armored Skeletal Champion with Kalasag Shield & Blazing Volcanic Spear"
    },
    {
        "path": "assets/cutscenes/stage2_boss_defeat.jpg",
        "title": "STAGE 2 DEFEAT: VANGUARD EXTINCTION & TORRENTIAL RAIN",
        "desc": "Extinguished Spear Shatters as Tropical Thunderstorm Rolls Over Mount Mayon"
    }
]

# We will create an elegant dark gallery sheet: 1920x1180
sheet_w = 1920
sheet_h = 1200
sheet = Image.new("RGBA", (sheet_w, sheet_h), (12, 10, 14, 255))
draw = ImageDraw.Draw(sheet)

# Header
font_title = None
font_sub = None
font_card_title = None
font_card_desc = None
try:
    font_title = ImageFont.truetype("alagard.ttf", 36)
    font_sub = ImageFont.truetype("alagard.ttf", 20)
    font_card_title = ImageFont.truetype("alagard.ttf", 22)
    font_card_desc = ImageFont.truetype("alagard.ttf", 15)
except Exception:
    font_title = ImageFont.load_default()
    font_sub = ImageFont.load_default()
    font_card_title = ImageFont.load_default()
    font_card_desc = ImageFont.load_default()

# Draw Header
header_text = "HALIYA: THE LAST LIGHT — CINEMATIC BOSS CUTSCENES"
draw.text((sheet_w // 2, 40), header_text, fill=(245, 210, 115, 255), font=font_title, anchor="mm")
sub_text = "16:9 Widescreen Painterly Philippine Dark Fantasy Illustrations & Dynamic Stage 2 Downpour"
draw.text((sheet_w // 2, 75), sub_text, fill=(180, 185, 195, 220), font=font_sub, anchor="mm")

# Grid 2x2:
thumb_w = 880
thumb_h = 495 # 16:9

cols = [50, 990]
rows = [120, 650]

for idx, item in enumerate(cutscene_files):
    c_x = cols[idx % 2]
    c_y = rows[idx // 2]
    
    # Border card
    card_rect = [c_x - 4, c_y - 4, c_x + thumb_w + 4, c_y + thumb_h + 46]
    draw.rectangle(card_rect, fill=(20, 18, 24, 255), outline=(70, 60, 45, 180), width=2)
    
    if os.path.exists(item["path"]):
        img = Image.open(item["path"]).convert("RGBA")
        img_resized = img.resize((thumb_w, thumb_h), Image.Resampling.LANCZOS)
        sheet.paste(img_resized, (c_x, c_y))
    
    # Title & description under thumbnail
    draw.text((c_x + 12, c_y + thumb_h + 10), item["title"], fill=(240, 215, 130, 255), font=font_card_title)
    draw.text((c_x + 12, c_y + thumb_h + 30), item["desc"], fill=(170, 175, 185, 220), font=font_card_desc)

out_path = "C:/Users/Lin/.gemini/antigravity/brain/6fd12419-defb-4ac8-a90b-58865f9d5a8a/cinematic_boss_cutscenes_sheet.png"
sheet.save(out_path)
print("Saved gallery sheet to:", out_path)
