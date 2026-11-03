from PIL import Image, ImageDraw

# Color Palette strictly matching Floor Tiles1.png and Decor.png
C_OUTLINE    = (34, 31, 25, 255)     # Darkest bark / soil outline
C_SHADOW     = (50, 44, 36, 255)     # Deep shadow
C_WOOD_DARK  = (110, 94, 81, 255)    # Weathered timber
C_WOOD_MID   = (155, 114, 55, 255)   # Golden bamboo / hardwood
C_WOOD_LIGHT = (206, 159, 74, 255)   # Sunlit bamboo slat
C_WOOD_HI    = (224, 188, 90, 255)   # Bamboo highlight
C_WALL_SAWALI= (189, 164, 143, 255)  # Woven sawali matting
C_WALL_DARK  = (145, 120, 100, 255)  # Sawali shadow weave
C_THATCH_HI  = (224, 188, 90, 255)   # Golden nipa palm frond
C_THATCH_MID = (185, 145, 60, 255)   # Mid nipa thatching
C_THATCH_LOW = (140, 105, 45, 255)   # Deep nipa shadow
C_GRASS_HI   = (166, 181, 83, 255)   # Fresh rice grass
C_GRASS_MID  = (123, 127, 59, 255)   # Paddy green
C_GRASS_LOW  = (61, 63, 30, 255)     # Dense grass root
C_WATER_HI   = (242, 249, 252, 255)  # Spring splash white
C_WATER_MID  = (140, 175, 203, 255)  # Mountain water blue
C_WATER_DARK = (87, 103, 135, 255)   # Deep irrigation blue
TRANSPARENT  = (0, 0, 0, 0)

