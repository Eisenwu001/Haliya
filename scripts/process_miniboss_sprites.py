import os
import numpy as np
from PIL import Image
from collections import deque
from scipy.ndimage import label

def remove_bg_flood(img, tolerance=40):
    """Flood-fills from borders to make the white/off-white background transparent."""
    img = img.convert("RGBA")
    w, h = img.size
    pixels = img.load()
    
    visited = [[False for _ in range(h)] for _ in range(w)]
    queue = deque()
    
    def is_bg(x, y):
        r, g, b, a = pixels[x, y]
        return r >= (255 - tolerance) and g >= (255 - tolerance) and b >= (255 - tolerance)
    
    for x in range(w):
        if is_bg(x, 0) and not visited[x][0]:
            queue.append((x, 0))
            visited[x][0] = True
        if is_bg(x, h - 1) and not visited[x][h - 1]:
            queue.append((x, h - 1))
            visited[x][h - 1] = True
            
    for y in range(h):
        if is_bg(0, y) and not visited[0][y]:
            queue.append((0, y))
            visited[0][y] = True
        if is_bg(w - 1, y) and not visited[w - 1][y]:
            queue.append((w - 1, y))
            visited[w - 1][y] = True
            
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
                        
    return img

def clean_isolated_pixels(img, min_component_size=35):
    """Clean near-white pixels and remove small disconnected noise components."""
    arr = np.array(img.convert("RGBA")).copy()
    near_white = (arr[:, :, 0] > 238) & (arr[:, :, 1] > 238) & (arr[:, :, 2] > 238) & (arr[:, :, 3] > 0)
    arr[near_white] = [0, 0, 0, 0]
    
    alpha = arr[:, :, 3] > 0
    labeled, num_features = label(alpha)
    if num_features > 0:
        sizes = np.bincount(labeled.ravel())
        mask = sizes < min_component_size
        mask[0] = False
        remove = mask[labeled]
        arr[remove] = [0, 0, 0, 0]
        
    return Image.fromarray(arr).copy()

def place_anchored(crop_img, anchor_x, ground_y, scale=0.63, target_size=(256, 256), target_baseline_y=240, target_center_x=128):
    """
    Places a cropped image onto a (256, 256) canvas with:
    - Uniform scale across all frames
    - Anchor_x (torso/hip center in crop coordinates) mapped exactly to target_center_x (128)
    - Ground_y (feet contact in crop coordinates) mapped exactly to target_baseline_y (240)
    This completely eliminates walking jitter, bobbing, and hopping!
    """
    cw, ch = crop_img.size
    nw = max(1, int(round(cw * scale)))
    nh = max(1, int(round(ch * scale)))
    resized = crop_img.resize((nw, nh), Image.Resampling.LANCZOS)
    
    canvas = Image.new("RGBA", target_size, (0, 0, 0, 0))
    paste_x = int(round(target_center_x - (anchor_x * scale)))
    paste_y = int(round(target_baseline_y - (ground_y * scale)))
    
    canvas.paste(resized, (paste_x, paste_y), resized)
    return canvas

def find_torso_center(crop_img, ground_y=None):
    """Calculates the horizontal center of mass of the character's torso."""
    arr = np.array(crop_img)
    alpha = arr[:, :, 3] > 0
    rows = np.where(np.sum(alpha, axis=1) >= 4)[0]
    if len(rows) == 0:
        return crop_img.width // 2, crop_img.height
    
    top_y = rows[0]
    bot_y = ground_y if ground_y is not None else rows[-1]
    h = max(10, bot_y - top_y)
    
    # Torso band: 25% to 55% from top
    t_top = top_y + int(h * 0.25)
    t_bot = top_y + int(h * 0.55)
    t_mask = alpha[t_top:t_bot, :]
    cols = np.where(np.sum(t_mask, axis=0) >= 3)[0]
    if len(cols) > 0:
        return int((cols[0] + cols[-1]) / 2), bot_y
    else:
        cols_all = np.where(np.sum(alpha, axis=0) >= 3)[0]
        return int((cols_all[0] + cols_all[-1]) / 2), bot_y

