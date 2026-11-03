import numpy as np
from PIL import Image

def generate_rock_texture(w, h, base_color, accent_color, seed=42):
    np.random.seed(seed)
    arr = np.zeros((h, w, 4), dtype=np.uint8)
    arr[:, :, 3] = 255
    
    br, bg, bb = base_color
    ar, ag, ab = accent_color
    
    # Base fill
    for y in range(h):
        for x in range(w):
            # Horizontal geological strata wave
            strata = np.sin((y + np.sin(x * 0.15) * 3.0) * 0.45)
            # Micro-noise
            noise = np.random.uniform(-0.15, 0.15)
            val = strata * 0.35 + noise
            
            # Subtle stone color variance
            r = int(np.clip(br + val * 16.0, br - 8, br + 22))
            g = int(np.clip(bg + val * 20.0, bg - 10, bg + 26))
            b = int(np.clip(bb + val * 28.0, bb - 12, bb + 36))
            
            # Occasional subtle dark crevice / crack line
            if (y % 16 == 0 and (x + y // 2) % 7 != 0) or ((x + y) % 31 == 0 and x % 4 != 0):
                r = max(4, r - 10)
                g = max(6, g - 12)
                b = max(10, b - 16)
                
            # Occasional micro mineral sparkle (1 in 80 pixels)
            if np.random.random() < 0.012:
                r = int(np.clip(r + ar * 0.6, 0, 255))
                g = int(np.clip(g + ag * 0.6, 0, 255))
                b = int(np.clip(b + ab * 0.6, 0, 255))
                
            arr[y, x, 0] = r
            arr[y, x, 1] = g
            arr[y, x, 2] = b
            
    return arr

def main():
    src_path = "assets/cave_platformer/cave_rock_tiles.png"
    img = Image.open(src_path)
    arr = np.array(img)
    
    # Cyan section: rows 0..192
    # Base color: (18, 25, 42), Accent: (60, 220, 255)
    cyan_tex = generate_rock_texture(288, 192, (18, 25, 42), (50, 210, 255), seed=101)
    
    # Purple section: rows 192..384
    # Base color: (28, 20, 42), Accent: (190, 110, 255)
    purp_tex = generate_rock_texture(288, 192, (26, 18, 40), (180, 100, 255), seed=202)
    
    # Where existing pixels are flat base color and fully opaque, blend the texture
    # Cyan flat mask:
    cyan_flat = (arr[:192, :, 3] == 255) & (arr[:192, :, 0] <= 24) & (arr[:192, :, 1] <= 32) & (arr[:192, :, 2] <= 52)
    arr[:192, :, :3][cyan_flat] = cyan_tex[:192, :, :3][cyan_flat]
    
    # Purple flat mask:
    purp_flat = (arr[192:, :, 3] == 255) & (arr[192:, :, 0] <= 36) & (arr[192:, :, 1] <= 26) & (arr[192:, :, 2] <= 52)
    arr[192:, :, :3][purp_flat] = purp_tex[:192, :, :3][purp_flat]
    
    res = Image.fromarray(arr, "RGBA")
    res.save("assets/cave_platformer/cave_rock_tiles.png")
    res.save("assets/cave_platformer/cave_tileset_atlas.png")
    print("Enriched cave_rock_tiles.png and cave_tileset_atlas.png with realistic geological strata!")

if __name__ == "__main__":
    main()