# ==============================================================================
# 1. BAHAY KUBO (192 x 144) — Pixel-Art Pre-Colonial Stilt Nipa Hut
# ==============================================================================
def draw_pixel_bahay_kubo():
    w, h = 192, 144
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    
    # ── Ground Stilts (y: 88 .. 138) ──────────────────────────────────────────
    # 4 Heavy Bamboo Stilt Pillars (X: 36, 68, 124, 156)
    stilt_x = [34, 66, 122, 154]
    for sx in stilt_x:
        # Main pole
        draw.rectangle([sx, 84, sx + 5, 138], fill=C_WOOD_MID, outline=C_OUTLINE)
        # Bamboo node segments every 14 pixels
        for ny in range(86, 136, 14):
            draw.line([(sx, ny), (sx + 5, ny)], fill=C_WOOD_HI)
            draw.line([(sx, ny + 1), (sx + 5, ny + 1)], fill=C_OUTLINE)
        # Highlight edge
        draw.line([(sx + 1, 85), (sx + 1, 137)], fill=C_WOOD_LIGHT)
        
        # Grounding grass tufts around foot of stilt
        for gx in range(sx - 4, sx + 9):
            img.putpixel((gx, 138), C_GRASS_LOW)
        draw.line([(sx - 3, 137), (sx - 5, 131)], fill=C_GRASS_MID)
        draw.line([(sx - 1, 137), (sx - 2, 129)], fill=C_GRASS_HI)
        draw.line([(sx + 4, 137), (sx + 6, 128)], fill=C_GRASS_HI)
        draw.line([(sx + 6, 137), (sx + 8, 132)], fill=C_GRASS_MID)
    
    # Diagonal bracing cross-ties between stilts
    draw.line([(36, 128), (68, 96)], fill=C_WOOD_DARK, width=2)
    draw.line([(68, 128), (36, 96)], fill=C_WOOD_MID, width=1)
    draw.line([(124, 128), (156, 96)], fill=C_WOOD_DARK, width=2)
    draw.line([(156, 128), (124, 96)], fill=C_WOOD_MID, width=1)
    
    # Bamboo Ladder on left stilt (X: 18..32, Y: 88..138)
    draw.line([(22, 90), (16, 138)], fill=C_WOOD_MID, width=2)
    draw.line([(30, 90), (24, 138)], fill=C_WOOD_MID, width=2)
    for ly in range(96, 136, 8):
        lx1 = int(22 - (ly - 90) * 0.125)
        lx2 = int(30 - (ly - 90) * 0.125)
        draw.line([(lx1, ly), (lx2, ly)], fill=C_WOOD_HI, width=2)
        draw.line([(lx1, ly+1), (lx2, ly+1)], fill=C_OUTLINE, width=1)
    
    # ── Living Deck Platform (Y: 82 .. 92, X: 24 .. 168) ─────────────────────
    # Sub-beams
    draw.rectangle([24, 88, 168, 93], fill=C_SHADOW)
    draw.rectangle([22, 82, 170, 88], fill=C_WOOD_MID, outline=C_OUTLINE)
    # Slatted bamboo deck surface
    for dx in range(24, 168, 4):
        draw.line([(dx, 83), (dx, 87)], fill=C_WOOD_HI)
        draw.line([(dx + 1, 83), (dx + 1, 87)], fill=C_OUTLINE)
        
    # Porch railing (X: 24..60 and X: 132..168, Y: 68..82)
    for rx_range in [(24, 58), (134, 168)]:
        draw.line([(rx_range[0], 68), (rx_range[1], 68)], fill=C_WOOD_HI, width=2)
        draw.line([(rx_range[0], 69), (rx_range[1], 69)], fill=C_OUTLINE, width=1)
        for px in range(rx_range[0] + 4, rx_range[1], 8):
            draw.line([(px, 70), (px, 82)], fill=C_WOOD_MID, width=2)
            draw.line([(px, 70), (px, 82)], fill=C_OUTLINE, width=1)
            
    # ── Woven Sawali Walls (X: 42 .. 150, Y: 44 .. 82) ────────────────────────
    # Wall base fill with woven diamond texture
    draw.rectangle([44, 46, 148, 82], fill=C_WALL_SAWALI, outline=C_OUTLINE)
    for wy in range(48, 80, 4):
        for wx in range(46, 146, 6):
            if (wx + wy) % 8 == 0:
                img.putpixel((wx, wy), C_WALL_DARK)
                img.putpixel((wx+1, wy), C_WOOD_LIGHT)
    
    # Corner wall timber studs
    draw.rectangle([42, 44, 48, 82], fill=C_WOOD_MID, outline=C_OUTLINE)
    draw.rectangle([144, 44, 150, 82], fill=C_WOOD_MID, outline=C_OUTLINE)
    
    # Center Open Window & Door with Bamboo Slats
    # Window Left (X: 56..76, Y: 52..68)
    draw.rectangle([56, 52, 76, 68], fill=C_SHADOW, outline=C_OUTLINE)
    # Propped bamboo shutter awning
    draw.polygon([(54, 50), (78, 50), (82, 44), (50, 44)], fill=C_THATCH_MID, outline=C_OUTLINE)
    draw.line([(55, 52), (52, 46)], fill=C_WOOD_HI)
    draw.line([(77, 52), (80, 46)], fill=C_WOOD_HI)
    
    # Doorway Center (X: 88..108, Y: 52..82)
    draw.rectangle([88, 52, 108, 82], fill=C_SHADOW, outline=C_OUTLINE)
    # Ethereal warm lantern glow inside doorway
    draw.ellipse([92, 58, 104, 74], fill=(245, 185, 75, 90))
    img.putpixel((98, 64), (255, 235, 140, 220))
    
    # Window Right (X: 118..138, Y: 52..68)
    draw.rectangle([118, 52, 138, 68], fill=C_SHADOW, outline=C_OUTLINE)
    draw.polygon([(116, 50), (140, 50), (144, 44), (112, 44)], fill=C_THATCH_MID, outline=C_OUTLINE)
    draw.line([(117, 52), (114, 46)], fill=C_WOOD_HI)
    draw.line([(139, 52), (142, 46)], fill=C_WOOD_HI)
    
    # ── Steep Thatched Nipa Palm Roof (Y: 6 .. 48, X: 16 .. 176) ─────────────
    # Ridge beam at top (X: 84..108, Y: 6..10)
    draw.rectangle([82, 6, 110, 11], fill=C_THATCH_HI, outline=C_OUTLINE)
    # Traditional crossed roof finials (Carabao horns motif on apex)
    draw.line([(80, 14), (74, 4)], fill=C_WOOD_MID, width=2)
    draw.line([(112, 14), (118, 4)], fill=C_WOOD_MID, width=2)
    
    # Layered Thatched Palm Tiers
    # Tier 1 (Top: Y: 10 .. 22)
    roof_t1 = [(76, 22), (96, 8), (116, 22)]
    draw.polygon(roof_t1, fill=C_THATCH_HI, outline=C_OUTLINE)
    
    # Tier 2 (Mid-High: Y: 20 .. 34)
    roof_t2 = [(52, 34), (74, 18), (118, 18), (140, 34)]
    draw.polygon(roof_t2, fill=C_THATCH_MID, outline=C_OUTLINE)
    for tx in range(54, 138, 3):
        draw.line([(tx, 30), (tx + 1, 35)], fill=C_THATCH_LOW)
        draw.line([(tx, 20), (tx, 26)], fill=C_THATCH_HI)
        
    # Tier 3 (Broad Eaves Overhang: Y: 32 .. 48, X: 14 .. 178)
    roof_t3 = [(14, 48), (50, 30), (142, 30), (178, 48), (172, 52), (20, 52)]
    draw.polygon(roof_t3, fill=C_THATCH_LOW, outline=C_OUTLINE)
    draw.polygon([(16, 46), (51, 31), (141, 31), (176, 46), (172, 49), (20, 49)], fill=C_THATCH_MID)
    
    # Shaggy overhang fringe along bottom eave
    for fx in range(16, 176, 3):
        f_len = 3 if fx % 2 == 0 else 5
        draw.line([(fx, 48), (fx, 48 + f_len)], fill=C_THATCH_HI)
        draw.line([(fx + 1, 48), (fx + 1, 48 + f_len)], fill=C_OUTLINE)
        
    img.save("assets/rice_field/bahay_kubo.png")
    print("Saved pixel-art bahay_kubo.png (192x144)")

