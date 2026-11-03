import cv2
import numpy as np
from PIL import Image

def find_components(img_path, min_area=1500, max_area=250000):
    im = Image.open(img_path).convert("RGB")
    arr = np.array(im)
    
    # Check if background is dark or light
    corners = [arr[0,0], arr[0,-1], arr[-1,0], arr[-1,-1]]
    mean_corner = np.mean(corners)
    is_dark_bg = mean_corner < 128
    
    gray = cv2.cvtColor(arr, cv2.COLOR_RGB2GRAY)
    if is_dark_bg:
        _, mask = cv2.threshold(gray, 30, 255, cv2.THRESH_BINARY)
    else:
        _, mask = cv2.threshold(gray, 225, 255, cv2.THRESH_BINARY_INV)
        
    num_labels, labels, stats, centroids = cv2.connectedComponentsWithStats(mask)
    
    components = []
    for i in range(1, num_labels):
        area = stats[i, cv2.CC_STAT_AREA]
        if min_area <= area <= max_area:
            x = stats[i, cv2.CC_STAT_LEFT]
            y = stats[i, cv2.CC_STAT_TOP]
            w = stats[i, cv2.CC_STAT_WIDTH]
            h = stats[i, cv2.CC_STAT_HEIGHT]
            components.append((x, y, w, h, area))
            
    print(f"Found {len(components)} components in {img_path}:")
    for idx, (x, y, w, h, area) in enumerate(sorted(components, key=lambda c: (c[1]//100, c[0]))):
        print(f"  [{idx+1}] x={x}, y={y}, w={w}, h={h}, area={area}")

print("=== IMAGE 2 (Platforms & Relics) ===")
find_components(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_cave_platforms_spritesheet_1792544043909.jpg")

print("\n=== IMAGE 1 (Tiles & Props) ===")
find_components(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_subterranean_cave_tileset_1792544013682.jpg")

print("\n=== IMAGE 3 (Modular Tilemap) ===")
find_components(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\cave_tileset_spritesheet_1792544092516.jpg")
