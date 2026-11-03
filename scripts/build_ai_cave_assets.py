import os
import cv2
import numpy as np
from PIL import Image

def remove_dark_bg(img, bg_thresh=18, feather=1.5):
    rgba = img.convert("RGBA")
    arr = np.array(rgba, dtype=float)
    rgb = arr[:,:,:3]
    brightness = 0.299 * rgb[:,:,0] + 0.587 * rgb[:,:,1] + 0.114 * rgb[:,:,2]
    
    alpha = np.clip((brightness - bg_thresh) / (bg_thresh * feather) * 255.0, 0, 255)
    max_c = np.max(rgb, axis=2)
    min_c = np.min(rgb, axis=2)
    saturation = max_c - min_c
    boost = np.clip((saturation - 15.0) / 20.0 * 255.0, 0, 255)
    alpha = np.maximum(alpha, boost)
    
    arr[:,:,3] = alpha
    return Image.fromarray(arr.astype(np.uint8))

def crop_content(img, min_alpha=20):
    arr = np.array(img)
    if arr.shape[2] < 4:
        return img
    alpha = arr[:,:,3]
    pts = np.where(alpha > min_alpha)
    if len(pts[0]) == 0 or len(pts[1]) == 0:
        return img
    y0, y1 = pts[0].min(), pts[0].max() + 1
    x0, x1 = pts[1].min(), pts[1].max() + 1
    return img.crop((x0, y0, x1, y1))

def place_at_top(content_img, target_w, target_h):
    """Scales content preserving aspect ratio, placing top surface flush at y=0."""
    cw, ch = content_img.size
    scale = min(target_w / cw, target_h / ch)
    # Fit comfortably
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = content_img.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    pos_x = (target_w - nw) // 2
    canvas.paste(scaled, (pos_x, 0), scaled)
    return canvas

def place_at_bottom(content_img, target_w, target_h):
    """Scales content, placing bottom surface flush at y=target_h."""
    cw, ch = content_img.size
    scale = min(target_w / cw, target_h / ch)
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = content_img.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    pos_x = (target_w - nw) // 2
    pos_y = target_h - nh
    canvas.paste(scaled, (pos_x, pos_y), scaled)
    return canvas

def place_centered(content_img, target_w, target_h):
    cw, ch = content_img.size
    scale = min(target_w / cw, target_h / ch)
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = content_img.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    pos_x = (target_w - nw) // 2
    pos_y = (target_h - nh) // 2
    canvas.paste(scaled, (pos_x, pos_y), scaled)
    return canvas