# ==============================================================================
# 2. BAMBOO IRRIGATION FLUME (144 x 56) — Segmented Aqueduct & Water Trough
# ==============================================================================
def draw_pixel_bamboo_flume():
    w, h = 144, 56
    img = Image.new("RGBA", (w, h), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    
    # Tripod support legs (Left: X: 34..46, Right: X: 104..116, Y: 16..54)
    supports = [(30, 42, 54), (100, 112, 124)]
    for lx1, mx, rx2 in supports:
        # Left leg
        draw.line([(mx, 18), (lx1, 52)], fill=C_WOOD_MID, width=2)
        draw.line([(mx, 18), (lx1, 52)], fill=C_OUTLINE, width=1)
        # Right leg
        draw.line([(mx, 18), (rx2, 52)], fill=C_WOOD_MID, width=2)
        draw.line([(mx, 18), (rx2, 52)], fill=C_OUTLINE, width=1)
        # Center tie
        draw.line([(lx1 + 4, 38), (rx2 - 4, 38)], fill=C_WOOD_LIGHT, width=2)
        draw.line([(lx1 + 4, 39), (rx2 - 4, 39)], fill=C_OUTLINE, width=1)
        
        # Grounding grass tufts at base of tripod
        for gx in [lx1, rx2]:
            for ox in range(-3, 4):
                img.putpixel((gx + ox, 53), C_GRASS_LOW)
            draw.line([(gx - 2, 52), (gx - 3, 46)], fill=C_GRASS_MID)
            draw.line([(gx + 1, 52), (gx + 2, 45)], fill=C_GRASS_HI)
            
    # Main Horizontal Bamboo Trough (Slight slope left to right: Y: 12..22)
    # Trough outer casing (Hollowed thick bamboo culm)
    draw.polygon([(6, 12), (134, 16), (134, 25), (6, 21)], fill=C_WOOD_MID, outline=C_OUTLINE)
    draw.polygon([(8, 14), (132, 18), (132, 23), (8, 19)], fill=C_WOOD_LIGHT)
    
    # Bamboo nodes along trough every 24 pixels
    for nx in range(18, 130, 24):
        draw.line([(nx, 13 + int(nx * 0.03)), (nx, 23 + int(nx * 0.03))], fill=C_WOOD_HI, width=2)
        draw.line([(nx + 1, 13 + int(nx * 0.03)), (nx + 1, 23 + int(nx * 0.03))], fill=C_OUTLINE, width=1)
        
    # Flowing Clear Mountain Spring Water inside trough
    draw.polygon([(8, 14), (134, 18), (134, 20), (8, 16)], fill=C_WATER_DARK)
    draw.polygon([(10, 14), (132, 18), (132, 19), (10, 15)], fill=C_WATER_MID)
    # Flow specular highlights
    for wx in range(16, 128, 14):
        img.putpixel((wx, 15 + int(wx * 0.03)), C_WATER_HI)
        img.putpixel((wx + 1, 15 + int(wx * 0.03)), C_WATER_HI)
        
    # Nozzle water spout pouring over right end (X: 132..138, Y: 18..48)
    draw.polygon([(132, 18), (138, 20), (136, 42), (131, 40)], fill=C_WATER_MID)
    draw.line([(134, 19), (133, 41)], fill=C_WATER_HI)
    # Water droplets & splash foam at base
    splash_pts = [(133, 44), (135, 46), (131, 48), (136, 50), (129, 51), (138, 51)]
    for sp in splash_pts:
        img.putpixel(sp, C_WATER_HI)
        img.putpixel((sp[0], sp[1] + 1), C_WATER_MID)
        
    img.save("assets/rice_field/bamboo_flume.png")
    print("Saved pixel-art bamboo_flume.png (144x56)")

draw_pixel_bahay_kubo()
draw_pixel_bamboo_flume()
print("All Stage 2 rice field props authored in 16-bit pixel art!")
