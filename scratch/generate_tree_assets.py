import os
import math
import random
from PIL import Image, ImageDraw

os.makedirs("assets/foliage", exist_ok=True)

# ── Authentic Color Palette matching background_layer_1 and foreground pixel art ──
C_CLEAR = (0, 0, 0, 0)

# Bark tones
BARK_OUTLINE = (27, 21, 18, 255)
BARK_SHADOW = (48, 36, 32, 255)
BARK_DEEP = (68, 48, 38, 255)
BARK_MID = (86, 58, 44, 255)
BARK_LGT = (108, 74, 54, 255)
BARK_RIM = (136, 96, 68, 255)

# Foliage tones (rich forest olive matching background_layer_1 & Tree1)
LEAF_OUTLINE = (18, 32, 16, 255)
LEAF_SHADOW = (32, 52, 24, 255)
LEAF_DEEP = (48, 68, 34, 255)
LEAF_MID = (66, 86, 46, 255)
LEAF_LGT = (88, 114, 56, 255)
LEAF_RIM = (118, 142, 68, 255)
LEAF_SPEC = (148, 172, 86, 255)

def draw_umbrella_dome(pixels, cx, cy, rx, ry, seed=42):
    """Draws a layered umbrella/cloud canopy cluster with pixel-art shading."""
    rnd = random.Random(seed)
    for dy in range(-ry - 2, ry + 3):
        for dx in range(-rx - 3, rx + 4):
            x = cx + dx
            y = cy + dy
            # Flat-bottomed dome: lower half is flatter (acacia umbrella style)
            norm_y = dy / float(ry)
            if norm_y > 0:
                norm_y *= 1.4 # Flatter on bottom
            norm_x = dx / float(rx)
            dist_sq = norm_x * norm_x + norm_y * norm_y
            
            # Leaf edge dither/scallop
            angle = math.atan2(dy, dx)
            scallop = 0.12 * math.cos(angle * 7.0 + rnd.uniform(-0.3, 0.3))
            
            if dist_sq + scallop <= 1.05:
                # Determine lighting (sun from top-left, flatter shadow on bottom)
                sun_factor = (norm_x * -0.5 - norm_y * 0.85) # range roughly -1.3 to 1.3
                
                # Leaf cluster dithering
                cluster_noise = rnd.uniform(-0.18, 0.18)
                shade = sun_factor + cluster_noise
                
                # Edge outline
                if dist_sq + scallop > 0.88:
                    if shade < 0.1:
                        color = LEAF_OUTLINE
                    else:
                        color = LEAF_SHADOW
                elif shade > 0.75:
                    color = LEAF_SPEC
                elif shade > 0.45:
                    color = LEAF_RIM
                elif shade > 0.15:
                    color = LEAF_LGT
                elif shade > -0.20:
                    color = LEAF_MID
                elif shade > -0.55:
                    color = LEAF_DEEP
                else:
                    color = LEAF_SHADOW
                
                # Blend if existing
                if 0 <= x < len(pixels[0]) and 0 <= y < len(pixels):
                    cur = pixels[y][x]
                    if cur[3] == 0 or color[3] > 0:
                        # Only overwrite with shadow if current is empty or current is behind
                        pixels[y][x] = color

def draw_branch(pixels, x0, y0, x1, y1, width0, width1, seed=123):
    """Draws a curved wooden branch with bark texture."""
    rnd = random.Random(seed)
    steps = int(max(abs(x1 - x0), abs(y1 - y0)) * 2)
    if steps == 0:
        return
    for i in range(steps + 1):
        t = i / float(steps)
        # Slight quadratic arch
        arch = -12.0 * t * (1.0 - t)
        cx = x0 + (x1 - x0) * t
        cy = y0 + (y1 - y0) * t + arch
        cur_w = width0 + (width1 - width0) * t
        hw = cur_w * 0.5
        
        for dw in range(-int(hw) - 1, int(hw) + 2):
            px = int(round(cx + dw))
            py = int(round(cy))
            if 0 <= px < len(pixels[0]) and 0 <= py < len(pixels):
                norm_w = dw / (hw if hw > 0 else 1.0)
                if abs(norm_w) <= 1.0:
                    # Shading: light from top/left (negative dw)
                    if abs(norm_w) > 0.85:
                        pixels[py][px] = BARK_OUTLINE
                    elif norm_w < -0.35:
                        pixels[py][px] = BARK_RIM if norm_w < -0.65 else BARK_LGT
                    elif norm_w < 0.2:
                        pixels[py][px] = BARK_MID
                    elif norm_w < 0.7:
                        pixels[py][px] = BARK_DEEP
                    else:
                        pixels[py][px] = BARK_SHADOW

