import os
import cv2
import numpy as np
from PIL import Image

def create_rich_cave_tile(
    base_tex: np.ndarray,
    tile_type: str,
    moss_color=(135, 235, 248),
    is_basalt=False
) -> np.ndarray:
    """
    Creates a single 32x32 master-grade cave tile with authentic rock textures,
    mineral moss highlights on top, and hanging stalactite teeth on ceilings.
    """
    h, w = 32, 32
    tile = np.zeros((h, w, 4), dtype=np.uint8)
    
    # Base textured bedrock fill
    tex_crop = cv2.resize(base_tex, (w, h), interpolation=cv2.INTER_LANCZOS4)
    if is_basalt:
        tex_crop = (tex_crop * 0.75).astype(np.uint8)
    else:
        tex_crop[:, :, 0] = np.clip(tex_crop[:, :, 0] * 0.85 + 6, 0, 255)
        tex_crop[:, :, 1] = np.clip(tex_crop[:, :, 1] * 0.95 + 12, 0, 255)
        tex_crop[:, :, 2] = np.clip(tex_crop[:, :, 2] * 1.15 + 22, 0, 255)
        
    tile[:, :, :3] = tex_crop[:, :, :3]
    tile[:, :, 3] = 255 # Solid alpha
    
    # Apply type-specific cave sculpting
    if "top" in tile_type:
        # High-contrast walkable cave rock rim (y=0..2)
        for x in range(w):
            tile[0, x, :3] = [moss_color[0], moss_color[1], moss_color[2]]
            tile[1, x, :3] = [int(moss_color[0] * 0.75), int(moss_color[1] * 0.85), int(moss_color[2] * 0.90)]
            tile[2, x, :3] = [int(moss_color[0] * 0.50), int(moss_color[1] * 0.60), int(moss_color[2] * 0.70)]
            
    if "bot" in tile_type:
        # Hanging stalactite ceiling teeth (y=16..31)
        for x in range(w):
            dist1 = abs(x - 8)
            dist2 = abs(x - 24)
            tip1 = max(0, 14 - dist1 * 3)
            tip2 = max(0, 15 - dist2 * 3)
            max_y = 16 + max(tip1, tip2)
            
            if max_y < 31:
                tile[max_y+1:32, x, 3] = 0
                tile[max_y, x, :3] = (tile[max_y, x, :3].astype(float) * 0.45).astype(np.uint8)
                
    if "left" in tile_type:
        for y in range(h):
            if tile[y, 0, 3] > 0:
                tile[y, 0, :3] = (tile[y, 0, :3].astype(float) * 0.55).astype(np.uint8)
                if tile[y, 1, 3] > 0:
                    tile[y, 1, :3] = (tile[y, 1, :3].astype(float) * 0.75).astype(np.uint8)
                    
    if "right" in tile_type:
        for y in range(h):
            if tile[y, 31, 3] > 0:
                tile[y, 31, :3] = (tile[y, 31, :3].astype(float) * 0.55).astype(np.uint8)
                if tile[y, 30, 3] > 0:
                    tile[y, 30, :3] = (tile[y, 30, :3].astype(float) * 0.75).astype(np.uint8)

    # Add subtle quartz/fluorite crystal flecks in the rock body
    np.random.seed(sum(tile_type.encode()) % 1000)
    for _ in range(4):
        rx, ry = np.random.randint(4, 28), np.random.randint(4, 28)
        if tile[ry, rx, 3] > 100:
            tile[ry, rx, :3] = [185, 245, 255] # Cyan crystalline speck
            
    return tile

def build_artistic_cave_tileset():
    master_path = r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_subterranean_cave_tileset_1792544013682.jpg"
    im = Image.open(master_path).convert("RGBA")
    master_arr = np.array(im)
    
    sheet_arr = np.zeros((384, 288, 4), dtype=np.uint8)
    
    variants = [
        ("sapphire", 0, (135, 235, 248), False),
        ("basalt",   6, (160, 215, 205), True)
    ]
    
    tile_defs = [
        (0, 0, "top_left"),
        (1, 0, "top"),
        (2, 0, "top_right"),
        (0, 1, "left"),
        (1, 1, "center"),
        (2, 1, "right"),
        (0, 2, "bot_left"),
        (1, 2, "bot"),
        (2, 2, "bot_right"),
    ]
    
    for vname, y_off, moss_col, is_bas in variants:
        for cx, cy, ttype in tile_defs:
            sx = (cx * 110 + 40) % (master_arr.shape[1] - 80)
            sy = ((cy + y_off) * 55 + 60) % (master_arr.shape[0] - 80)
            crop_base = master_arr[sy:sy+64, sx:sx+64, :3]
            tile = create_rich_cave_tile(crop_base, ttype, moss_col, is_basalt=is_bas)
            dest_x = cx * 32
            dest_y = (cy + y_off) * 32
            sheet_arr[dest_y:dest_y+32, dest_x:dest_x+32] = tile
            
    for vname, y_off, moss_col, is_bas in variants:
        for extra_x in range(3, 9):
            for extra_y in range(3):
                sx = (extra_x * 90 + 70) % (master_arr.shape[1] - 80)
                sy = ((extra_y + y_off) * 70 + 80) % (master_arr.shape[0] - 80)
                crop_base = master_arr[sy:sy+64, sx:sx+64, :3]
                ttype = "center" if extra_y == 1 else ("top" if extra_y == 0 else "bot")
                tile = create_rich_cave_tile(crop_base, ttype, moss_col, is_basalt=is_bas)
                dest_x = extra_x * 32
                dest_y = (extra_y + y_off) * 32
                sheet_arr[dest_y:dest_y+32, dest_x:dest_x+32] = tile
                
    out_img = Image.fromarray(sheet_arr)
    target_path = "assets/cave_platformer/cave_rock_tiles.png"
    out_img.save(target_path)
    out_img.save("assets/cave_platformer/cave_tileset_atlas.png")
    out_img.save("scratch/cave_rock_tiles_artistic.png")
    print(f"Successfully generated artistic cave rock tileset: {target_path} (288x384)")

if __name__ == "__main__":
    build_artistic_cave_tileset()