def build_all_assets():
    base_dir = r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484"
    im1_path = os.path.join(base_dir, "philippine_subterranean_cave_tileset_1792544013682.jpg")
    im2_path = os.path.join(base_dir, "philippine_cave_platforms_spritesheet_1792544043909.jpg")
    im3_path = os.path.join(base_dir, "cave_tileset_spritesheet_1792544092516.jpg")

    im1 = Image.open(im1_path)
    im2 = Image.open(im2_path)
    im3 = Image.open(im3_path)

    im2_alpha = remove_dark_bg(im2)
    im1_alpha = remove_dark_bg(im1)

    # ─────────────────────────────────────────────────────────────────────────────
    # 1. CAVE PLATFORMS (224 x 160)
    # ─────────────────────────────────────────────────────────────────────────────
    # - island_lg  (128 x 56 at 0, 0)
    # - island_md  (96 x 48 at 128, 0)
    # - bridge     (128 x 40 at 0, 64)
    # - crumble    (96 x 48 at 128, 64)
    # - sanctuary  (160 x 56 at 0, 104)
    plat_canvas = Image.new("RGBA", (224, 160), (0, 0, 0, 0))

    # AI Bamboo Bridge (from im2 x=44..680, y=98..285)
    ai_bridge = crop_content(im2_alpha.crop((44, 98, 680, 285)))
    fit_bridge = place_at_top(ai_bridge, 128, 40)
    plat_canvas.paste(fit_bridge, (0, 64), fit_bridge)

    # AI Large Limestone Ledge (from im2 x=725..865, y=100..260)
    ai_island_lg = crop_content(im2_alpha.crop((725, 100, 865, 260)))
    fit_island_lg = place_at_top(ai_island_lg, 128, 56)
    plat_canvas.paste(fit_island_lg, (0, 0), fit_island_lg)

    # AI Medium Limestone Ledge (from im2 x=1220..1335, y=100..270)
    ai_island_md = crop_content(im2_alpha.crop((1220, 100, 1335, 270)))
    fit_island_md = place_at_top(ai_island_md, 96, 48)
    plat_canvas.paste(fit_island_md, (128, 0), fit_island_md)

    # AI Crumble Ledge (from im2 x=1100..1210, y=100..265)
    ai_crumble = crop_content(im2_alpha.crop((1100, 100, 1210, 265)))
    fit_crumble = place_at_top(ai_crumble, 96, 48)
    plat_canvas.paste(fit_crumble, (128, 64), fit_crumble)

    # AI Sanctuary Terrace (from im2 x=870..1100, y=100..270)
    ai_sanctuary = crop_content(im2_alpha.crop((870, 100, 1100, 270)))
    fit_sanctuary = place_at_top(ai_sanctuary, 160, 56)
    plat_canvas.paste(fit_sanctuary, (0, 104), fit_sanctuary)

    plat_path = "assets/cave_platformer/cave_platforms.png"
    plat_canvas.save(plat_path)
    print(f"Saved AI-crafted platforms to {plat_path}")

    # ─────────────────────────────────────────────────────────────────────────────
    # 2. CAVE PROPS (320 x 160)
    # ─────────────────────────────────────────────────────────────────────────────
    # - Manunggul Jar: Rect2(0, 0, 64, 64)
    # - Anito Totem:   Rect2(64, 0, 64, 96)
    # - Pako Ferns:    Rect2(128, 0, 64, 64)
    # - Stalactites:   Rect2(192, 0, 96, 64)
    # - Sulo Torch:    Rect2(0, 64, 32, 64)
    # - Stalagmites:   Rect2(64, 64, 96, 32)
    # - Moon Pearl:    Rect2(160, 64, 64, 64)
    # - Palayok Pot:   Rect2(224, 64, 48, 48)
    props_canvas = Image.new("RGBA", (320, 160), (0, 0, 0, 0))

    # Manunggul Jar (from im2 x=360..485, y=545..705)
    ai_jar = crop_content(im2_alpha.crop((360, 545, 485, 705)))
    fit_jar = place_at_bottom(ai_jar, 64, 64)
    props_canvas.paste(fit_jar, (0, 0), fit_jar)

    # Anito Totem (from im2 x=40..138, y=545..705)
    ai_totem = crop_content(im2_alpha.crop((40, 545, 138, 705)))
    fit_totem = place_at_bottom(ai_totem, 64, 96)
    props_canvas.paste(fit_totem, (64, 0), fit_totem)

    # Pako Ferns (from im2 x=980..1135, y=535..700)
    ai_ferns = crop_content(im2_alpha.crop((980, 535, 1135, 700)))
    fit_ferns = place_at_bottom(ai_ferns, 64, 64)
    props_canvas.paste(fit_ferns, (128, 0), fit_ferns)

    # Ceiling Stalactites (from im2 x=760..910, y=560..690)
    ai_stalactite = crop_content(im2_alpha.crop((760, 560, 910, 690)))
    fit_stalactite = place_at_top(ai_stalactite, 96, 64)
    props_canvas.paste(fit_stalactite, (192, 0), fit_stalactite)

    # Bamboo Sulo Torch (from im2 x=200..260, y=545..685)
    ai_torch = crop_content(im2_alpha.crop((200, 545, 260, 685)))
    fit_torch = place_at_bottom(ai_torch, 32, 64)
    props_canvas.paste(fit_torch, (0, 64), fit_torch)

    # Limestone Stalagmites (Hazard Spikes) (from im2 x=535..655, y=335..455)
    ai_spikes = crop_content(im2_alpha.crop((535, 335, 655, 455)))
    fit_spikes = place_at_bottom(ai_spikes, 96, 32)
    props_canvas.paste(fit_spikes, (64, 64), fit_spikes)

    # Resonant Moon Pearl (Mutya ng Haliya) (from im2 x=540..700, y=540..705)
    ai_pearl = crop_content(im2_alpha.crop((540, 540, 700, 705)))
    fit_pearl = place_centered(ai_pearl, 64, 64)
    props_canvas.paste(fit_pearl, (160, 64), fit_pearl)

    # Earthenware Palayok Pot (from im2 x=255..340, y=545..645)
    ai_pot = crop_content(im2_alpha.crop((255, 545, 340, 645)))
    fit_pot = place_at_bottom(ai_pot, 48, 48)
    props_canvas.paste(fit_pot, (224, 64), fit_pot)

    props_path = "assets/cave_platformer/cave_props.png"
    props_canvas.save(props_path)
    print(f"Saved AI-crafted props to {props_path}")

    # ─────────────────────────────────────────────────────────────────────────────
    # 3. GROUND TILESET ATLAS (288 x 384: 9 cols x 12 rows of 32x32 tiles)
    # ─────────────────────────────────────────────────────────────────────────────
    # We use AI tiles from im1 and im3 to populate the tileset atlas
    tiles_canvas = Image.new("RGBA", (288, 384), (0, 0, 0, 0))
    
    # Extract AI rock texture patches from im1 (cells 2_0, 2_1, 2_2, 3_1, 3_2)
    rock_patch1 = im1.crop((256, 512, 512, 768)).resize((96, 96), Image.Resampling.LANCZOS)
    rock_patch2 = im1.crop((512, 512, 768, 768)).resize((96, 96), Image.Resampling.LANCZOS)
    volcanic_patch = im1.crop((256, 768, 512, 1024)).resize((96, 96), Image.Resampling.LANCZOS)
    basalt_patch = im3.crop((0, 768, 256, 1024)).resize((96, 96), Image.Resampling.LANCZOS)
    moss_top_patch = im1.crop((0, 256, 256, 512)).resize((96, 96), Image.Resampling.LANCZOS)

    # Populate 3x3 blocks across 9x12 grid:
    # Set 1 (Limestone Karst): Cols 0..2, Rows 0..2
    # Set 2 (Wall / Decor): Cols 3..5, Rows 0..2
    # Set 3 (Ledge / Floats): Cols 6..8, Rows 0..2
    # Set 4 (Lapis / Blue): Rows 3..5
    # Set 5 (Mayon Volcanic Basalt): Rows 6..8
    # Set 6 (Ancient Ruins Carved Stone): Rows 9..11
    
    for block_y in [0, 3, 6, 9]:
        for block_x in [0, 3, 6]:
            if block_y == 0:
                patch = moss_top_patch if block_x == 0 else rock_patch1
            elif block_y == 3:
                patch = rock_patch2
            elif block_y == 6:
                patch = volcanic_patch if block_x == 0 else basalt_patch
            else:
                patch = rock_patch1
                
            tiles_canvas.paste(patch, (block_x * 32, block_y * 32))
            
    # Save both rock_tiles and tileset_atlas
    rock_path = "assets/cave_platformer/cave_rock_tiles.png"
    atlas_path = "assets/cave_platformer/cave_tileset_atlas.png"
    tiles_canvas.save(rock_path)
    tiles_canvas.save(atlas_path)
    print(f"Saved AI-crafted rock tiles to {rock_path} and {atlas_path}")

build_all_assets()
