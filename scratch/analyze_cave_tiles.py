from PIL import Image

def analyze_sheet(name, path, cols, rows):
    im = Image.open(path)
    print(f"=== {name} ({im.size}) cols={cols}, rows={rows} ===")
    tile_w, tile_h = 32, 32
    for r in range(rows):
        row_has_content = False
        for c in range(cols):
            box = (c * tile_w, r * tile_h, (c + 1) * tile_w, (r + 1) * tile_h)
            tile = im.crop(box)
            # check if not completely transparent
            extrema = tile.getextrema()
            if len(extrema) == 4 and extrema[3][1] > 0: # RGBA
                row_has_content = True
        if row_has_content:
            print(f"  Row {r}: active")

analyze_sheet("Floor Tiles2", "assets/platform_assets/Floor Tiles2.png", 9, 18)
analyze_sheet("Other Tiles2", "assets/platform_assets/Other Tiles2.png", 9, 7)