def main():
    brain = r'C:\Users\Lin\.gemini\antigravity\brain\f58783f4-77f3-4438-92d1-5409479b469e'
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    
    out_forest = os.path.join(base_dir, "assets", "miniboss", "forest_brute")
    out_mayon = os.path.join(base_dir, "assets", "miniboss", "mayon_vanguard")
    os.makedirs(out_forest, exist_ok=True)
    os.makedirs(out_mayon, exist_ok=True)

    # =========================================================================
    # 1. FOREST BRUTE
    # =========================================================================
    fb_walk_img = Image.open(os.path.join(brain, 'forest_brute_walk_1790926410384.jpg'))
    fb_atk_img = Image.open(os.path.join(brain, 'forest_brute_attacks_1790926439947.jpg'))
    fb_orig_img = Image.open(os.path.join(brain, 'forest_brute_boss_1790924202974.jpg'))
    fb_death_img = Image.open(os.path.join(brain, 'forest_brute_death_1790929101456.jpg'))

    # Uniform scale factor: standing height is ~310 px -> scale = 195 / 310 = 0.629
    FB_SCALE = 0.629

    # Idle (Original Sheet Q1)
    crop = clean_isolated_pixels(remove_bg_flood(fb_orig_img.crop((40, 40, 480, 458)), tolerance=35))
    # Remove grass
    px = crop.load()
    cw, ch = crop.size
    for x in range(cw):
        for y in range(ch - 35, ch):
            r, g, b, a = px[x, y]
            if g > r and g > 60:
                px[x, y] = (0, 0, 0, 0)
    cx, gy = find_torso_center(crop)
    fb_idle = place_anchored(crop, cx, gy, FB_SCALE)

    # Walk cycle (7 frames with anchored ground line: Row 1 = 375, Row 2 = 711)
    fb_walk_crops = [
        # (box, ground_y_in_box)
        ((80, 50, 340, 380), 375 - 50),
        ((420, 50, 650, 380), 375 - 50),
        ((730, 50, 960, 380), 375 - 50),
        ((1030, 50, 1290, 380), 375 - 50),
        ((120, 390, 370, 720), 711 - 390),
        ((550, 390, 820, 720), 711 - 390),
        ((990, 390, 1265, 720), 711 - 390),
    ]
    fb_walk_frames = []
    for (box, gy) in fb_walk_crops:
        c = clean_isolated_pixels(remove_bg_flood(fb_walk_img.crop(box), tolerance=40))
        cx, _ = find_torso_center(c, gy)
        fb_walk_frames.append(place_anchored(c, cx, gy, FB_SCALE))

    # Slam Attack (4 frames: windup 8, lunge 9, slam 10, shockwave 11)
    fb_slam_crops = [
        ((40, 20, 350, 380), 375 - 20),
        ((390, 20, 750, 380), 375 - 20),
        ((860, 120, 1310, 380), 375 - 120),
        ((80, 410, 480, 730), 711 - 410),
    ]
    fb_slam_frames = []
    for (box, gy) in fb_slam_crops:
        c = clean_isolated_pixels(remove_bg_flood(fb_atk_img.crop(box), tolerance=40))
        cx, _ = find_torso_center(c, gy)
        fb_slam_frames.append(place_anchored(c, cx, gy, FB_SCALE))

    # Claw Swipe (2 frames: windup 16, swipe strike 17)
    sw0 = clean_isolated_pixels(remove_bg_flood(fb_atk_img.crop((470, 380, 930, 725)), tolerance=40))
    # clean corner spike
    px0 = sw0.load()
    w0, h0 = sw0.size
    for x in range(w0 - 70, w0):
        for y in range(h0 - 70, h0):
            px0[x, y] = (0, 0, 0, 0)
    cx0, gy0 = find_torso_center(sw0, 711 - 380)
    fb_swipe_0 = place_anchored(sw0, cx0, gy0, FB_SCALE)

    sw1 = clean_isolated_pixels(remove_bg_flood(fb_atk_img.crop((940, 395, 1360, 725)), tolerance=40))
    cx1, gy1 = find_torso_center(sw1, 711 - 395)
    fb_swipe_1 = place_anchored(sw1, cx1, gy1, FB_SCALE)

    # Reactions: Frame 24 (Stagger), Frame 25 (Hurt)
    stagger_crop = clean_isolated_pixels(remove_bg_flood(fb_orig_img.crop((540, 530, 990, 990)), tolerance=35))
    cx_s, gy_s = find_torso_center(stagger_crop)
    fb_stagger = place_anchored(stagger_crop, cx_s, gy_s, FB_SCALE)

    # Death sequence: 4 dramatic frames (Frames 26, 27, 28, 29)
    # Strip ground line is Y = 450
    fb_death_boxes = [
        # Frame 1: Clutching wound roaring (x=46..338, y=60..455)
        ((45, 55, 340, 455), 450 - 55),
        # Frame 2: Club dropping & bouncing (x=410..720, y=100..455)
        ((390, 95, 730, 455), 450 - 95),
        # Frame 3: Falling onto knees (x=730..1030, y=180..455)
        ((725, 180, 1030, 455), 450 - 180),
        # Frame 4: Collapsed into petrified wood with soul wisps (x=1030..1355, y=100..455)
        ((1025, 95, 1355, 455), 450 - 95),
    ]
    fb_death_frames = []
    for (box, gy) in fb_death_boxes:
        c = clean_isolated_pixels(remove_bg_flood(fb_death_img.crop(box), tolerance=40))
        cx, _ = find_torso_center(c, gy)
        fb_death_frames.append(place_anchored(c, cx, gy, FB_SCALE))

    # Assemble Master Spritesheet: 2048 x 1024 (8 cols x 4 rows)
    fb_master = Image.new("RGBA", (2048, 1024), (0, 0, 0, 0))
    # Row 0: Locomotion (0: Idle, 1..7: Walk 0..6)
    fb_master.paste(fb_idle, (0 * 256, 0 * 256))
    for i in range(7):
        fb_master.paste(fb_walk_frames[i], ((i + 1) * 256, 0 * 256))
    # Row 1: Heavy Slam (8: windup, 9: lunge, 10: slam, 11: shockwave)
    for i in range(4):
        fb_master.paste(fb_slam_frames[i], (i * 256, 1 * 256))
    # Row 2: Claw Swipe (16: windup, 17: strike)
    fb_master.paste(fb_swipe_0, (0 * 256, 2 * 256))
    fb_master.paste(fb_swipe_1, (1 * 256, 2 * 256))
    # Row 3: Reactions & Complete Death Animation
    # 24: Parried Stagger, 25: Hurt, 26: Death 1, 27: Death 2, 28: Death 3, 29: Death 4
    fb_master.paste(fb_stagger, (0 * 256, 3 * 256))
    fb_master.paste(fb_stagger, (1 * 256, 3 * 256)) # Hurt
    for i in range(4):
        fb_master.paste(fb_death_frames[i], ((i + 2) * 256, 3 * 256))

    fb_master_path = os.path.join(out_forest, "forest_brute_spritesheet.png")
    fb_master.save(fb_master_path)
    print("Saved Updated Forest Brute Master Spritesheet:", fb_master_path)

    # =========================================================================
    # 2. MAYON VANGUARD
    # =========================================================================
    mv_march_img = Image.open(os.path.join(brain, 'mayon_vanguard_march_1790926472430.jpg'))
    mv_atk_img = Image.open(os.path.join(brain, 'mayon_vanguard_attacks_1790926501493.jpg'))
    mv_orig_img = Image.open(os.path.join(brain, 'mayon_vanguard_boss_1790924229520.jpg'))
    mv_death_img = Image.open(os.path.join(brain, 'mayon_vanguard_death_1790929135078.jpg'))

    MV_SCALE = 0.629

    # Idle (Original Sheet Q1)
    mv_idle_crop = clean_isolated_pixels(remove_bg_flood(mv_orig_img.crop((50, 75, 460, 445)), tolerance=35))
    cx_mi, gy_mi = find_torso_center(mv_idle_crop)
    mv_idle = place_anchored(mv_idle_crop, cx_mi, gy_mi, MV_SCALE)

    # March cycle (7 frames with anchored ground lines: Row 1 = 375, Row 2 = 736)
    mv_march_crops = [
        ((50, 40, 320, 380), 375 - 40),
        ((400, 40, 660, 380), 375 - 40),
        ((730, 40, 990, 380), 375 - 40),
        ((1080, 40, 1330, 380), 375 - 40),
        ((170, 400, 420, 740), 736 - 400),
        ((600, 400, 860, 740), 736 - 400),
        ((995, 400, 1250, 740), 736 - 400),
    ]
    mv_march_frames = []
    for (box, gy) in mv_march_crops:
        c = clean_isolated_pixels(remove_bg_flood(mv_march_img.crop(box), tolerance=40))
        cx, _ = find_torso_center(c, gy)
        mv_march_frames.append(place_anchored(c, cx, gy, MV_SCALE))

    # Flame Sword Attack (Frames 8, 9, 10)
    mv_flame_crops = [
        ((30, 20, 350, 380), 375 - 20),
        ((350, 80, 850, 380), 375 - 80),
        ((850, 80, 1340, 380), 375 - 80),
    ]
    mv_flame_frames = []
    for (box, gy) in mv_flame_crops:
        c = clean_isolated_pixels(remove_bg_flood(mv_atk_img.crop(box), tolerance=40))
        cx, _ = find_torso_center(c, gy)
        mv_flame_frames.append(place_anchored(c, cx, gy, MV_SCALE))

    # Shield Bash Attack (Frames 16, 17, 18)
    mv_shield_crops = [
        ((50, 420, 360, 730), 736 - 420),
        ((360, 420, 880, 730), 736 - 420),
        ((880, 420, 1250, 730), 736 - 420),
    ]
    mv_shield_frames = []
    for (box, gy) in mv_shield_crops:
        c = clean_isolated_pixels(remove_bg_flood(mv_atk_img.crop(box), tolerance=40))
        cx, _ = find_torso_center(c, gy)
        mv_shield_frames.append(place_anchored(c, cx, gy, MV_SCALE))

    # Parried Stagger & Hurt (Frame 24, Frame 25)
    mv_stagger_crop = clean_isolated_pixels(remove_bg_flood(mv_orig_img.crop((540, 580, 960, 915)), tolerance=35))
    cx_ms, gy_ms = find_torso_center(mv_stagger_crop)
    mv_stagger = place_anchored(mv_stagger_crop, cx_ms, gy_ms, MV_SCALE)

    # Death sequence: 4 dramatic frames (Frames 26, 27, 28, 29)
    # Strip ground line inside panels is Y = 499
    mv_death_boxes = [
        # Panel 1: Staggered back, shield falling (x=42..330, y=200..500)
        ((42, 200, 330, 502), 499 - 200),
        # Panel 2: Sword planted into ground (x=372..660, y=200..500)
        ((372, 200, 660, 502), 499 - 200),
        # Panel 3: Collapsing onto knees (x=702..990, y=200..500)
        ((702, 200, 990, 502), 499 - 200),
        # Panel 4: Crumbling obsidian ash pile with rising smoke (x=1032..1320, y=200..502)
        ((1032, 200, 1320, 502), 499 - 200),
    ]
    mv_death_frames = []
    for (box, gy) in mv_death_boxes:
        c = clean_isolated_pixels(remove_bg_flood(mv_death_img.crop(box), tolerance=40))
        cx, _ = find_torso_center(c, gy)
        mv_death_frames.append(place_anchored(c, cx, gy, MV_SCALE))

    # Assemble Master Spritesheet: 2048 x 1024 (8 cols x 4 rows)
    mv_master = Image.new("RGBA", (2048, 1024), (0, 0, 0, 0))
    # Row 0: Locomotion (0: Idle, 1..7: March 0..6)
    mv_master.paste(mv_idle, (0 * 256, 0 * 256))
    for i in range(7):
        mv_master.paste(mv_march_frames[i], ((i + 1) * 256, 0 * 256))
    # Row 1: Flame Sword (8: windup, 9: flame sweep, 10: flame thrust)
    for i in range(3):
        mv_master.paste(mv_flame_frames[i], (i * 256, 1 * 256))
    # Row 2: Shield Bash (16: brace, 17: spark burst, 18: recover)
    for i in range(3):
        mv_master.paste(mv_shield_frames[i], (i * 256, 2 * 256))
    # Row 3: Reactions & Complete Death Animation
    # 24: Parried Stagger, 25: Hurt, 26: Death 1, 27: Death 2, 28: Death 3, 29: Death 4
    mv_master.paste(mv_stagger, (0 * 256, 3 * 256))
    mv_master.paste(mv_stagger, (1 * 256, 3 * 256)) # Hurt
    for i in range(4):
        mv_master.paste(mv_death_frames[i], ((i + 2) * 256, 3 * 256))

    mv_master_path = os.path.join(out_mayon, "mayon_vanguard_spritesheet.png")
    mv_master.save(mv_master_path)
    print("Saved Updated Mayon Vanguard Master Spritesheet:", mv_master_path)

if __name__ == "__main__":
    main()