def generate_large_canopy_tree():
    w, h = 192, 160
    pixels = [[C_CLEAR for _ in range(w)] for _ in range(h)]
    
    # 1. Main trunk & root flare (Bottom center: x=96, y=156)
    trunk_base_x = 96
    trunk_base_y = 158
    
    # Root buttresses
    draw_branch(pixels, trunk_base_x, trunk_base_y - 20, trunk_base_x - 24, trunk_base_y, 14, 5, seed=1)
    draw_branch(pixels, trunk_base_x, trunk_base_y - 20, trunk_base_x + 24, trunk_base_y, 14, 5, seed=2)
    draw_branch(pixels, trunk_base_x, trunk_base_y - 30, trunk_base_x - 10, trunk_base_y, 16, 8, seed=3)
    draw_branch(pixels, trunk_base_x, trunk_base_y - 30, trunk_base_x + 10, trunk_base_y, 16, 8, seed=4)
    
    # Central Trunk
    draw_branch(pixels, trunk_base_x, trunk_base_y - 10, trunk_base_x - 2, 95, 20, 15, seed=5)
    
    # Major Branching limbs (Acacia/Narra umbrella architecture)
    # Left main branch
    draw_branch(pixels, trunk_base_x - 2, 98, 48, 65, 14, 8, seed=6)
    draw_branch(pixels, 52, 68, 28, 55, 8, 4, seed=7)
    draw_branch(pixels, 65, 75, 45, 80, 7, 4, seed=8)
    
    # Right main branch
    draw_branch(pixels, trunk_base_x + 2, 98, 144, 65, 14, 8, seed=9)
    draw_branch(pixels, 140, 68, 164, 55, 8, 4, seed=10)
    draw_branch(pixels, 128, 75, 148, 80, 7, 4, seed=11)
    
    # Center-left and center-right upper branches
    draw_branch(pixels, trunk_base_x - 4, 92, 78, 45, 12, 6, seed=12)
    draw_branch(pixels, trunk_base_x + 4, 92, 114, 45, 12, 6, seed=13)
    draw_branch(pixels, 96, 75, 96, 38, 9, 5, seed=14)
    
    # 2. Layered Umbrella Canopy Domes
    # Background canopy layers (lower & side clusters)
    draw_umbrella_dome(pixels, 28, 55, 26, 18, seed=101)
    draw_umbrella_dome(pixels, 164, 55, 26, 18, seed=102)
    draw_umbrella_dome(pixels, 44, 76, 22, 15, seed=103)
    draw_umbrella_dome(pixels, 148, 76, 22, 15, seed=104)
    
    # Mid canopy layers
    draw_umbrella_dome(pixels, 55, 42, 32, 22, seed=105)
    draw_umbrella_dome(pixels, 137, 42, 32, 22, seed=106)
    draw_umbrella_dome(pixels, 76, 32, 34, 24, seed=107)
    draw_umbrella_dome(pixels, 116, 32, 34, 24, seed=108)
    
    # Crown central canopy dome (spreading umbrella top)
    draw_umbrella_dome(pixels, 96, 24, 42, 26, seed=109)
    
    # Convert pixels to Image
    img = Image.new("RGBA", (w, h))
    for y in range(h):
        for x in range(w):
            img.putpixel((x, y), pixels[y][x])
    return img

