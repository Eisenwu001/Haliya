import os
import numpy as np
from PIL import Image, ImageDraw

def remove_black_bg(img: Image.Image, threshold: int = 15, smooth: int = 12) -> Image.Image:
    rgba = img.convert("RGBA")
    arr = np.array(rgba, dtype=np.float32)
    rgb_max = np.max(arr[:, :, :3], axis=2)
    alpha = np.clip((rgb_max - threshold) / float(smooth), 0.0, 1.0) * 255.0
    for c in range(3):
        arr[:, :, c] = np.where(alpha > 0, np.clip(arr[:, :, c] * (255.0 / np.maximum(alpha, 10.0)), 0, 255), 0)
    arr[:, :, 3] = alpha
    return Image.fromarray(arr.astype(np.uint8), "RGBA")

def main():
    base_dir = r"assets\cave_platformer"
    os.makedirs(base_dir, exist_ok=True)
    
    # ── Source images ──
    plat_raw_src = r"C:\Users\Lin\.gemini\antigravity\brain\351a0af0-87d2-4735-aa24-b03d486d3110\platforms_and_stalactites_raw_1792489085961.jpg"
    ceiling_src = r"C:\Users\Lin\.gemini\antigravity\brain\351a0af0-87d2-4735-aa24-b03d486d3110\cavern_ceiling_raw_1792489065276.jpg"
    props_raw_src = r"assets\generated_raw\props_raw.jpg"
    
    p_img = Image.open(plat_raw_src)
    p_rgba = remove_black_bg(p_img, threshold=14, smooth=10)
    
    # ── 1. Build cave_platforms.png (224 x 160) ──
    # Existing layout expected by scenes:
    # Rect2(128, 0, 96, 48)   -> island_md
    # Rect2(0, 0, 128, 56)    -> island_lg
    # Rect2(0, 64, 128, 40)   -> bridge
    # Rect2(0, 104, 160, 56)  -> sanctuary
    
    platforms_atlas = Image.new("RGBA", (224, 160), (0, 0, 0, 0))
    
    # Crop source elements:
    # A. Mossy ledge: (38, 330, 690, 725)
    plat_moss = p_rgba.crop((38, 330, 690, 725))
    # B. Runic altar: (1025, 270, 1340, 540)
    plat_runic = p_rgba.crop((1025, 270, 1340, 540))
    # C. Basalt column: (750, 160, 980, 645)
    plat_basalt = p_rgba.crop((750, 160, 980, 645))
    
    # 1. island_md: 96x48 at (128, 0)
    # Using a 96x48 crop of mossy ledge
    moss_md = plat_moss.resize((96, 54), Image.Resampling.LANCZOS).crop((0, 0, 96, 48))
    platforms_atlas.paste(moss_md, (128, 0), moss_md)
    
    # 2. island_lg: 128x56 at (0, 0)
    # Using runic altar platform!
    runic_lg = plat_runic.resize((128, 62), Image.Resampling.LANCZOS).crop((0, 0, 128, 56))
    platforms_atlas.paste(runic_lg, (0, 0), runic_lg)
    
    # 3. bridge: 128x40 at (0, 64)
    # Using center slice of mossy ledge
    bridge_crop = plat_moss.crop((60, 20, plat_moss.width - 60, plat_moss.height))
    bridge_scaled = bridge_crop.resize((128, 44), Image.Resampling.LANCZOS).crop((0, 0, 128, 40))
    platforms_atlas.paste(bridge_scaled, (0, 64), bridge_scaled)
    
    # 4. sanctuary: 160x56 at (0, 104)
    # Full wide mossy cavern terrace!
    moss_wide = plat_moss.resize((160, 62), Image.Resampling.LANCZOS).crop((0, 0, 160, 56))
    platforms_atlas.paste(moss_wide, (0, 104), moss_wide)
    
    platforms_atlas.save(os.path.join(base_dir, "cave_platforms.png"))
    print("Saved cave_platforms.png: 224x160")
    
    # ── 2. Build cave_props.png (320 x 160) ──
    props_atlas = Image.new("RGBA", (320, 160), (0, 0, 0, 0))
    
    # Props raw has: stele, cyan crystal, amethyst crystal, geode orb
    pr_img = Image.open(props_raw_src)
    pr_rgba = remove_black_bg(pr_img, threshold=12, smooth=10)
    
    # Extract from props_raw:
    # Raw size is 1376x768 or similar
    # Let's crop components from props_raw
    # We also have the stalactites from p_rgba!
    stala_crop = p_rgba.crop((265, 38, 458, 335))
    # Resonant stalactite tip for pogo: Rect2(64, 96, 64, 64)
    stala_pogo = stala_crop.resize((64, 76), Image.Resampling.LANCZOS).crop((0, 12, 64, 76)) # Keep the glowing crystal point
    props_atlas.paste(stala_pogo, (64, 96), stala_pogo)
    
    # Save standalone resonant pogo stalactite full
    stala_full = stala_crop.resize((64, 96), Image.Resampling.LANCZOS)
    stala_full.save(os.path.join(base_dir, "pogo_stalactite_resonant.png"))
    
    # Extract props from props_raw:
    # Let's find props_raw dimensions and components
    w_pr, h_pr = pr_rgba.size
    # 4 items horizontally spaced:
    # 1. Cyan crystal: ~0.05 to 0.25
    # 2. Amethyst crystal: ~0.28 to 0.48
    # 3. Geode orb: ~0.50 to 0.72
    # 4. Runic obelisk: ~0.78 to 0.95
    c_cyan = pr_rgba.crop((int(w_pr * 0.04), int(h_pr * 0.22), int(w_pr * 0.25), int(h_pr * 0.78)))
    c_am = pr_rgba.crop((int(w_pr * 0.28), int(h_pr * 0.27), int(w_pr * 0.48), int(h_pr * 0.78)))
    c_geode = pr_rgba.crop((int(w_pr * 0.51), int(h_pr * 0.38), int(w_pr * 0.72), int(h_pr * 0.78)))
    c_stele = pr_rgba.crop((int(w_pr * 0.77), int(h_pr * 0.12), int(w_pr * 0.95), int(h_pr * 0.78)))
    
    # 1. Stele at (0, 0, 64, 96)
    s_stele = c_stele.resize((64, 96), Image.Resampling.LANCZOS)
    props_atlas.paste(s_stele, (0, 0), s_stele)
    
    # 2. Cyan Geode / Crystal at (64, 0, 64, 64)
    s_cyan = c_cyan.resize((64, 64), Image.Resampling.LANCZOS)
    props_atlas.paste(s_cyan, (64, 0), s_cyan)
    
    # 3. Amethyst Geode / Crystal at (128, 0, 64, 64)
    s_am = c_am.resize((64, 64), Image.Resampling.LANCZOS)
    props_atlas.paste(s_am, (128, 0), s_am)
    
    # 4. Large Cyan Spire at (192, 0, 64, 64)
    s_geode = c_geode.resize((60, 60), Image.Resampling.LANCZOS)
    props_atlas.paste(s_geode, (194, 2), s_geode)
    
    # 5. Large Amethyst Spire at (256, 0, 64, 64)
    props_atlas.paste(s_am, (256, 0), s_am)
    
    # 6. Cavern Flora at (0, 96, 64, 64)
    # Bioluminescent mushroom cluster
    flora_crop = p_rgba.crop((48, 350, 160, 460))
    s_flora = flora_crop.resize((60, 52), Image.Resampling.LANCZOS)
    props_atlas.paste(s_flora, (2, 102), s_flora)
    
    # 7. Hazard spikes at (128, 96, 128, 48)
    # Create sharp crystal hazard spikes bed
    spikes = Image.new("RGBA", (128, 48), (0, 0, 0, 0))
    s_tip = stala_crop.resize((32, 48), Image.Resampling.LANCZOS).transpose(Image.Transpose.FLIP_TOP_BOTTOM)
    for sx in [0, 24, 48, 72, 96]:
        spikes.paste(s_tip, (sx, 0), s_tip)
    props_atlas.paste(spikes, (128, 96), spikes)
    
    props_atlas.save(os.path.join(base_dir, "cave_props.png"))
    print("Saved cave_props.png: 320x160")
    
    # ── 3. Save modular cavern ceiling ──
    # 640x110 seamless
    c_img = Image.open(ceiling_src)
    arr = np.array(c_img)
    arr[:45, :, 0] = 18
    arr[:45, :, 1] = 20
    arr[:45, :, 2] = 30
    c_fixed = Image.fromarray(arr)
    c_rgba = remove_black_bg(c_fixed, threshold=15, smooth=10)
    arr_rgba = np.array(c_rgba)
    arr_rgba[:45, :, 3] = 255
    c_cropped = Image.fromarray(arr_rgba, "RGBA").crop((0, 0, 1376, 565))
    c_mod = c_cropped.resize((640, 108), Image.Resampling.LANCZOS)
    
    # Seamless horizontal blend
    a_mod = np.array(c_mod)
    bw = 32
    for i in range(bw):
        f = i / float(bw)
        a_mod[:, -bw + i, :] = (a_mod[:, -bw + i, :] * (1 - f) + a_mod[:, i, :] * f).astype(np.uint8)
    
    c_final = Image.fromarray(a_mod, "RGBA")
    c_final.save(os.path.join(base_dir, "cavern_ceiling_modular.png"))
    print("Saved cavern_ceiling_modular.png: 640x108")

if __name__ == "__main__":
    main()
