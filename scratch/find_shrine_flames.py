from PIL import Image

shrine = Image.open("assets/art/totem_shrine.png")
w, h = shrine.size
print(f"totem_shrine size: {w}x{h}")

# Search for gold pixels: PROJECT_PALETTE gold colors:
# (140, 111, 46), (201, 162, 74), (222, 197, 124)
gold_colors = [(140, 111, 46), (201, 162, 74), (222, 197, 124)]

gold_pixels = []
for y in range(h):
    for x in range(w):
        p = shrine.getpixel((x, y))
        if p[3] > 0 and p[:3] in gold_colors:
            gold_pixels.append((x, y, p[:3]))

print(f"Total gold pixels: {len(gold_pixels)}")
# Group gold pixels by x clusters to find the candle flame centers
from collections import defaultdict
clusters = defaultdict(list)
for x, y, c in gold_pixels:
    # cluster key by x // 10
    clusters[x // 12].append((x, y))

for k, pts in sorted(clusters.items()):
    avg_x = sum(p[0] for p in pts) / len(pts)
    avg_y = sum(p[1] for p in pts) / len(pts)
    print(f"Cluster near x={avg_x:.1f}, y={avg_y:.1f} (count={len(pts)})")