def generate_medium_canopy_tree():
    w, h = 128, 128
    pixels = [[C_CLEAR for _ in range(w)] for _ in range(h)]
    
    trunk_base_x = 64
    trunk_base_y = 126
    
    # Root flare
    draw_branch(pixels, trunk_base_x, trunk_base_y - 15, trunk_base_x - 16, trunk_base_y, 11, 4, seed=201)
    draw_branch(pixels, trunk_base_x, trunk_base_y - 15, trunk_base_x + 16, trunk_base_y, 11, 4, seed=202)
    
    # Trunk
    draw_branch(pixels, trunk_base_x, trunk_base_y - 8, trunk_base_x, 75, 14, 10, seed=203)
    
    # Branches
    draw_branch(pixels, trunk_base_x, 78, 32, 52, 9, 5, seed=204)
    draw_branch(pixels, trunk_base_x, 78, 96, 52, 9, 5, seed=205)
    draw_branch(pixels, trunk_base_x, 72, 54, 38, 8, 4, seed=206)
    draw_branch(pixels, trunk_base_x, 72, 74, 38, 8, 4, seed=207)
    
    # Canopies
    draw_umbrella_dome(pixels, 26, 48, 22, 15, seed=301)
    draw_umbrella_dome(pixels, 102, 48, 22, 15, seed=302)
    draw_umbrella_dome(pixels, 46, 34, 26, 18, seed=303)
    draw_umbrella_dome(pixels, 82, 34, 26, 18, seed=304)
    draw_umbrella_dome(pixels, 64, 22, 30, 20, seed=305)
    
    img = Image.new("RGBA", (w, h))
    for y in range(h):
        for x in range(w):
            img.putpixel((x, y), pixels[y][x])
    return img

def generate_cluster_canopy_tree():
    w, h = 96, 88
    pixels = [[C_CLEAR for _ in range(w)] for _ in range(h)]
    
    trunk_base_x = 48
    trunk_base_y = 86
    
    # Roots & Short Sturdy Trunk
    draw_branch(pixels, trunk_base_x, trunk_base_y - 10, trunk_base_x - 12, trunk_base_y, 9, 3, seed=401)
    draw_branch(pixels, trunk_base_x, trunk_base_y - 10, trunk_base_x + 12, trunk_base_y, 9, 3, seed=402)
    draw_branch(pixels, trunk_base_x, trunk_base_y - 6, trunk_base_x, 52, 11, 8, seed=403)
    
    # Short forks
    draw_branch(pixels, trunk_base_x, 54, 26, 38, 7, 4, seed=404)
    draw_branch(pixels, trunk_base_x, 54, 70, 38, 7, 4, seed=405)
    draw_branch(pixels, trunk_base_x, 50, 48, 30, 6, 4, seed=406)
    
    # Umbrella Domes
    draw_umbrella_dome(pixels, 22, 36, 18, 13, seed=501)
    draw_umbrella_dome(pixels, 74, 36, 18, 13, seed=502)
    draw_umbrella_dome(pixels, 36, 24, 22, 15, seed=503)
    draw_umbrella_dome(pixels, 60, 24, 22, 15, seed=504)
    draw_umbrella_dome(pixels, 48, 15, 24, 16, seed=505)
    
    img = Image.new("RGBA", (w, h))
    for y in range(h):
        for x in range(w):
            img.putpixel((x, y), pixels[y][x])
    return img

if __name__ == "__main__":
    t_large = generate_large_canopy_tree()
    t_large.save("assets/foliage/tree_canopy_large.png")
    print("Saved assets/foliage/tree_canopy_large.png (Size: %s)" % str(t_large.size))
    
    t_med = generate_medium_canopy_tree()
    t_med.save("assets/foliage/tree_canopy_medium.png")
    print("Saved assets/foliage/tree_canopy_medium.png (Size: %s)" % str(t_med.size))
    
    t_clust = generate_cluster_canopy_tree()
    t_clust.save("assets/foliage/tree_canopy_cluster.png")
    print("Saved assets/foliage/tree_canopy_cluster.png (Size: %s)" % str(t_clust.size))
