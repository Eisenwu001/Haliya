import numpy as np
from PIL import Image

def generate_dirt_roots_texture():
    # 4 columns x 3 rows of 32x32 tiles (128 x 96 total)
    # Row 0: Top Subsurface Dirt with hanging root crowns
    # Row 1: Mid Subsurface Dirt with branching roots and pebbles
    # Row 2: Deep Subsurface Dirt with deep root tips and strata
    
    W, H = 128, 96
    img = np.zeros((H, W, 4), dtype=np.uint8)
    
    # Palette
    C_SOIL_BASE = [38, 29, 22, 255]      # Rich dark earth #261d16
    C_SOIL_DARK = [28, 21, 16, 255]      # Shadow earth #1c1510
    C_SOIL_MID  = [48, 38, 28, 255]      # Mid earth #30261c
    C_SOIL_DEEP = [22, 17, 14, 255]      # Bedrock earth #16110e
    
    C_ROOT_DARK = [45, 30, 18, 255]      # Root shadow
    C_ROOT_MID  = [84, 58, 36, 255]      # Root body #543a24
    C_ROOT_LIGHT= [118, 86, 54, 255]     # Root highlight #765636
    
    C_STONE_MID = [65, 72, 68, 255]      # Embedded slate pebble #414844
    C_STONE_DARK= [40, 45, 42, 255]      # Pebble shadow
    
    np.random.seed(42)
    
    for ty in range(3):
        for tx in range(4):
            x_off = tx * 32
            y_off = ty * 32
            
            # 1. Fill base soil texture with subtle organic noise
            for py in range(32):
                for px in range(32):
                    n = np.random.rand()
                    if ty == 0:
                        # Upper dirt
                        if n < 0.25:
                            col = C_SOIL_DARK
                        elif n < 0.70:
                            col = C_SOIL_BASE
                        else:
                            col = C_SOIL_MID
                    elif ty == 1:
                        # Mid dirt (slightly darker)
                        if n < 0.40:
                            col = C_SOIL_DARK
                        elif n < 0.80:
                            col = C_SOIL_BASE
                        else:
                            col = C_SOIL_MID
                    else:
                        # Deep dirt (darkest, compact earth)
                        if n < 0.55:
                            col = C_SOIL_DEEP
                        elif n < 0.85:
                            col = C_SOIL_DARK
                        else:
                            col = C_SOIL_BASE
                    img[y_off + py, x_off + px] = col
            
            # 2. Add organic root tendrils
            # Each variation has distinct winding paths
            root_paths = []
            if ty == 0: # Upper: vertical root taproots entering from top
                if tx == 0:
                    root_paths.append([(6, 0), (7, 8), (9, 18), (8, 26), (10, 31)])
                    root_paths.append([(22, 0), (21, 10), (19, 20), (17, 31)])
                    root_paths.append([(9, 18), (14, 25), (15, 31)]) # small branch
                elif tx == 1:
                    root_paths.append([(14, 0), (13, 9), (12, 17), (14, 25), (16, 31)])
                    root_paths.append([(27, 0), (28, 8), (26, 16), (23, 24)])
                    root_paths.append([(12, 17), (7, 23), (5, 31)])
                elif tx == 2:
                    root_paths.append([(3, 0), (4, 10), (6, 20), (8, 31)])
                    root_paths.append([(18, 0), (19, 7), (22, 15), (20, 24), (19, 31)])
                    root_paths.append([(22, 15), (26, 22), (28, 31)])
                elif tx == 3:
                    root_paths.append([(10, 0), (11, 12), (10, 22), (9, 31)])
                    root_paths.append([(24, 0), (23, 11), (25, 20), (27, 31)])
                    root_paths.append([(11, 12), (16, 19), (17, 27)])
            elif ty == 1: # Mid: twisting roots crossing through soil
                if tx == 0:
                    root_paths.append([(10, 0), (11, 10), (13, 22), (12, 31)])
                    root_paths.append([(17, 0), (15, 9), (12, 16)]) # merge into main
                    root_paths.append([(13, 22), (18, 28), (20, 31)])
                elif tx == 1:
                    root_paths.append([(16, 0), (17, 12), (15, 21), (13, 31)])
                    root_paths.append([(5, 0), (7, 10), (9, 20), (8, 31)])
                elif tx == 2:
                    root_paths.append([(8, 0), (9, 11), (12, 20), (11, 31)])
                    root_paths.append([(19, 0), (18, 9), (16, 19), (17, 31)])
                    root_paths.append([(28, 0), (27, 12), (25, 22), (26, 31)])
                elif tx == 3:
                    root_paths.append([(9, 0), (8, 10), (10, 21), (11, 31)])
                    root_paths.append([(27, 0), (25, 12), (22, 22), (20, 31)])
            else: # Deep: tapering fine root tips
                if tx == 0:
                    root_paths.append([(12, 0), (13, 8), (14, 15)])
                    root_paths.append([(20, 0), (19, 10), (18, 18)])
                elif tx == 1:
                    root_paths.append([(13, 0), (12, 9), (11, 17)])
                    root_paths.append([(8, 0), (9, 8), (10, 14)])
                elif tx == 2:
                    root_paths.append([(11, 0), (12, 11), (13, 19)])
                    root_paths.append([(17, 0), (16, 7), (15, 13)])
                elif tx == 3:
                    root_paths.append([(11, 0), (12, 10), (13, 16)])
                    root_paths.append([(20, 0), (19, 8), (18, 14)])
            
            # Draw root segments
            for pts in root_paths:
                for i in range(len(pts) - 1):
                    p0 = pts[i]
                    p1 = pts[i+1]
                    dist = max(abs(p1[0] - p0[0]), abs(p1[1] - p0[1]))
                    for step in range(dist + 1):
                        f = float(step) / max(dist, 1)
                        rx = int(round(p0[0] + (p1[0] - p0[0]) * f))
                        ry = int(round(p0[1] + (p1[1] - p0[1]) * f))
                        if 0 <= rx < 32 and 0 <= ry < 32:
                            # Main root body
                            img[y_off + ry, x_off + rx] = C_ROOT_MID
                            # Highlight on left
                            if rx > 0:
                                img[y_off + ry, x_off + rx - 1] = C_ROOT_LIGHT
                            # Shadow on right
                            if rx < 31:
                                img[y_off + ry, x_off + rx + 1] = C_ROOT_DARK
                                
            # 3. Add small pebbles in mid and deep layers
            if ty >= 1:
                pebble_pos = [(18, 12), (6, 24)] if tx % 2 == 0 else [(24, 8), (10, 18)]
                for px, py in pebble_pos:
                    if 1 <= px < 30 and 1 <= py < 30:
                        img[y_off + py, x_off + px] = C_STONE_MID
                        img[y_off + py, x_off + px + 1] = C_STONE_MID
                        img[y_off + py + 1, x_off + px] = C_STONE_DARK
                        img[y_off + py + 1, x_off + px + 1] = C_STONE_DARK
                        
    im = Image.fromarray(img)
    im.save('assets/platform_assets/forest_dirt_roots.png')
    print('Saved assets/platform_assets/forest_dirt_roots.png (128x96)')

generate_dirt_roots_texture()
