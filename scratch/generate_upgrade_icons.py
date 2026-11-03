import os
from PIL import Image, ImageDraw

os.makedirs("assets/ui/icons", exist_ok=True)

# Color palettes
FRAME_BRASS_LIGHT = (212, 175, 85, 255)
FRAME_BRASS_MID   = (158, 117, 40, 255)
FRAME_BRASS_DARK  = (68, 48, 20, 255)
BG_DARK           = (12, 16, 26, 255)
TRANSPARENT       = (0, 0, 0, 0)

def create_base_icon_frame():
    """Creates a 32x32 icon with an antique brass filigree border and dark background."""
    img = Image.new("RGBA", (32, 32), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    
    # Fill background
    for y in range(2, 30):
        for x in range(2, 30):
            img.putpixel((x, y), BG_DARK)
            
    # Outer dark border
    draw.rectangle([0, 0, 31, 31], outline=FRAME_BRASS_DARK)
    # Inner brass highlight
    draw.rectangle([1, 1, 30, 30], outline=FRAME_BRASS_MID)
    # Corner filigree accents (Philippine pre-colonial jewelry motif)
    for cx, cy in [(1, 1), (30, 1), (1, 30), (30, 30), (16, 1), (16, 30), (1, 16), (30, 16)]:
        img.putpixel((cx, cy), FRAME_BRASS_LIGHT)
        
    return img

# 1. Vitality: Moonstone Anting-Anting (Talisman with pulsing heart ruby)
def gen_vitality():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Golden amulet chain & bail
    draw.line([(15, 4), (16, 4)], fill=FRAME_BRASS_LIGHT)
    draw.line([(14, 5), (17, 5)], fill=FRAME_BRASS_MID)
    # Diamond stone setting
    amulet_pts = [(16, 7), (24, 16), (16, 25), (8, 16)]
    draw.polygon(amulet_pts, outline=FRAME_BRASS_LIGHT, fill=(35, 20, 28, 255))
    # Glowing ruby vitality core
    draw.polygon([(16, 10), (21, 16), (16, 22), (11, 16)], fill=(220, 35, 60, 255))
    draw.polygon([(16, 12), (19, 16), (16, 20), (13, 16)], fill=(255, 95, 120, 255))
    img.putpixel((16, 15), (255, 230, 240, 255)) # highlight glint
    img.save("assets/ui/icons/icon_vitality.png")
    print("Generated icon_vitality.png")

# 2. Damage: Balaraw Edge (Traditional winged leaf-bladed dagger)
def gen_damage():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Cross diagonal dagger blade
    # Pommel and horn grip
    draw.line([(7, 24), (10, 21)], fill=(120, 60, 30, 255), width=2)
    # Winged crossguard
    draw.line([(9, 23), (12, 18)], fill=FRAME_BRASS_LIGHT, width=2)
    draw.line([(8, 19), (14, 21)], fill=FRAME_BRASS_MID)
    # Razor leaf blade
    blade_pts = [(11, 20), (22, 9), (26, 5), (23, 10), (13, 18)]
    draw.polygon(blade_pts, fill=(200, 215, 235, 255), outline=(130, 155, 185, 255))
    # Razor edge shine & tip
    img.putpixel((26, 5), (255, 255, 255, 255))
    img.putpixel((25, 6), (255, 255, 255, 255))
    draw.line([(14, 17), (24, 7)], fill=(245, 250, 255, 255))
    img.save("assets/ui/icons/icon_damage.png")
    print("Generated icon_damage.png")

# 3. Stamina: Breeze of Mayon (Volcanic ember spiral & wind talisman)
def gen_stamina():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Spiral wind arcs
    draw.arc([7, 8, 24, 23], start=45, end=270, fill=(255, 170, 45, 255), width=2)
    draw.arc([10, 11, 21, 20], start=180, end=360, fill=(255, 225, 95, 255), width=2)
    # Glowing embers
    embers = [(9, 12), (14, 8), (22, 11), (20, 21), (13, 23), (16, 15)]
    for ex, ey in embers:
        img.putpixel((ex, ey), (255, 235, 140, 255))
        img.putpixel((ex+1, ey), (240, 90, 30, 255))
    img.save("assets/ui/icons/icon_stamina.png")
    print("Generated icon_stamina.png")

# 4. Swiftness: Amihan's Swiftness (Sacred Sarimanok celestial plume)
def gen_swiftness():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Curving feather spine
    draw.line([(8, 24), (14, 18), (20, 11), (25, 6)], fill=(255, 240, 180, 255), width=1)
    # Feather vanes (Emerald & Cyan iridescent tufts)
    for i in range(10):
        t = i / 10.0
        bx = int(8 + t * 16)
        by = int(24 - t * 17)
        # Left barbs (emerald)
        draw.line([(bx, by), (bx - 3, by - 2)], fill=(45, 210, 135, 255))
        # Right barbs (cyan-gold)
        draw.line([(bx, by), (bx + 3, by + 1)], fill=(55, 195, 240, 255))
    img.putpixel((25, 6), (255, 255, 255, 255)) # radiant quill tip
    img.save("assets/ui/icons/icon_swiftness.png")
    print("Generated icon_swiftness.png")

# 5. Aegis: Lunar Aegis (Carved Kalasag hardwood shield with silver crescent)
def gen_aegis():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Hexagonal Kalasag shield outline
    shield_pts = [(16, 5), (24, 9), (23, 23), (16, 27), (9, 23), (8, 9)]
    draw.polygon(shield_pts, fill=(75, 42, 22, 255), outline=FRAME_BRASS_LIGHT)
    # Hardwood grain planks
    draw.line([(16, 6), (16, 26)], fill=(52, 28, 14, 255))
    draw.line([(12, 8), (12, 24)], fill=(52, 28, 14, 255))
    draw.line([(20, 8), (20, 24)], fill=(52, 28, 14, 255))
    # Carved silver lunar crescent boss
    draw.arc([11, 10, 21, 20], start=45, end=315, fill=(225, 240, 255, 255), width=2)
    img.putpixel((13, 15), (255, 255, 255, 255))
    img.save("assets/ui/icons/icon_aegis.png")
    print("Generated icon_aegis.png")

# 6. Riposte: Vampiric Riposte (Cursed Mandaya blood blade)
def gen_riposte():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Curved waved Kris dagger
    kris_pts = [(9, 23), (13, 17), (16, 18), (19, 12), (21, 13), (25, 6)]
    for i in range(len(kris_pts)-1):
        draw.line([kris_pts[i], kris_pts[i+1]], fill=(220, 225, 235, 255), width=2)
    # Dripping crimson lunar blood droplets
    draw.polygon([(13, 19), (15, 24), (13, 26), (11, 24)], fill=(220, 25, 45, 255))
    img.putpixel((13, 23), (255, 90, 110, 255))
    draw.polygon([(20, 15), (21, 19), (19, 20), (18, 18)], fill=(180, 15, 30, 255))
    img.save("assets/ui/icons/icon_riposte.png")
    print("Generated icon_riposte.png")

# 7. Shockwave: Lunar Shockwave (Crescent sickle & shockwave arcs)
def gen_shockwave():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Haliya's crescent scythe
    draw.arc([7, 7, 21, 21], start=60, end=300, fill=(230, 245, 255, 255), width=3)
    # Shockwave blast ripples expanding outward
    draw.arc([14, 6, 26, 22], start=300, end=420, fill=(120, 190, 255, 255), width=2)
    draw.arc([18, 4, 30, 24], start=310, end=410, fill=(80, 140, 240, 255), width=1)
    img.save("assets/ui/icons/icon_shockwave.png")
    print("Generated icon_shockwave.png")

# 8. Ghost Dash: Spectral Mask of Haliya & phantom trail
def gen_ghost_dash():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Mask of sorrow shape
    mask_pts = [(16, 7), (23, 11), (22, 21), (16, 25), (10, 21), (9, 11)]
    draw.polygon(mask_pts, fill=(195, 215, 240, 255), outline=(130, 160, 205, 255))
    # Downward slanted eye slits (sorrow)
    draw.line([(11, 14), (14, 16)], fill=(20, 30, 50, 255), width=1)
    draw.line([(21, 14), (18, 16)], fill=(20, 30, 50, 255), width=1)
    # Phantom motion speed lines trailing to the left
    draw.line([(6, 11), (1, 11)], fill=(120, 180, 255, 180), width=1)
    draw.line([(5, 17), (2, 17)], fill=(120, 180, 255, 210), width=1)
    draw.line([(7, 23), (3, 23)], fill=(120, 180, 255, 150), width=1)
    img.save("assets/ui/icons/icon_ghost_dash.png")
    print("Generated icon_ghost_dash.png")

# 9. Eclipse Pogo: Eclipsed Moon & downward thrust spear
def gen_eclipse_pogo():
    img = create_base_icon_frame()
    draw = ImageDraw.Draw(img)
    # Eclipsed sun disc with golden corona
    draw.ellipse([8, 6, 24, 22], outline=(255, 195, 45, 255), width=2)
    draw.ellipse([10, 8, 22, 20], fill=(15, 18, 28, 255))
    # Downward striking spear point
    draw.polygon([(16, 12), (19, 21), (16, 27), (13, 21)], fill=(240, 245, 255, 255), outline=FRAME_BRASS_LIGHT)
    # Impact burst lines
    draw.line([(12, 26), (9, 28)], fill=(255, 215, 80, 255))
    draw.line([(20, 26), (23, 28)], fill=(255, 215, 80, 255))
    img.save("assets/ui/icons/icon_eclipse_pogo.png")
    print("Generated icon_eclipse_pogo.png")

gen_vitality()
gen_damage()
gen_stamina()
gen_swiftness()
gen_aegis()
gen_riposte()
gen_shockwave()
gen_ghost_dash()
gen_eclipse_pogo()
print("All 9 Philippine mythology upgrade icons created successfully!")
