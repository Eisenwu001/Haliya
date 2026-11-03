import cv2
import numpy as np
from PIL import Image

def build_master_art():
    print("=== BUILDING MASTER CAVE ARTWORK ===")

    # -------------------------------------------------------------
    # 1. CAVE ROCK TILESET (assets/cave_platformer/cave_rock_tiles.png)
    # -------------------------------------------------------------
    sheet_tiles = Image.open('C:/Users/Lin/.gemini/antigravity/brain/e5c63084-b9ad-4add-8dcb-68444de8a484/cave_tileset_spritesheet_1792544092516.jpg')
    
    # Floor: cell_r0_c1 (256..512 in x, 0..256 in y)
    cell_floor = sheet_tiles.crop((256 + 4, 124, 256 + 252, 251))
    floor_32 = cell_floor.resize((96, 32), Image.Resampling.LANCZOS)
    
    # Ceiling: cell_r2_c0 (0..256 in x, 512..768 in y)
    cell_ceil = sheet_tiles.crop((0, 512 + 4, 252, 512 + 107))
    ceil_32 = cell_ceil.resize((96, 32), Image.Resampling.LANCZOS)
    
    # Convert white background in ceiling to transparent alpha
    ceil_arr = np.array(ceil_32.convert("RGBA"))
    is_bg_ceil = (ceil_arr[:, :, 0] > 230) & (ceil_arr[:, :, 1] > 230) & (ceil_arr[:, :, 2] > 230)
    ceil_arr[is_bg_ceil, 3] = 0
    # Anti-alias boundary
    for y in range(32):
        for x in range(96):
            if not is_bg_ceil[y, x]:
                # If adjacent to bg, blend
                if (y < 31 and is_bg_ceil[y+1, x]) or (x > 0 and is_bg_ceil[y, x-1]) or (x < 95 and is_bg_ceil[y, x+1]):
                    ceil_arr[y, x, 3] = 200
    ceil_clean = Image.fromarray(ceil_arr)
    
    # Bedrock 1 (Cracked Limestone): cell_r1_c1 (256..512, 256..512)
    cell_bed1 = sheet_tiles.crop((256 + 4, 256 + 4, 256 + 252, 256 + 252))
    bed1_96 = cell_bed1.resize((96, 96), Image.Resampling.LANCZOS).convert("RGBA")
    
    # Bedrock 2 (Quartz Veins): cell_r1_c2 (512..768, 256..512)
    cell_bed2 = sheet_tiles.crop((512 + 4, 256 + 4, 512 + 252, 256 + 252))
    bed2_96 = cell_bed2.resize((96, 96), Image.Resampling.LANCZOS).convert("RGBA")
    
    # Bedrock 3 (Sapphire Gems): cell_r3_c3 (768..1024, 768..1024)
    cell_bed3 = sheet_tiles.crop((768 + 4, 768 + 4, 768 + 252, 768 + 252))
    bed3_96 = cell_bed3.resize((96, 96), Image.Resampling.LANCZOS).convert("RGBA")

    # Bedrock 4 (Dark Basalt): cell_r3_c1 (256..512, 768..1024)
    cell_bed4 = sheet_tiles.crop((256 + 4, 768 + 4, 256 + 252, 768 + 252))
    bed4_96 = cell_bed4.resize((96, 96), Image.Resampling.LANCZOS).convert("RGBA")

    # Build 288x384 master tileset atlas
    # Columns 0..2 (0..96): Variant 1 (Sapphire / Mossy Karst)
    # Columns 3..5 (96..192): Variant 2 (Quartz Veins / Basalt)
    # Columns 6..8 (192..288): Variant 3 (Abyssal Dark Karst / Gems)
    tiles_sheet = Image.new("RGBA", (288, 384), (0, 0, 0, 0))
    
    # Function to assemble 3x3 autotile block (96x96)
    def assemble_block(floor_img, bed_img, ceil_img):
        b = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
        # Top row: floor_img
        b.paste(floor_img, (0, 0))
        # Mid row: mid row of bed_img
        b.paste(bed_img.crop((0, 32, 96, 64)), (0, 32))
        # Bot row: ceil_img
        b.paste(ceil_img, (0, 64), ceil_img)
        return b

    # Variant 1 (Sapphire / Moist Karst) at (0, 0)
    v1 = assemble_block(floor_32, bed1_96, ceil_clean)
    tiles_sheet.paste(v1, (0, 0), v1)

    # Variant 2 (Quartz Veins) at (0, 192) - used by build_cave_levels row_offset 6!
    # Tint bed2 slightly for dark basalt/veins
    v2 = assemble_block(floor_32, bed2_96, ceil_clean)
    tiles_sheet.paste(v2, (0, 192), v2)

    # Alternate bedrock variations at (96, 0), (96, 192), (192, 0), (192, 192)
    v3 = assemble_block(floor_32, bed3_96, ceil_clean)
    tiles_sheet.paste(v3, (96, 0), v3)
    
    v4 = assemble_block(floor_32, bed4_96, ceil_clean)
    tiles_sheet.paste(v4, (96, 192), v4)

    # Fill remaining rows with seamless bedrock blocks
    for y_row in [96, 288]:
        tiles_sheet.paste(bed1_96, (0, y_row))
        tiles_sheet.paste(bed2_96, (96, y_row))
        tiles_sheet.paste(bed3_96, (192, y_row))

    tiles_sheet.save('assets/cave_platformer/cave_rock_tiles.png')
    tiles_sheet.save('assets/cave_platformer/cave_tileset_atlas.png')
    tiles_sheet.save('scratch/master_cave_rock_tiles.png')
    print("Saved cave_rock_tiles.png (288x384)")

    # -------------------------------------------------------------
    # 2. CAVE PLATFORMS (assets/cave_platformer/cave_platforms.png)
    # -------------------------------------------------------------
    plat_raw = Image.open('C:/Users/Lin/.gemini/antigravity/brain/e5c63084-b9ad-4add-8dcb-68444de8a484/philippine_cave_platforms_spritesheet_1792544043909.jpg')
    
    def extract_clean_plat(crop_box, target_w, target_h, top_offset_trim=0):
        c = plat_raw.crop(crop_box).convert("RGBA")
        arr = np.array(c, dtype=float)
        rgb = arr[:, :, :3]
        gray = 0.299 * rgb[:, :, 0] + 0.587 * rgb[:, :, 1] + 0.114 * rgb[:, :, 2]
        
        # Background is dark charcoal #111111 (~17)
        # Identify background by floodfill from corners
        h, w = arr.shape[:2]
        is_bg_seed = (arr[:, :, 0] < 24) & (arr[:, :, 1] < 25) & (arr[:, :, 2] < 28)
        
        # Use cv2 floodfill from borders
        mask = np.zeros((h + 2, w + 2), np.uint8)
        seed_img = (is_bg_seed * 255).astype(np.uint8)
        
        # Flood fill from all 4 borders
        for bx in range(w):
            if seed_img[0, bx] == 255 and mask[1, bx+1] == 0:
                cv2.floodFill(seed_img, mask, (bx, 0), 128)
            if seed_img[h-1, bx] == 255 and mask[h, bx+1] == 0:
                cv2.floodFill(seed_img, mask, (bx, h-1), 128)
        for by in range(h):
            if seed_img[by, 0] == 255 and mask[by+1, 1] == 0:
                cv2.floodFill(seed_img, mask, (0, by), 128)
            if seed_img[by, w-1] == 255 and mask[by+1, w] == 0:
                cv2.floodFill(seed_img, mask, (w-1, by), 128)
                
        bg_filled = (mask[1:h+1, 1:w+1] == 128)
        
        arr[:, :, 3] = 255
        arr[bg_filled, 3] = 0
        
        # Trim top label if needed
        if top_offset_trim > 0:
            arr[:top_offset_trim, :, 3] = 0
            
        # Crop tight
        a = arr[:, :, 3]
        rows = np.where(a.max(axis=1) > 0)[0]
        cols = np.where(a.max(axis=0) > 0)[0]
        if len(rows) == 0 or len(cols) == 0:
            tight = Image.fromarray(arr.astype(np.uint8))
        else:
            tight = Image.fromarray(arr.astype(np.uint8)).crop((cols[0], rows[0], cols[-1] + 1, rows[-1] + 1))
            
        # Fit into target_w x target_h
        tw, th = target_w, target_h
        cw, ch = tight.size
        scale = tw / float(cw)
        new_h = min(th, int(round(ch * scale)))
        scaled = tight.resize((tw, new_h), Image.Resampling.LANCZOS)
        
        canvas = Image.new("RGBA", (tw, th), (0, 0, 0, 0))
        canvas.paste(scaled, (0, 0), scaled)
        
        # Ensure top row y=0..1 is 100% solid across where platform exists
        c_arr = np.array(canvas)
        for x in range(tw):
            ys = np.where(c_arr[:, x, 3] > 60)[0]
            if len(ys) > 0:
                top_y = ys[0]
                if 0 < top_y <= 5:
                    col = c_arr[top_y, x].copy()
                    for fy in range(0, top_y):
                        c_arr[fy, x] = col
                        c_arr[fy, x, 3] = 255
        return Image.fromarray(c_arr)

    plat_sheet = Image.new("RGBA", (384, 256), (0, 0, 0, 0))

    # 1. island_lg: 160 x 56 (rect: 0, 0, 160, 56)
    # Ledge 2 (wide moist limestone shelf with cave moss and roots)
    p_lg = extract_clean_plat((850, 115, 1080, 310), 160, 56)
    plat_sheet.paste(p_lg, (0, 0), p_lg)

    # 2. sanctuary: 192 x 56 (rect: 160, 0, 192, 56)
    # Wide karst limestone terrace
    p_sanc = extract_clean_plat((835, 115, 1090, 310), 192, 56)
    plat_sheet.paste(p_sanc, (160, 0), p_sanc)

    # 3. island_md: 112 x 48 (rect: 0, 64, 112, 48)
    # Ledge 4 (hanging rock with roots)
    p_md = extract_clean_plat((1218, 120, 1320, 310), 112, 48)
    plat_sheet.paste(p_md, (0, 64), p_md)

    # 4. crumble: 112 x 48 (rect: 112, 64, 112, 48)
    # Fractured limestone shelf with crumbling rock debris
    p_crm = extract_clean_plat((288, 350, 510, 460), 112, 48)
    plat_sheet.paste(p_crm, (112, 64), p_crm)

    # 5. bridge: 160 x 44 (rect: 224, 64, 160, 44)
    # Shelf 1 (solid limestone stepping stone span)
    p_brg = extract_clean_plat((45, 350, 155, 450), 160, 44)
    plat_sheet.paste(p_brg, (224, 64), p_brg)

    plat_sheet.save('assets/cave_platformer/cave_platforms.png')
    plat_sheet.save('scratch/master_cave_platforms.png')
    print("Saved cave_platforms.png (384x256)")

if __name__ == "__main__":
    build_master_art()
