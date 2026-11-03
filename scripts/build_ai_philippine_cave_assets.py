import os
import cv2
import numpy as np
from PIL import Image

def isolate_sprite(img_crop, bg_thresh=18):
    """Cleanly extracts foreground from dark background using color distance and morphology."""
    arr = np.array(img_crop.convert("RGBA"), dtype=float)
    rgb = arr[:,:,:3]
    gray = 0.299 * rgb[:,:,0] + 0.587 * rgb[:,:,1] + 0.114 * rgb[:,:,2]
    
    corners = [gray[0,0], gray[0,-1], gray[-1,0], gray[-1,-1]]
    bg_val = np.median(corners)
    
    bg_rgb = np.median([rgb[0,0], rgb[0,-1], rgb[-1,0], rgb[-1,-1]], axis=0)
    color_dist = np.linalg.norm(rgb - bg_rgb, axis=2)
    diff = np.abs(gray - bg_val)
    
    # Mask foreground
    mask = (color_dist > 16.0) | (diff > 14.0) | (gray > 40.0)
    mask_u8 = (mask * 255).astype(np.uint8)
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (3, 3))
    mask_clean = cv2.morphologyEx(mask_u8, cv2.MORPH_CLOSE, kernel)
    
    alpha = cv2.GaussianBlur(mask_clean.astype(float), (3, 3), 0.5)
    arr[:,:,3] = np.clip(alpha, 0, 255)
    return Image.fromarray(arr.astype(np.uint8))

def crop_solid_box(im, min_alpha=80):
    arr = np.array(im)
    alpha = arr[:,:,3]
    rows = np.where(alpha.max(axis=1) >= min_alpha)[0]
    cols = np.where(alpha.max(axis=0) >= min_alpha)[0]
    if len(rows) == 0 or len(cols) == 0:
        return im
    return im.crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))

def create_flush_platform(raw_crop, target_w, target_h):
    """Extracts platform with 100% flush top surface at y=0."""
    iso = isolate_sprite(raw_crop)
    tight = crop_solid_box(iso, min_alpha=90)
    
    tw, th = target_w, target_h
    cw, ch = tight.size
    scale = min(tw / cw, th / ch)
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = tight.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    pos_x = (tw - nw) // 2
    canvas.paste(scaled, (pos_x, 0), scaled)
    
    c_arr = np.array(canvas)
    # Pull any small sub-pixel gap at the top to y=0
    for x in range(pos_x, pos_x + nw):
        first_y = 0
        while first_y < th and c_arr[first_y, x, 3] < 100:
            first_y += 1
        if 0 < first_y < 8:
            for y_fill in range(first_y):
                c_arr[y_fill, x] = c_arr[first_y, x]
                c_arr[y_fill, x, 3] = 255
                
    return Image.fromarray(c_arr)

def create_flush_bottom_prop(raw_crop, target_w, target_h):
    """Extracts prop with bottom sitting flush at y=target_h."""
    iso = isolate_sprite(raw_crop)
    tight = crop_solid_box(iso, min_alpha=80)
    
    tw, th = target_w, target_h
    cw, ch = tight.size
    scale = min((tw - 4) / cw, (th - 4) / ch)
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = tight.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    pos_x = (tw - nw) // 2
    pos_y = th - nh
    canvas.paste(scaled, (pos_x, pos_y), scaled)
    return canvas

def create_flush_top_prop(raw_crop, target_w, target_h):
    """Extracts prop (e.g. stalactite) with top flush at y=0."""
    iso = isolate_sprite(raw_crop)
    tight = crop_solid_box(iso, min_alpha=80)
    
    tw, th = target_w, target_h
    cw, ch = tight.size
    scale = min((tw - 4) / cw, (th - 4) / ch)
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = tight.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    pos_x = (tw - nw) // 2
    canvas.paste(scaled, (pos_x, 0), scaled)
    return canvas

def create_centered_prop(raw_crop, target_w, target_h):
    """Extracts centered floating prop (e.g. Mutya pearl)."""
    iso = isolate_sprite(raw_crop)
    tight = crop_solid_box(iso, min_alpha=70)
    
    tw, th = target_w, target_h
    cw, ch = tight.size
    scale = min((tw - 6) / cw, (th - 6) / ch)
    nw = int(round(cw * scale))
    nh = int(round(ch * scale))
    scaled = tight.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
    pos_x = (tw - nw) // 2
    pos_y = (th - nh) // 2
    canvas.paste(scaled, (pos_x, pos_y), scaled)
    return canvas


