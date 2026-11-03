import os
from PIL import Image
from collections import deque

def remove_background(input_path, output_path, tolerance=35):
    img = Image.open(input_path).convert("RGBA")
    w, h = img.size
    pixels = img.load()
    
    # Visited matrix
    visited = [[False for _ in range(h)] for _ in range(w)]
    queue = deque()
    
    # Check if a pixel is considered "white background"
    def is_bg(x, y):
        r, g, b, a = pixels[x, y]
        # Solid white or near-white background
        return r >= (255 - tolerance) and g >= (255 - tolerance) and b >= (255 - tolerance)

    # Push all 4 borders
    for x in range(w):
        if is_bg(x, 0):
            queue.append((x, 0))
            visited[x][0] = True
        if is_bg(x, h - 1):
            queue.append((x, h - 1))
            visited[x][h - 1] = True
            
    for y in range(h):
        if is_bg(0, y) and not visited[0][y]:
            queue.append((0, y))
            visited[0][y] = True
        if is_bg(w - 1, y) and not visited[w - 1][y]:
            queue.append((w - 1, y))
            visited[w - 1][y] = True
            
    # BFS flood fill from edges
    while queue:
        cx, cy = queue.popleft()
        pixels[cx, cy] = (0, 0, 0, 0)
        
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h:
                if not visited[nx][ny]:
                    visited[nx][ny] = True
                    if is_bg(nx, ny):
                        queue.append((nx, ny))

    # Also crop any empty edges to tight bounding box with a 4px padding
    bbox = img.getbbox()
    if bbox:
        # Add 4px margin if possible
        x1 = max(0, bbox[0] - 4)
        y1 = max(0, bbox[1] - 4)
        x2 = min(w, bbox[2] + 4)
        y2 = min(h, bbox[3] + 4)
        img = img.crop((x1, y1, x2, y2))
        
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    img.save(output_path, "PNG")
    print(f"Processed: {output_path} (size: {img.size})")

if __name__ == "__main__":
    src1 = r"C:\Users\Lin\.gemini\antigravity\brain\b8a60ec0-3a71-45af-9c09-c7de3a708077\bakunawa_head_1790729347614.jpg"
    src2 = r"C:\Users\Lin\.gemini\antigravity\brain\b8a60ec0-3a71-45af-9c09-c7de3a708077\bakunawa_strike_1790729363883.jpg"
    
    out_dir = r"assets\bakunawa"
    remove_background(src1, os.path.join(out_dir, "bakunawa_idle.png"), tolerance=40)
    remove_background(src2, os.path.join(out_dir, "bakunawa_breath.png"), tolerance=40)
