import os
import numpy as np
from PIL import Image

BRAIN_DIR = r"C:\Users\Lin\.gemini\antigravity\brain\d9eafb9d-1e01-4d36-bcb2-e9064cb02374"
UI_DIR = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test\assets\ui"

ICONS_JPG = os.path.join(BRAIN_DIR, "filipino_map_marker_icons_1793677868255.jpg")
PLANKS_JPG = os.path.join(BRAIN_DIR, "filipino_ui_planks_1793677976970.jpg")
HUD_FILL_PNG = os.path.join(UI_DIR, "hud_hp_bar_fill.png")


def remove_green_bg(img: Image.Image) -> Image.Image:
    rgba = img.convert("RGBA")
    arr = np.array(rgba, dtype=np.float32)
    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    greenness = g - np.maximum(r, b)
    magentaness = np.minimum(r, b) - g

    mask_green_bg = (greenness > 25) & (g > 70)
    mask_green_edge = (greenness > 8) & (~mask_green_bg)

    mask_mag_bg = (magentaness > 25) & (r > 90) & (b > 90)
    mask_mag_edge = (magentaness > 8) & (~mask_mag_bg)

    arr[mask_green_bg | mask_mag_bg, 3] = 0.0

    if np.any(mask_green_edge):
        arr[mask_green_edge, 1] = np.minimum(arr[mask_green_edge, 1], (arr[mask_green_edge, 0] + arr[mask_green_edge, 2]) * 0.5)
        arr[mask_green_edge, 3] = np.clip(255.0 - (greenness[mask_green_edge] - 8.0) * 9.0, 0.0, 255.0)

    if np.any(mask_mag_edge):
        arr[mask_mag_edge, 0] = np.minimum(arr[mask_mag_edge, 0], arr[mask_mag_edge, 1] * 1.1)
        arr[mask_mag_edge, 2] = np.minimum(arr[mask_mag_edge, 2], arr[mask_mag_edge, 1] * 1.1)
        arr[mask_mag_edge, 3] = np.clip(255.0 - (magentaness[mask_mag_edge] - 8.0) * 9.0, 0.0, 255.0)

    return Image.fromarray(arr.astype(np.uint8), "RGBA")


def crop_to_alpha(img: Image.Image) -> Image.Image:
    bbox = img.getbbox()
    return img.crop(bbox) if bbox else img