def main():
    base_dir = r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484"
    im1_path = os.path.join(base_dir, "philippine_subterranean_cave_tileset_1792544013682.jpg")
    im2_path = os.path.join(base_dir, "philippine_cave_platforms_spritesheet_1792544043909.jpg")
    im3_path = os.path.join(base_dir, "cave_tileset_spritesheet_1792544092516.jpg")

    im1 = Image.open(im1_path)
    im2 = Image.open(im2_path)
    im3 = Image.open(im3_path)

    # ─────────────────────────────────────────────────────────────────────────────
    # 1. CAVE PLATFORMS (224 x 160)
    # ─────────────────────────────────────────────────────────────────────────────
    plat_canvas = Image.new("RGBA", (224, 160), (0, 0, 0, 0))

    # Bridge: Tulay na Kawayan (from im2 x=44..680, y=98..285)
    raw_bridge = im2.crop((44, 98, 680, 285))
    bridge_plat = create_flush_platform(raw_bridge, 128, 40)
    plat_canvas.paste(bridge_plat, (0, 64), bridge_plat)

    # Large Mossy Limestone Ledge: island_lg (from im2 x=725..865, y=100..260)
    raw_island_lg = im2.crop((725, 100, 865, 260))
    island_lg_plat = create_flush_platform(raw_island_lg, 128, 56)
    plat_canvas.paste(island_lg_plat, (0, 0), island_lg_plat)

    # Medium Limestone Ledge: island_md (from im2 x=1220..1335, y=100..270)
    raw_island_md = im2.crop((1220, 100, 1335, 270))
    island_md_plat = create_flush_platform(raw_island_md, 96, 48)
    plat_canvas.paste(island_md_plat, (128, 0), island_md_plat)

    # Brittle Limestone Shelf: crumble (from im2 x=1100..1210, y=100..265)
    raw_crumble = im2.crop((1100, 100, 1210, 265))
    crumble_plat = create_flush_platform(raw_crumble, 96, 48)
    plat_canvas.paste(crumble_plat, (128, 64), crumble_plat)

    # Pre-colonial Sanctuary Terrace: sanctuary (from im2 x=870..1100, y=100..270)
    raw_sanctuary = im2.crop((870, 100, 1100, 270))
    sanctuary_plat = create_flush_platform(raw_sanctuary, 160, 56)
    plat_canvas.paste(sanctuary_plat, (0, 104), sanctuary_plat)

    plat_out = "assets/cave_platformer/cave_platforms.png"
    plat_canvas.save(plat_out)
    print(f"Wrote {plat_out}")

    # ─────────────────────────────────────────────────────────────────────────────
    # 2. CAVE PROPS (320 x 160)
    # ─────────────────────────────────────────────────────────────────────────────
    props_canvas = Image.new("RGBA", (320, 160), (0, 0, 0, 0))

    # Manunggul Burial Jar (from im2 x=360..485, y=545..705)
    raw_jar = im2.crop((360, 545, 485, 705))
    jar_prop = create_flush_bottom_prop(raw_jar, 64, 64)
    props_canvas.paste(jar_prop, (0, 0), jar_prop)

    # Carved Anito / Likha Totem (from im2 x=40..138, y=545..705)
    raw_totem = im2.crop((40, 545, 138, 705))
    totem_prop = create_flush_bottom_prop(raw_totem, 64, 96)
    props_canvas.paste(totem_prop, (64, 0), totem_prop)

    # Subterranean Pako River Ferns (from im2 x=980..1135, y=535..700)
    raw_ferns = im2.crop((980, 535, 1135, 700))
    ferns_prop = create_flush_bottom_prop(raw_ferns, 64, 64)
    props_canvas.paste(ferns_prop, (128, 0), ferns_prop)

    # Ceiling Limestone Stalactites (from im2 x=760..910, y=560..690)
    raw_stalactite = im2.crop((760, 560, 910, 690))
    stalactite_prop = create_flush_top_prop(raw_stalactite, 96, 64)
    props_canvas.paste(stalactite_prop, (192, 0), stalactite_prop)

    # Bamboo Sulo Torch (from im2 x=200..260, y=545..685)
    raw_torch = im2.crop((200, 545, 260, 685))
    torch_prop = create_flush_bottom_prop(raw_torch, 32, 64)
    props_canvas.paste(torch_prop, (0, 64), torch_prop)

    # Limestone Stalagmites (Hazard Spikes) (from im2 x=535..655, y=335..455)
    raw_spikes = im2.crop((535, 335, 655, 455))
    spikes_prop = create_flush_bottom_prop(raw_spikes, 96, 32)
    props_canvas.paste(spikes_prop, (64, 64), spikes_prop)

    # Resonant Moon Pearl (Mutya ng Haliya) (from im2 x=540..700, y=540..705)
    raw_pearl = im2.crop((540, 540, 700, 705))
    pearl_prop = create_centered_prop(raw_pearl, 64, 64)
    props_canvas.paste(pearl_prop, (160, 64), pearl_prop)

    # Earthenware Palayok Pot (from im2 x=255..340, y=545..645)
    raw_pot = im2.crop((255, 545, 340, 645))
    pot_prop = create_flush_bottom_prop(raw_pot, 48, 48)
    props_canvas.paste(pot_prop, (224, 64), pot_prop)

    props_out = "assets/cave_platformer/cave_props.png"
    props_canvas.save(props_out)
    print(f"Wrote {props_out}")

    # ─────────────────────────────────────────────────────────────────────────────
    # 3. GROUND TILESET ATLAS (288 x 384)
    # ─────────────────────────────────────────────────────────────────────────────
    # 9 columns x 12 rows of 32x32 tiles.
    tiles_canvas = Image.new("RGBA", (288, 384), (0, 0, 0, 0))

    # High-detail AI textures:
    # 1. Top mossy limestone surface (from im1 cells 0_0, 0_1, 0_2)
    ai_moss_surface = im1.crop((30, 320, 700, 450))
    # 2. Rock strata cavern core (from im1 cells 2_1, 2_2)
    ai_rock_strata = im1.crop((256, 512, 512, 768))
    # 3. Mayon volcanic basalt / obsidian (from im3 row 3)
    ai_basalt = im3.crop((0, 770, 512, 1024))
    # 4. Ceiling stalactites & lower edge (from im3 row 2)
    ai_ceiling = im3.crop((512, 512, 1024, 768))

    # Helper to tile / sample into 32x32 blocks
    for col in range(9):
        for row in range(12):
            tx = col * 32
            ty = row * 32
            
            # Select appropriate AI block
            if row in [0, 3]:
                # Top ground surface tile!
                # Sample 96x96 area from ai_moss_surface or ai_rock_strata
                sx = (col * 70) % (ai_moss_surface.width - 64)
                sy = 0
                sample = ai_moss_surface.crop((sx, sy, sx + 64, sy + 64)).resize((32, 32), Image.Resampling.LANCZOS).convert("RGBA")
                # Ensure top row of pixel y=0 is solid for flush character stepping!
                s_arr = np.array(sample)
                s_arr[:,:,3] = 255 # Solid tile
                tile = Image.fromarray(s_arr)
            elif row in [1, 4]:
                # Cavern core rock fill
                sx = (col * 50) % (ai_rock_strata.width - 64)
                sy = (row * 40) % (ai_rock_strata.height - 64)
                sample = ai_rock_strata.crop((sx, sy, sx + 64, sy + 64)).resize((32, 32), Image.Resampling.LANCZOS).convert("RGBA")
                s_arr = np.array(sample)
                s_arr[:,:,3] = 255
                tile = Image.fromarray(s_arr)
            elif row in [2, 5]:
                # Cavern bottom / ceiling edge
                sx = (col * 50) % (ai_ceiling.width - 64)
                sy = 0
                sample = ai_ceiling.crop((sx, sy, sx + 64, sy + 64)).resize((32, 32), Image.Resampling.LANCZOS).convert("RGBA")
                s_arr = np.array(sample)
                s_arr[:,:,3] = 255
                tile = Image.fromarray(s_arr)
            elif row in [6, 7, 8]:
                # Mayon Volcanic Basalt / Obsidian
                sx = (col * 45) % (ai_basalt.width - 64)
                sy = ((row - 6) * 45) % (ai_basalt.height - 64)
                sample = ai_basalt.crop((sx, sy, sx + 64, sy + 64)).resize((32, 32), Image.Resampling.LANCZOS).convert("RGBA")
                s_arr = np.array(sample)
                s_arr[:,:,3] = 255
                tile = Image.fromarray(s_arr)
            else:
                # Ancient pre-colonial carved stone ruins (Rows 9..11)
                sx = (col * 40) % (ai_rock_strata.width - 64)
                sy = ((row - 9) * 40) % (ai_rock_strata.height - 64)
                sample = ai_rock_strata.crop((sx, sy, sx + 64, sy + 64)).resize((32, 32), Image.Resampling.LANCZOS).convert("RGBA")
                s_arr = np.array(sample)
                s_arr[:,:,3] = 255
                tile = Image.fromarray(s_arr)
                
            tiles_canvas.paste(tile, (tx, ty))

    tiles_out = "assets/cave_platformer/cave_rock_tiles.png"
    atlas_out = "assets/cave_platformer/cave_tileset_atlas.png"
    tiles_canvas.save(tiles_out)
    tiles_canvas.save(atlas_out)
    print(f"Wrote {tiles_out} and {atlas_out}")

if __name__ == "__main__":
    main()
