import os
from PIL import Image, ImageDraw, ImageFont

def generate_showcase():
    # Overall showcase canvas: 860x520
    W, H = 860, 520
    bg_sky = (14, 18, 26, 255)
    canvas = Image.new('RGBA', (W, H), bg_sky)

    # Top Half (Y: 0 to 260): Lightning Hazard Warning & Crater
    # 1. Base tiles from Floor Tiles1
    tiles = Image.open('assets/platform_assets/Floor Tiles1.png')
    t_mid = tiles.crop((32, 0, 64, 32))
    t_sub = tiles.crop((32, 32, 64, 64))

    GROUND_Y = 190
    for x in range(0, W, 32):
        canvas.paste(t_mid, (x, GROUND_Y))
        canvas.paste(t_sub, (x, GROUND_Y + 32))
        canvas.paste(t_sub, (x, GROUND_Y + 64))

    # Top Left (Center X: 220): Atmospheric Hazard Warning (Ionized Cyan-Azure Beacon, Zero Lightning)
    warn = Image.open('assets/vfx/vfx_lightning_warning.png')
    w_scale = 0.28, 0.40
    new_w = int(512 * w_scale[0]) # 143
    new_h = int(384 * w_scale[1]) # 153
    warn_resized = warn.resize((new_w, new_h), Image.Resampling.LANCZOS)
    
    warn_px = 220 - (new_w // 2)
    warn_py = GROUND_Y - int(380 * w_scale[1])
    canvas.paste(warn_resized, (warn_px, warn_py), warn_resized)

    # Top Right (Center X: 640): Cyan-Azure Vitrified Crater Decal + Permanent Carbon Scorch
    scorch = Image.open('assets/vfx/vfx_lightning_scorch.png')
    # Frame 2: Cooling cyan fulgurite fissures
    f2 = scorch.crop((2 * 256, 0, 3 * 256, 160))
    s_scale = 0.50
    s_w = int(256 * s_scale)
    s_h = int(160 * s_scale)
    f2_resized = f2.resize((s_w, s_h), Image.Resampling.LANCZOS)
    canvas.paste(f2_resized, (530 - (s_w // 2), GROUND_Y - int(20 * s_scale)), f2_resized)

    # Frame 4: Permanent cooled carbon crater with Haliya standing on top
    f4 = scorch.crop((4 * 256, 0, 5 * 256, 160))
    f4_resized = f4.resize((s_w, s_h), Image.Resampling.LANCZOS)
    canvas.paste(f4_resized, (730 - (s_w // 2), GROUND_Y - int(20 * s_scale)), f4_resized)

    haliya = Image.open('assets/haliya/common_00_idle_stand_A01.png').convert('RGBA')
    h_w, h_h = haliya.size
    canvas.paste(haliya, (730 - (h_w // 2), GROUND_Y - h_h + 8), haliya)

    # Bottom Half (Y: 265 to 515): Remade Golden-Hour Ricefield Parallax Background
    rf_preview = Image.open('scratch/golden_ricefield_preview.png')
    # Size 540x360 -> resize to 840x240
    rf_banner = rf_preview.resize((840, 240), Image.Resampling.LANCZOS)
    canvas.paste(rf_banner, (10, 270))

    # Borders & Text Labels
    draw = ImageDraw.Draw(canvas)
    draw.rectangle([0, 0, W - 1, H - 1], outline=(60, 75, 100, 255), width=2)
    draw.line([(0, 262), (W, 262)], fill=(50, 65, 85, 255), width=2)
    draw.line([(W // 2, 0), (W // 2, 262)], fill=(45, 55, 75, 255), width=1)

    draw.text((25, 12), "1. IONIZED CYAN/AZURE HAZARD WARNING (NO LIGHTNING)", fill=(120, 225, 255, 255))
    draw.text((25, 28), "• Translucent sky beacon & ground danger glow in pure electric blue/cyan", fill=(180, 210, 240, 255))
    draw.text((25, 42), "• Zero lightning bolts, zero sparks, zero orange/magma", fill=(180, 210, 240, 255))
    draw.text((25, 56), "• Cosine edge feathering dissolves seamlessly into platform tiles", fill=(180, 210, 240, 255))

    draw.text((455, 12), "2. CYAN VITRIFIED FULGURITE CRATER & COOLED SCORCH", fill=(130, 240, 255, 255))
    draw.text((455, 28), "• Cooling electric cyan glass fissures (left) -> Permanent carbon (right)", fill=(180, 210, 240, 255))
    draw.text((455, 42), "• Soft soot chars underlying tileset naturally with zero raised bumps", fill=(180, 210, 240, 255))
    draw.text((455, 56), "• Haliya walks flush over the crater without hovering", fill=(180, 210, 240, 255))

    draw.text((20, 275), "3. REMADE GOLDEN-HOUR RICEFIELD BACKGROUND (ZERO PARTICLES)", fill=(255, 220, 130, 255))
    draw.text((20, 292), "• Mount Mayon with afternoon clouds • Stepped emerald terraces • Bahay kubo stilt huts • Lush palms", fill=(240, 230, 200, 255))

    out_path = 'scratch/preview_atmospheric_hazard_showcase.png'
    artifact_path = r'C:\Users\Lin\.gemini\antigravity\brain\c7718a4a-5c4f-4a83-8604-730ecde0e295\preview_atmospheric_hazard_showcase.png'
    canvas.save(out_path)
    canvas.save(artifact_path)
    print(f"Saved showcase to {out_path} and {artifact_path}")

if __name__ == '__main__':
    generate_showcase()