def extract_kamagong_wood_patch(w: int, h: int, brightness: float = 1.0) -> np.ndarray:
    """
    Extracts authentic pixel-art dark Kamagong wood grain from the center of plank0
    and combines it with crisp horizontal timber grain striations and heartwood streaks.
    """
    raw = Image.open(PLANKS_JPG)
    clean = remove_green_bg(raw)
    # Center pure wood region of plank0 (avoiding the left/right bone arrowheads)
    wood_crop = clean.crop((340, 125, 1060, 285)).resize((w, h), Image.Resampling.NEAREST)
    arr = np.array(wood_crop, dtype=np.float32)

    luma = 0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2]
    norm = np.clip((luma - 14.0) / 52.0, 0.0, 1.0)

    # Crisp horizontal wood-grain rings + long wavy timber fibers
    rng = np.random.default_rng(20261103 + w * 31 + h)
    xs = np.linspace(0.0, 4.0 * np.pi, w)[None, :]
    ys = np.arange(h)[:, None]
    wave = 0.5 + 0.5 * np.sin(ys * 1.45 + np.sin(xs * 0.7) * 1.6)
    row_banding = rng.uniform(-0.16, 0.16, size=(h, 1))
    streak = np.convolve(rng.uniform(-0.22, 0.22, size=w * h), np.ones(9) / 9.0, mode="same").reshape(h, w)

    grain = np.clip(norm * 0.55 + wave * 0.30 + row_banding + streak, 0.0, 1.0)

    out = np.zeros((h, w, 4), dtype=np.float32)
    # Rich oiled Kamagong hardwood: deep ebony-charcoal (#161113) to warm dark walnut heartwood (#42342e)
    out[:, :, 0] = (20.0 + grain * 44.0) * brightness
    out[:, :, 1] = (15.0 + grain * 35.0) * brightness
    out[:, :, 2] = (16.0 + grain * 30.0) * brightness

    # Carve 2 subtle dark horizontal wood-pore lines across the plank for unmistakable timber feel
    for py in [h // 3, (2 * h) // 3]:
        if 4 <= py < h - 4:
            out[py, ::2, :3] *= 0.76
            if py + 1 < h - 4:
                out[py + 1, ::2, :3] = np.clip(out[py + 1, ::2, :3] * 1.14, 0, 255)

    out[:, :, 3] = 255.0
    return out


def draw_sleek_engraved_slat(
    w: int,
    h: int,
    wood_brightness: float = 1.0,
    engrave_col: tuple = (138, 128, 104, 215),
    border_col: tuple = (62, 52, 46, 255),
    end_band_w: int = 12,
) -> Image.Image:
    """
    Builds a sleek, straight-edged (1px micro-chamfered) Charred Kamagong wood slat
    with fine 1px tribal geometric engravings recessed inside the left & right bookend bands.
    No protruding arrowheads or bulky endcaps—leaving the entire central wood chamber
    (x = end_band_w + 2 .. w - end_band_w - 2) 100% unobstructed for text.
    """
    arr = extract_kamagong_wood_patch(w, h, brightness=wood_brightness)

    def set_px(x: int, y: int, c: tuple):
        if 0 <= x < w and 0 <= y < h:
            arr[y, x, 0] = c[0]
            arr[y, x, 1] = c[1]
            arr[y, x, 2] = c[2]
            arr[y, x, 3] = c[3]

    # 1. Outer 1px dark silhouette & 1px micro-chamfered corners
    outer_dark = (12, 10, 11, 255)
    for x in range(w):
        set_px(x, 0, outer_dark)
        set_px(x, h - 1, outer_dark)
    for y in range(h):
        set_px(0, y, outer_dark)
        set_px(w - 1, y, outer_dark)

    # Micro-chamfer the 4 extreme corner pixels for a sleek silhouette
    for cx, cy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        set_px(cx, cy, (0, 0, 0, 0))
    for cx, cy in [(1, 1), (w - 2, 1), (1, h - 2), (w - 2, h - 2)]:
        set_px(cx, cy, outer_dark)

    # 2. Inner 1px beveled hardwood rim (x=1..w-2, y=1..h-2)
    rim_top = (min(255, int(border_col[0] * 1.18)), min(255, int(border_col[1] * 1.18)), min(255, int(border_col[2] * 1.18)), 255)
    rim_bot = (int(border_col[0] * 0.72), int(border_col[1] * 0.72), int(border_col[2] * 0.72), 255)
    for x in range(2, w - 2):
        set_px(x, 1, rim_top)
        set_px(x, h - 2, rim_bot)
    for y in range(2, h - 2):
        set_px(1, y, border_col)
        set_px(w - 2, y, border_col)

    # 3. Recessed 1px dark groove inside rim (x=2..w-3, y=2..h-3)
    groove = (17, 14, 15, 255)
    for x in range(2, w - 2):
        set_px(x, 2, groove)
        set_px(x, h - 3, groove)
    for y in range(2, h - 2):
        set_px(2, y, groove)
        set_px(w - 3, y, groove)

    # 4. Fine 1px etched tribal engraving inside the left & right bookend bands (3 .. end_band_w)
    #    Matches the delicate geometric linework on Haliya Totem's chest
    faint_engrave = (
        int(engrave_col[0] * 0.62 + arr[h // 2, w // 2, 0] * 0.38),
        int(engrave_col[1] * 0.62 + arr[h // 2, w // 2, 1] * 0.38),
        int(engrave_col[2] * 0.62 + arr[h // 2, w // 2, 2] * 0.38),
        255,
    )
    bright_engrave = (engrave_col[0], engrave_col[1], engrave_col[2], 255)

    # Subtle top & bottom engraved hairline rails only near the ends (leaving center sleek)
    rail_len = min(28, w // 5)
    for x in range(3, 3 + rail_len):
        set_px(x, 3, faint_engrave)
        set_px(x, h - 4, faint_engrave)
        set_px(w - 1 - x, 3, faint_engrave)
        set_px(w - 1 - x, h - 4, faint_engrave)

    # Vertical engraved divider line separating the slim bookend motif from the text chamber
    lx = end_band_w
    rx = w - 1 - end_band_w
    for y in range(3, h - 3):
        set_px(lx, y, faint_engrave)
        set_px(lx + 1, y, groove)
        set_px(rx, y, faint_engrave)
        set_px(rx - 1, y, groove)

    # Delicate geometric Bicolano diamond-and-notch motif centered vertically inside [3 .. lx-1]
    cy = h // 2
    mcx_l = (3 + lx - 1) // 2
    mcx_r = (rx + 1 + w - 4) // 2

    # Small 5x5 hollow etched diamond in each bookend
    diamond_offsets = [
        (0, -2),
        (-1, -1), (1, -1),
        (-2, 0), (2, 0),
        (-1, 1), (1, 1),
        (0, 2),
    ]
    for dx, dy in diamond_offsets:
        set_px(mcx_l + dx, cy + dy, bright_engrave)
        set_px(mcx_r + dx, cy + dy, bright_engrave)

    # Tiny center pinpoint & top/bottom step ticks
    set_px(mcx_l, cy - 5, faint_engrave)
    set_px(mcx_l, cy + 5, faint_engrave)
    set_px(mcx_r, cy - 5, faint_engrave)
    set_px(mcx_r, cy + 5, faint_engrave)

    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")


def draw_sleek_engraved_bar_frame(w: int, h: int, pad_x: int = 10, pad_y: int = 5) -> Image.Image:
    """
    Builds a sleek engraved Kamagong wood bar frame (for Loading Bar and Stage Progress Tracker)
    with a recessed inner channel of size (w - 2*pad_x, h - 2*pad_y) at (pad_x, pad_y).
    """
    arr = extract_kamagong_wood_patch(w, h, brightness=0.96)

    def set_px(x: int, y: int, c: tuple):
        if 0 <= x < w and 0 <= y < h:
            arr[y, x, 0] = c[0]
            arr[y, x, 1] = c[1]
            arr[y, x, 2] = c[2]
            arr[y, x, 3] = c[3]

    outer_dark = (12, 10, 11, 255)
    rim_col = (68, 58, 50, 255)
    engrave_col = (148, 138, 112, 255)
    groove = (14, 11, 12, 255)

    # Outer border + 1px micro-chamfer
    for x in range(w):
        set_px(x, 0, outer_dark)
        set_px(x, h - 1, outer_dark)
    for y in range(h):
        set_px(0, y, outer_dark)
        set_px(w - 1, y, outer_dark)
    for cx, cy in [(0, 0), (w - 1, 0), (0, h - 1), (w - 1, h - 1)]:
        set_px(cx, cy, (0, 0, 0, 0))
    for cx, cy in [(1, 1), (w - 2, 1), (1, h - 2), (w - 2, h - 2)]:
        set_px(cx, cy, outer_dark)

    # Beveled hardwood rim
    for x in range(2, w - 2):
        set_px(x, 1, (82, 70, 58, 255))
        set_px(x, h - 2, (48, 40, 35, 255))
    for y in range(2, h - 2):
        set_px(1, y, rim_col)
        set_px(w - 2, y, rim_col)

    # Etched bone corner ticks & end-cap diamond accents inside [2 .. pad_x-2]
    cy = h // 2
    lx = pad_x // 2
    rx = w - 1 - (pad_x // 2)
    for dx, dy in [(0, -1), (-1, 0), (1, 0), (0, 1)]:
        set_px(lx + dx, cy + dy, engrave_col)
        set_px(rx + dx, cy + dy, engrave_col)

    # Recessed inner channel [pad_x .. w - pad_x - 1, pad_y .. h - pad_y - 1]
    x0, x1 = pad_x, w - pad_x
    y0, y1 = pad_y, h - pad_y

    # 1px engraved bone bezel around the recessed channel
    bezel_col = (108, 98, 80, 255)
    for x in range(x0 - 1, x1 + 1):
        set_px(x, y0 - 1, bezel_col)
        set_px(x, y1, bezel_col)
    for y in range(y0 - 1, y1 + 1):
        set_px(x0 - 1, y, bezel_col)
        set_px(x1, y, bezel_col)

    # Dark recessed interior timber trough
    for y in range(y0, y1):
        for x in range(x0, x1):
            # Subtle horizontal dark wood trough lines
            trough_v = 13 if (y % 2 == 0) else 17
            set_px(x, y, (trough_v + 2, trough_v, trough_v + 1, 255))

    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")


def create_carved_wood_and_banig_fill(width: int, height: int, tone: str = "bone_timber") -> Image.Image:
    hud_fill = Image.open(HUD_FILL_PNG).convert("RGBA")
    banig_resized = hud_fill.resize((width, height), Image.Resampling.NEAREST)
    arr = np.array(banig_resized, dtype=np.float32)

    r, g, b, a = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2], arr[:, :, 3]
    luma = 0.299 * r + 0.587 * g + 0.114 * b
    norm = np.clip((luma - 20.0) / 140.0, 0.0, 1.0)

    out = np.zeros_like(arr)
    if tone == "bone_timber":
        out[:, :, 0] = 48.0 + norm * 104.0
        out[:, :, 1] = 43.0 + norm * 95.0
        out[:, :, 2] = 35.0 + norm * 74.0
    else:
        out[:, :, 0] = 52.0 + norm * 112.0
        out[:, :, 1] = 48.0 + norm * 104.0
        out[:, :, 2] = 39.0 + norm * 82.0

    out[0, :, :3] = np.clip(out[0, :, :3] * 1.18, 0, 255)
    out[-1, :, :3] = out[-1, :, :3] * 0.65

    seg_step = max(24, width // 8)
    for x in range(seg_step, width - 8, seg_step):
        out[:, x, :3] *= 0.62
        if x + 1 < width:
            out[:, x + 1, :3] = np.clip(out[:, x + 1, :3] * 1.15, 0, 255)

    out[:, :, 3] = 255.0
    return Image.fromarray(np.clip(out, 0, 255).astype(np.uint8), "RGBA")


def process_map_pins():
    raw = Image.open(ICONS_JPG)
    clean = remove_green_bg(raw)

    icon0 = crop_to_alpha(clean.crop((102, 169, 444, 591)))
    icon1 = crop_to_alpha(clean.crop((543, 189, 835, 558)))
    icon2 = crop_to_alpha(clean.crop((955, 224, 1283, 553)))

    pin_haliya = icon0.resize((44, 56), Image.Resampling.NEAREST)
    pin_shrine = icon1.resize((44, 52), Image.Resampling.NEAREST)
    pin_boss = icon2.resize((48, 48), Image.Resampling.NEAREST)

    pin_haliya.save(os.path.join(UI_DIR, "progress_pin_haliya.png"))
    pin_shrine.save(os.path.join(UI_DIR, "progress_pin_shrine.png"))
    pin_boss.save(os.path.join(UI_DIR, "progress_pin_boss.png"))
    print("Saved crisp pixel-art carved wood & bone progress pins.")


def draw_kamagong_menu_pedestal(w: int = 268, h: int = 320) -> Image.Image:
    """
    Builds a bespoke 268x320 Carved Kamagong & Etched Bone Menu Pedestal with 3 integrated zones:
      1. Top Header Crest (y = 0..86): Houses 'HALIYA', an etched crescent-moon & geometric divider at y=54,
         and 'Mask of Sorrows' at y=60..80.
      2. Middle Recessed Sanctuary (y = 87..287): Semi-recessed dark timber chamber with vertical etched
         side rails that frames the 7 sleek engraved Kamagong wood buttons.
      3. Bottom Docked Status Base (y = 288..319): Integrated engraved Kamagong base plaque for the active
         save slot summary ('Slot 1: Whispering Canopy • HP 5/5 • 02:05').
    """
    arr = extract_kamagong_wood_patch(w, h, brightness=0.92)

    def set_px(x: int, y: int, c: tuple):
        if 0 <= x < w and 0 <= y < h:
            arr[y, x, 0] = c[0]
            arr[y, x, 1] = c[1]
            arr[y, x, 2] = c[2]
            arr[y, x, 3] = c[3]

    outer_dark = (10, 8, 9, 255)
    rim_light = (92, 80, 66, 255)
    rim_mid = (68, 58, 48, 255)
    rim_dark = (44, 36, 31, 255)
    groove = (14, 11, 12, 255)
    engrave_bright = (168, 156, 128, 255)
    engrave_faint = (106, 96, 78, 255)

    # Recessed middle sanctuary slightly translucent & darker so the buttons pop cleanly
    for y in range(88, 288):
        for x in range(4, w - 4):
            arr[y, x, 0] *= 0.62
            arr[y, x, 1] *= 0.62
            arr[y, x, 2] *= 0.64
            arr[y, x, 3] = 232.0

    # Top header crest & bottom status base rich dark hardwood
    for y in list(range(3, 87)) + list(range(289, h - 3)):
        for x in range(3, w - 3):
            arr[y, x, 0] *= 0.88
            arr[y, x, 1] *= 0.88
            arr[y, x, 2] *= 0.90
            arr[y, x, 3] = 248.0

    # 1. Outer 1px silhouette + 2px stepped corner chamfers
    for x in range(w):
        set_px(x, 0, outer_dark)
        set_px(x, h - 1, outer_dark)
    for y in range(h):
        set_px(0, y, outer_dark)
        set_px(w - 1, y, outer_dark)

    for cx, cy in [
        (0, 0), (1, 0), (0, 1),
        (w - 1, 0), (w - 2, 0), (w - 1, 1),
        (0, h - 1), (1, h - 1), (0, h - 2),
        (w - 1, h - 1), (w - 2, h - 1), (w - 1, h - 2),
    ]:
        set_px(cx, cy, (0, 0, 0, 0))

    # 2. Beveled outer hardwood & bone rim (x=1..w-2, y=1..h-2)
    for x in range(2, w - 2):
        set_px(x, 1, rim_light)
        set_px(x, 2, groove)
        set_px(x, h - 2, rim_dark)
        set_px(x, h - 3, groove)
    for y in range(2, h - 2):
        set_px(1, y, rim_mid)
        set_px(2, y, groove)
        set_px(w - 2, y, rim_mid)
        set_px(w - 3, y, groove)

    # 3. Horizontal structural crossbeams at y=86..88 (below Header Crest) and y=287..289 (above Status Base)
    for by in [86, 287]:
        for x in range(2, w - 2):
            set_px(x, by, groove)
            set_px(x, by + 1, rim_light)
            set_px(x, by + 2, groove)

    # 4. Etched tribal geometric border & Crescent Moon divider inside Top Header Crest (y=0..86)
    for x in range(6, w - 6):
        set_px(x, 5, engrave_faint)
        set_px(x, 82, engrave_faint)
    for y in range(5, 83):
        set_px(6, y, engrave_faint)
        set_px(w - 7, y, engrave_faint)

    # Corner diamond inlays inside Header Crest
    for cx, cy in [(12, 11), (w - 13, 11), (12, 76), (w - 13, 76)]:
        for dx, dy in [(0, -2), (-1, -1), (1, -1), (-2, 0), (2, 0), (-1, 1), (1, 1), (0, 2)]:
            set_px(cx + dx, cy + dy, engrave_bright)
        set_px(cx, cy, engrave_faint)

    # Carved Crescent Moon & Tribal Divider at y = 55 (between 'HALIYA' and 'Mask of Sorrows')
    mid_x = w // 2
    div_y = 55
    # Horizontal engraved rays flanking the center crescent emblem
    for x in range(28, mid_x - 14):
        set_px(x, div_y, engrave_bright if (x % 2 == 0) else engrave_faint)
    for x in range(mid_x + 15, w - 28):
        set_px(x, div_y, engrave_bright if (x % 2 == 0) else engrave_faint)

    # Small side diamonds on the divider line
    for sx in [mid_x - 18, mid_x + 18, 26, w - 27]:
        for dx, dy in [(0, -1), (-1, 0), (1, 0), (0, 1)]:
            set_px(sx + dx, div_y + dy, engrave_bright)

    # Center upward-horned Crescent Moon motif (matching Haliya Totem's crown) at (mid_x, div_y)
    crescent_px = [
        (-5, -2), (-4, -1), (-4, 0), (-3, 0), (-3, 1), (-2, 1), (-1, 2), (0, 2), (1, 2), (2, 1), (3, 1), (3, 0), (4, 0), (4, -1), (5, -2),
        (-2, 2), (2, 2), (0, 3)
    ]
    for dx, dy in crescent_px:
        set_px(mid_x + dx, div_y + dy - 1, engrave_bright)

    # 5. Middle Recessed Sanctuary side rails (y=91..284)
    for y in range(92, 284):
        set_px(9, y, engrave_faint if (y % 3 != 0) else groove)
        set_px(w - 10, y, engrave_faint if (y % 3 != 0) else groove)

    # 6. Bottom Docked Status Base (y=289..319, center at y=304)
    status_cy = 304
    # Left & right bookend dividers at x=16 and x=w-17
    for y in range(291, h - 4):
        set_px(16, y, engrave_faint)
        set_px(17, y, groove)
        set_px(w - 17, y, engrave_faint)
        set_px(w - 18, y, groove)

    for mcx in [9, w - 10]:
        for dx, dy in [(0, -2), (-1, -1), (1, -1), (-2, 0), (2, 0), (-1, 1), (1, 1), (0, 2)]:
            set_px(mcx + dx, status_cy + dy, engrave_bright)

    return Image.fromarray(np.clip(arr, 0, 255).astype(np.uint8), "RGBA")


def process_planks_and_bars():
    # 0. Bespoke Carved Kamagong Menu Pedestal (268x320)
    pedestal = draw_kamagong_menu_pedestal(268, 320)
    pedestal.save(os.path.join(UI_DIR, "menu_column_plaque.png"))

    # 1. Sleek Engraved Kamagong Wood Menu Buttons (228x24, fits inside 268px pedestal with 20px margins)
    btn_w, btn_h = 228, 24
    btn_normal = draw_sleek_engraved_slat(
        btn_w, btn_h,
        wood_brightness=0.98,
        engrave_col=(140, 130, 106, 255),
        border_col=(64, 54, 46, 255),
        end_band_w=12,
    )
    btn_normal.save(os.path.join(UI_DIR, "menu_btn_normal.png"))

    btn_hover = draw_sleek_engraved_slat(
        btn_w, btn_h,
        wood_brightness=1.26,
        engrave_col=(214, 202, 166, 255),
        border_col=(128, 114, 92, 255),
        end_band_w=12,
    )
    btn_hover.save(os.path.join(UI_DIR, "menu_btn_hover.png"))

    btn_pressed = draw_sleek_engraved_slat(
        btn_w, btn_h,
        wood_brightness=0.80,
        engrave_col=(172, 160, 130, 255),
        border_col=(48, 40, 35, 255),
        end_band_w=12,
    )
    btn_pressed.save(os.path.join(UI_DIR, "menu_btn_pressed.png"))

    # 2. Sleek Engraved Kamagong Status Bar (260x24)
    inscr_plaque = draw_sleek_engraved_slat(
        260, 24,
        wood_brightness=0.94,
        engrave_col=(146, 136, 110, 255),
        border_col=(66, 56, 48, 255),
        end_band_w=11,
    )
    inscr_plaque.save(os.path.join(UI_DIR, "menu_preview_panel.png"))

    # 3. In-Game Stage Progress Tracker (240x20, inner channel = 220x10 at x=10, y=5)
    prog_frame = draw_sleek_engraved_bar_frame(240, 20, pad_x=10, pad_y=5)
    prog_frame.save(os.path.join(UI_DIR, "progress_track_frame.png"))

    prog_fill = create_carved_wood_and_banig_fill(220, 10, tone="bone_timber")
    prog_fill.save(os.path.join(UI_DIR, "progress_track_fill.png"))

    # 4. Main Menu Centered Loading Bar (356x24, inner channel = 336x14 at x=10, y=5)
    load_frame = draw_sleek_engraved_bar_frame(356, 24, pad_x=10, pad_y=5)
    load_frame.save(os.path.join(UI_DIR, "loading_bar_frame.png"))

    load_fill = create_carved_wood_and_banig_fill(336, 14, tone="moonlit_wood")
    load_fill.save(os.path.join(UI_DIR, "loading_bar_fill.png"))

    print("Saved bespoke Kamagong Menu Pedestal, sleek engraved slats, and bar frames!")


if __name__ == "__main__":
    process_map_pins()
    process_planks_and_bars()
