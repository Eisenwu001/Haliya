import os
import cv2
import numpy as np
from PIL import Image
from scipy.ndimage import binary_fill_holes, label

RAW_S1 = "C:/Users/Lin/.gemini/antigravity/brain/d1232b6c-c1d5-4adb-9f7d-742e59003878/.user_uploaded/media_1792896327769_8689766c.png"
RAW_S2 = "C:/Users/Lin/.gemini/antigravity/brain/d1232b6c-c1d5-4adb-9f7d-742e59003878/.user_uploaded/media_1792896327744_b5422873.png"
RAW_WALK_NEW = "C:/Users/Lin/.gemini/antigravity/brain/d1232b6c-c1d5-4adb-9f7d-742e59003878/forest_brute_walk_8x2_complete_1792902812298.jpg"
RAW_WALK_OLD = "C:/Users/Lin/.gemini/antigravity/brain/f58783f4-77f3-4438-92d1-5409479b469e/forest_brute_walk_1790926410384.jpg"
RAW_WHIRLWIND_V2 = "C:/Users/Lin/.gemini/antigravity/brain/d1232b6c-c1d5-4adb-9f7d-742e59003878/forest_brute_walk_and_whirlwind_v2_1792902467237.jpg"

OUT_DIR = os.path.normpath(os.path.abspath("assets/miniboss/forest_brute"))
os.makedirs(OUT_DIR, exist_ok=True)
OUT_PATH = os.path.join(OUT_DIR, "forest_brute_spritesheet.png")

# Generous 384x288 cell dimensions so NO extended attack, club swing, slash arc,
# or collapsing death pose is ever clipped at the cell boundary!
CELL_W = 384
CELL_H = 288
TARGET_CENTER_X = 192
TARGET_BASELINE_Y = 248

# Normalized scales so standing character height is ~169px across all sheets
SCALE_S1 = 1.15
SCALE_S2 = 1.74
SCALE_S2_COMPACT = 1.88          # Sheet 2 Rows 1, 2, 3 (Attack 2, Pickup, Attack 3 -> ~168px standing)
SCALE_WALK_X = 0.72              # Broad-shouldered muscular width matching Row 0 Idle
SCALE_WALK_Y = 169.0 / 292.0     # ~0.579 (maps 292px tall walk keyframes to 169px)
SCALE_WHIRLWIND_X = 0.90         # Broaden full-body Whirlwind & Earth-Shatter
SCALE_WHIRLWIND_Y = 172.0 / 205.0 # ~0.839 (maps 205px tall v2 whirlwind frames to 172px)


def find_2d_seam_black(strip_rgb, x_hint, half_win=30):
    """Finds a minimum-energy 2D seam from top to bottom through dark background pixels."""
    h, w = strip_rgb.shape[:2]
    x0 = max(0, x_hint - half_win)
    x1 = min(w, x_hint + half_win + 1)
    sub = np.max(strip_rgb[:, x0:x1, :3], axis=2).astype(float)
    sw = x1 - x0
    xs = np.arange(sw)[None, :] + x0
    energy = np.where(sub <= 3, 0.0, (sub ** 2)) + 0.04 * ((xs - x_hint) ** 2)
    dp = np.zeros_like(energy)
    back = np.zeros((h, sw), dtype=int)
    dp[0] = energy[0]
    for y in range(1, h):
        for x in range(sw):
            best_prev = x
            best_val = dp[y - 1, x]
            for dx in (-3, -2, -1, 1, 2, 3):
                nx = x + dx
                if 0 <= nx < sw:
                    val = dp[y - 1, nx] + abs(dx) * 1.5
                    if val < best_val:
                        best_val = val
                        best_prev = nx
            dp[y, x] = energy[y, x] + best_val
            back[y, x] = best_prev
    seam = np.zeros(h, dtype=int)
    cur = int(np.argmin(dp[h - 1]))
    for y in range(h - 1, -1, -1):
        seam[y] = x0 + cur
        cur = back[y, cur]
    return seam


def extract_row_by_seams_black(strip_rgba, seam_hints, min_comp_size=28):
    """
    Splits a horizontal row strip along 2D minimum-energy seams and removes the
    pure-black exterior background WITHOUT ever eating into interior shadows or outlines.
    """
    h, w = strip_rgba.shape[:2]
    seams = [np.zeros(h, dtype=int)]
    for h_x in seam_hints:
        seams.append(find_2d_seam_black(strip_rgba, h_x, half_win=30))
    seams.append(np.full(h, w, dtype=int))

    frames = []
    for i in range(len(seams) - 1):
        s_left = seams[i]
        s_right = seams[i + 1]
        x_min = max(0, int(s_left.min()) - 2)
        x_max = min(w, int(s_right.max()) + 2)

        crop = strip_rgba[:, x_min:x_max].copy()
        ch, cw = crop.shape[:2]
        for y in range(ch):
            lx = max(0, int(s_left[y]) - x_min)
            rx = min(cw, int(s_right[y]) - x_min)
            crop[y, :lx] = 0
            crop[y, rx:] = 0

        frames.append((x_min, remove_bg_solid_black(crop, min_comp_size=min_comp_size)))
    return frames


def remove_bg_solid_black(crop_rgba, min_comp_size=28):
    """
    Removes exterior black background while guaranteeing 100% solid interior opacity
    (zero holes in chest, waist, neck, or limbs).
    """
    arr = np.array(crop_rgba, dtype=np.uint8).copy()
    if arr.shape[2] == 3:
        rgba = np.zeros((arr.shape[0], arr.shape[1], 4), dtype=np.uint8)
        rgba[:, :, :3] = arr
        rgba[:, :, 3] = 255
        arr = rgba

    max_c = np.max(arr[:, :, :3], axis=2)
    # Any pixel with max RGB > 3 is part of the character or its dark outline
    fg_core = (max_c > 3).astype(np.uint8)

    # Close small 1-3px outline gaps so exterior flood fill never leaks inside waist/chest
    closed = cv2.morphologyEx(fg_core, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
    filled = binary_fill_holes(closed).astype(np.uint8)

    # Remove tiny isolated border dust speckles while keeping the main character + valid VFX/debris
    labeled, num_features = label(filled)
    if num_features > 1:
        sizes = np.bincount(labeled.ravel())
        sizes[0] = 0
        main_lbl = int(np.argmax(sizes))
        main_mask = (labeled == main_lbl)
        # Dilate main_mask by 28px to keep nearby flying rocks, slash arcs, or breath puffs
        near_main = cv2.dilate(main_mask.astype(np.uint8), np.ones((29, 29), np.uint8)) > 0
        for f_idx in range(1, num_features + 1):
            if f_idx == main_lbl:
                continue
            comp_mask = (labeled == f_idx)
            if sizes[f_idx] < min_comp_size or not np.any(comp_mask & near_main):
                filled[comp_mask] = 0

    arr[:, :, 3] = np.where(filled > 0, 255, 0).astype(np.uint8)
    return Image.fromarray(arr)


def remove_bg_solid_white(crop_rgb, tol=225):
    """
    Removes white background from high-res walk keyframes with 100% solid interior fill,
    zero white/grey anti-aliasing halo, and warm bark color grading matching Sheet 1 Row 0.
    """
    arr = np.zeros((crop_rgb.shape[0], crop_rgb.shape[1], 4), dtype=np.uint8)
    arr[:, :, :3] = crop_rgb
    min_c = np.min(crop_rgb, axis=2)
    max_c = np.max(crop_rgb, axis=2)
    sat = max_c.astype(int) - min_c.astype(int)

    # Exclude bright white background AND low-saturation grey anti-aliased edge pixels
    fg_core = ((min_c < tol) & ~((min_c > 110) & (sat < 32))).astype(np.uint8)
    closed = cv2.morphologyEx(fg_core, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
    filled = binary_fill_holes(closed).astype(np.uint8)

    labeled, num_features = label(filled)
    if num_features > 1:
        sizes = np.bincount(labeled.ravel())
        sizes[0] = 0
        main_lbl = int(np.argmax(sizes))
        filled = (labeled == main_lbl).astype(np.uint8)

    # Erode 1px of bright anti-aliased white border halo
    eroded = cv2.erode(filled, np.ones((3, 3), np.uint8))
    border_ring = (filled > 0) & (eroded == 0)
    bright_halo = border_ring & ((min_c > 95) | (sat < 22))
    filled[bright_halo] = 0

    eroded2 = cv2.erode(filled, np.ones((3, 3), np.uint8))
    outer_edge = (filled > 0) & (eroded2 == 0)

    # Warm bark color grading so walk frames match Sheet 1 Row 0's rich warm brown bark
    # (Row 0 mean RGB = (56, 40, 27), p75 = (82, 58, 37))
    rgb_f = arr[:, :, :3].astype(float)
    r, g, b = rgb_f[:, :, 0], rgb_f[:, :, 1], rgb_f[:, :, 2]

    # Identify mossy green leaf loincloth pixels (where G dominates R) vs brown bark/wood/horn pixels
    is_moss = (g > r + 3) & (filled > 0)
    is_bark = (~is_moss) & (filled > 0)

    # Clamp any residual desaturated bright grey pixels inside crevices
    desat_bright = is_bark & (b > 55) & ((r - b) < 18)
    r[desat_bright] *= 0.65
    g[desat_bright] *= 0.50
    b[desat_bright] *= 0.35

    # Boost warm reddish-gold bark midtones & highlights on bark pixels
    lum = 0.299 * r + 0.587 * g + 0.114 * b
    mid_mask = is_bark & (lum > 10)
    r[mid_mask] = np.clip(r[mid_mask] * 1.48 + 8.0, 0, 235)
    g[mid_mask] = np.clip(g[mid_mask] * 1.18 + 3.0, 0, 185)
    b[mid_mask] = np.clip(b[mid_mask] * 0.82 + 1.0, 0, 125)

    # Slightly enrich mossy green loincloth to match Sheet 1's warm forest moss
    r[is_moss] = np.clip(r[is_moss] * 1.12 + 4.0, 0, 160)
    g[is_moss] = np.clip(g[is_moss] * 1.15 + 4.0, 0, 180)
    b[is_moss] = np.clip(b[is_moss] * 0.78, 0, 100)

    arr[:, :, 0] = r.astype(np.uint8)
    arr[:, :, 1] = g.astype(np.uint8)
    arr[:, :, 2] = b.astype(np.uint8)

    # Darken outer 1px outline edge so it blends crisply like dark-fantasy pixel art
    arr[outer_edge, :3] = (arr[outer_edge, :3].astype(float) * 0.38).astype(np.uint8)
    arr[:, :, 3] = np.where(filled > 0, 255, 0).astype(np.uint8)
    return Image.fromarray(arr)


def find_torso_center(crop_img, ground_y=None):
    """Calculates horizontal center of the character's core torso (25%..58% height)."""
    arr = np.array(crop_img)
    alpha = arr[:, :, 3] > 128
    rows = np.where(np.sum(alpha, axis=1) >= 4)[0]
    if len(rows) == 0:
        return crop_img.width // 2, crop_img.height
    top_y = int(rows[0])
    bot_y = int(ground_y) if ground_y is not None else int(rows[-1])
    h = max(10, bot_y - top_y)
    t_top = top_y + int(h * 0.25)
    t_bot = top_y + int(h * 0.58)
    t_mask = alpha[t_top:t_bot, :]
    # Use median of foreground x-coordinates in torso band for jitter-free spine centering
    ys, xs = np.where(t_mask)
    if len(xs) > 0:
        return int(round(np.median(xs))), bot_y
    ys_all, xs_all = np.where(alpha)
    return int(round(np.median(xs_all))), bot_y


def place_anchored(crop_img, anchor_x, ground_y, scale_x, scale_y=None, y_offset=0):
    """
    Places a frame onto a (CELL_W, CELL_H) = (384, 288) canvas using sharp resampling
    and binarized alpha (>= 110 -> 255) so there are zero semi-transparent cutout artifacts.
    """
    if scale_y is None:
        scale_y = scale_x
    cw, ch = crop_img.size
    nw = max(1, int(round(cw * scale_x)))
    nh = max(1, int(round(ch * scale_y)))

    # Resize RGB with Lanczos for crisp detail, and resize Alpha with Bilinear+Threshold for solid silhouette
    arr = np.array(crop_img)
    rgb_img = Image.fromarray(arr[:, :, :3], mode="RGB").resize((nw, nh), Image.Resampling.LANCZOS)
    alpha_img = Image.fromarray(arr[:, :, 3], mode="L").resize((nw, nh), Image.Resampling.BILINEAR)

    rgb_arr = np.array(rgb_img)
    alpha_arr = np.where(np.array(alpha_img) >= 110, 255, 0).astype(np.uint8)

    # Ensure zero internal holes after scaling
    alpha_filled = binary_fill_holes(alpha_arr > 0).astype(np.uint8) * 255

    out_rgba = np.zeros((nh, nw, 4), dtype=np.uint8)
    out_rgba[:, :, :3] = rgb_arr
    out_rgba[:, :, 3] = alpha_filled
    resized = Image.fromarray(out_rgba)

    canvas = Image.new("RGBA", (CELL_W, CELL_H), (0, 0, 0, 0))
    paste_x = int(round(TARGET_CENTER_X - (anchor_x * scale_x)))
    paste_y = int(round(TARGET_BASELINE_Y - (ground_y * scale_y))) + int(y_offset)

    # Clamp paste_x if an extreme wide shockwave would touch the 384px border
    ys, xs = np.where(alpha_filled > 0)
    if len(xs) > 0:
        min_x = paste_x + int(xs.min())
        max_x = paste_x + int(xs.max())
        if max_x >= CELL_W - 4:
            paste_x -= (max_x - (CELL_W - 4))
        if min_x < 4:
            paste_x += (4 - min_x)

    canvas.paste(resized, (paste_x, paste_y), resized)
    return canvas


def clean_legs_only(l_arr, cx_l, waist_l):
    """Removes swinging unarmed arms/hands below the waist so only legs & loincloth remain."""
    arr = l_arr.copy()
    h, w = arr.shape[:2]
    for y in range(max(0, waist_l - 4), min(h, waist_l + 85)):
        xs = np.where(arr[y, :, 3] > 0)[0]
        if len(xs) == 0:
            continue
        # Also clear any stray flank pixels farther than 50px from center above knee level
        if y < waist_l + 65:
            far_flanks = (np.abs(np.arange(w) - cx_l) > 50) & (arr[y, :, 3] > 0)
            arr[y, far_flanks, 3] = 0
            xs = np.where(arr[y, :, 3] > 0)[0]
            if len(xs) == 0:
                continue

        diffs = np.diff(xs)
        gap_indices = np.where(diffs > 4)[0]
        if len(gap_indices) == 0:
            continue
        start = xs[0]
        segments = []
        for g in gap_indices:
            segments.append((start, xs[g]))
            start = xs[g + 1]
        segments.append((start, xs[-1]))

        for seg_start, seg_end in segments:
            is_trunk = (seg_start <= cx_l <= seg_end) or (abs((seg_start + seg_end)/2.0 - cx_l) < 32.0)
            if not is_trunk:
                arr[y, seg_start:seg_end + 1, 3] = 0
    return arr


def graft_torso_and_legs(upper_tuple, lower_tuple, shade_back_leg=False, shade_front_leg=False, isolate_legs_only=False):
    """
    Cleanly grafts the upper torso of `upper_tuple` (img, cx, gy) onto the walking legs
    of `lower_tuple` (img, cx, gy) at the leafy waist belt, with optional leg depth shading
    so left-step and right-step half-cycles are clearly distinguished!
    When `isolate_legs_only=True`, swinging unarmed arms below the waist are stripped out
    so the resulting armed character NEVER has duplicate phantom hands.
    """
    u_img, cx_u, gy_u = upper_tuple
    l_img, cx_l, gy_l = lower_tuple
    canvas = Image.new("RGBA", (360, 380), (0, 0, 0, 0))
    target_cx = 180
    target_gy = 350

    u_arr = np.array(u_img).copy()
    l_arr = np.array(l_img).copy()

    waist_u = gy_u - 154
    waist_l = gy_l - 154

    if isolate_legs_only:
        l_arr = clean_legs_only(l_arr, cx_l, waist_l)

    # Optional depth-cue shading on legs below loincloth (y > waist_l + 32)
    leg_y_start = max(0, waist_l + 32)
    if shade_back_leg:
        # Darken left/rear half of legs (x < cx_l) by 22% to push rear leg into shadow
        mask_rear = (l_arr[leg_y_start:, :cx_l, 3] > 0)
        l_arr[leg_y_start:, :cx_l, :3][mask_rear] = (
            l_arr[leg_y_start:, :cx_l, :3][mask_rear].astype(float) * 0.78
        ).astype(np.uint8)
    elif shade_front_leg:
        # Darken right/forward half of legs (x >= cx_l) slightly and brighten rear leg
        mask_fwd = (l_arr[leg_y_start:, cx_l:, 3] > 0)
        l_arr[leg_y_start:, cx_l:, :3][mask_fwd] = (
            l_arr[leg_y_start:, cx_l:, :3][mask_fwd].astype(float) * 0.80
        ).astype(np.uint8)

    l_arr[:waist_l - 4, :, 3] = 0
    u_arr[waist_u + 6:, :, 3] = 0

    l_part = Image.fromarray(l_arr)
    u_part = Image.fromarray(u_arr)

    canvas.paste(l_part, (target_cx - cx_l, target_gy - gy_l), l_part)
    canvas.paste(u_part, (target_cx - cx_u, target_gy - gy_u), u_part)
    return canvas, target_cx, target_gy


def build_walk_cycles(s1_ref_crop):
    """
    Builds both:
    - Row 1: 8-frame Smooth Unarmed Walk Cycle (with alternating lifted knees, passing legs, arm swing, and stride bob)
    - Row 8: 8-frame Smooth Phase 2 Armed Walk Cycle (carrying the giant spiked club on shoulder)
    """
    im_new = np.array(Image.open(RAW_WALK_NEW).convert("RGB"))
    im_old = np.array(Image.open(RAW_WALK_OLD).convert("RGB"))

    # 1. Extract the 4 isolated Unarmed Walk keyframes from Top Row of RAW_WALK_NEW
    # Ground baseline is at y = 359 (so inside y=25..365, gy = 334)
    u_boxes = [
        (75, 25, 340, 365),    # Key 0: Wide heel-strike stride (front arm forward)
        (415, 25, 650, 365),   # Key 1: Weight transfer / Down pose
        (725, 25, 960, 365),   # Key 2: Mid-stride Passing crossover
        (1025, 25, 1290, 365), # Key 3: Push-off extension stride (front arm back)
    ]
    gy_u = 334
    u_keys = []
    for (x0, y0, x1, y1) in u_boxes:
        c = remove_bg_solid_white(im_new[y0:y1, x0:x1])
        cx, _ = find_torso_center(c, gy_u)
        u_keys.append((c, cx, gy_u))

    # 2. Extract the High-Knee Lifted Stride (Pose 2 of Bottom Row in RAW_WALK_NEW,
    # masked cleanly using RAW_WALK_OLD's isolated silhouette for the legs)
    hk_old_crop = im_old[385:725, 545:825]
    hk_new_crop = im_new[385:725, 545:825].copy()
    fg_old = (np.min(hk_old_crop, axis=2) < 230).astype(np.uint8)
    mask_allow = cv2.dilate(fg_old, np.ones((7, 7), np.uint8))
    mask_allow[:, 65:195] = cv2.dilate(fg_old[:, 65:195], np.ones((25, 25), np.uint8))
    hk_new_masked = np.where(mask_allow[:, :, None] > 0, hk_new_crop, 255).astype(np.uint8)
    hk_legs_img = remove_bg_solid_white(hk_new_masked)
    # Stretch hk_legs_img vertically by 1.08x so the planted support leg has the exact same
    # waist-to-heel length (154px) as u_keys[0..3], keeping the planted foot on the ground!
    hk_w, hk_h = hk_legs_img.size
    hk_legs_img = hk_legs_img.resize((hk_w, int(round(hk_h * 1.08))), Image.Resampling.LANCZOS)
    hk_arr_check = np.array(hk_legs_img)
    hk_bot_y = int(np.where(hk_arr_check[:, :, 3] > 128)[0].max())
    cx_hk_legs, _ = find_torso_center(hk_legs_img, hk_bot_y)
    hk_tuple = (hk_legs_img, cx_hk_legs, hk_bot_y)

    # Create 8 distinct full-cycle Unarmed Walk poses (Frames 0..3 = Right Step, Frames 4..7 = Left Step)
    # by pairing alternating arm-swing upper torsos (Key 0..3) with depth-shaded alternating legs!
    pose_0 = graft_torso_and_legs(u_keys[0], u_keys[0], shade_back_leg=True)   # F0: Right Heel Strike
    pose_1 = graft_torso_and_legs(u_keys[1], u_keys[1], shade_back_leg=True)   # F1: Right Weight Down
    pose_2 = graft_torso_and_legs(u_keys[2], u_keys[2], shade_back_leg=True)   # F2: Right Passing Crossover
    pose_3 = graft_torso_and_legs(u_keys[2], hk_tuple,  shade_back_leg=True)   # F3: Left High-Knee Drive
    pose_4 = graft_torso_and_legs(u_keys[3], u_keys[3], shade_front_leg=True)  # F4: Left Heel Strike / Push-Off
    pose_5 = graft_torso_and_legs(u_keys[3], u_keys[1], shade_front_leg=True)  # F5: Left Weight Down (arms back)
    pose_6 = graft_torso_and_legs(u_keys[0], u_keys[2], shade_front_leg=True)  # F6: Left Passing (arms swinging fwd)
    pose_7 = graft_torso_and_legs(u_keys[0], hk_tuple,  shade_front_leg=True)  # F7: Right High-Knee Reach

    eight_poses = [pose_0, pose_1, pose_2, pose_3, pose_4, pose_5, pose_6, pose_7]

    # 3. Extract the 100% isolated Armed Upper Body + Spiked Club on Shoulder
    # from Bottom Row Figure 4 (x=990..1310, y=360..735) of RAW_WALK_NEW
    strip_b = im_new[360:735, :, :]
    dark_b = 255.0 - np.min(strip_b[:, :, :3].astype(float), axis=2)
    x0_s, x1_s = 975, 1065
    sub_b = dark_b[:, x0_s:x1_s]
    sw_b = x1_s - x0_s
    xs_b = np.arange(sw_b)[None, :] + x0_s
    energy_b = np.where(sub_b <= 18, 0.0, sub_b ** 2) + 0.05 * ((xs_b - 1020) ** 2)
    dp_b = np.zeros_like(energy_b)
    back_b = np.zeros((strip_b.shape[0], sw_b), dtype=int)
    dp_b[0] = energy_b[0]
    for y in range(1, strip_b.shape[0]):
        for x in range(sw_b):
            bp = x
            bv = dp_b[y - 1, x]
            for dx in (-3, -2, -1, 1, 2, 3):
                nx = x + dx
                if 0 <= nx < sw_b:
                    v = dp_b[y - 1, nx] + abs(dx) * 2.0
                    if v < bv:
                        bv = v
                        bp = nx
            dp_b[y, x] = energy_b[y, x] + bv
            back_b[y, x] = bp
    seam_b = np.zeros(strip_b.shape[0], dtype=int)
    cur_b = int(np.argmin(dp_b[-1]))
    for y in range(strip_b.shape[0] - 1, -1, -1):
        seam_b[y] = x0_s + cur_b
        cur_b = back_b[y, cur_b]

    armed_crop_rgb = strip_b.copy()
    for y in range(armed_crop_rgb.shape[0]):
        armed_crop_rgb[y, :seam_b[y]] = 255
    armed_crop_rgb = armed_crop_rgb[:, 990:1315]
    armed_full_img = remove_bg_solid_white(armed_crop_rgb)
    gy_armed = 711 - 360  # 351
    cx_armed, _ = find_torso_center(armed_full_img, gy_armed)
    armed_upper_tuple = (armed_full_img, cx_armed, gy_armed)

    # Vertical bob & subtle forward/back lean across the 8-frame heavy brute stride
    bob_and_lean = [
        ( 0,  0.0),  # F0: Contact
        ( 2,  1.4),  # F1: Heavy Down
        ( 0,  0.4),  # F2: Passing
        (-3, -1.2),  # F3: High-Knee Lift
        ( 0,  1.2),  # F4: Opposite Contact
        ( 2,  1.6),  # F5: Heavy Down
        (-1, -0.4),  # F6: Passing
        (-2,  0.6),  # F7: High-Knee Reach
    ]

    unarmed_walk_cells = []
    armed_walk_cells = []

    for frame_idx in range(8):
        _, lean_deg = bob_and_lean[frame_idx]
        u_img, cx_b, _ = eight_poses[frame_idx]
        if abs(lean_deg) > 0.1:
            u_frame = u_img.rotate(lean_deg, resample=Image.Resampling.BICUBIC, center=(cx_b, 350 - 90))
        else:
            u_frame = u_img.copy()

        # Find actual bottom of u_frame so planted foot is always at ground baseline
        u_arr = np.array(u_frame)
        ys_u = np.where(u_arr[:, :, 3] > 120)[0]
        actual_bot_u = int(ys_u.max()) if len(ys_u) > 0 else 350

        cell_u = place_anchored(u_frame, cx_b, actual_bot_u, SCALE_WALK_X, SCALE_WALK_Y, y_offset=0)
        unarmed_walk_cells.append(cell_u)

        # Build Armed Walk frame using armed_upper_tuple + the clean leg-only lower body of eight_poses[frame_idx]
        a_img, cx_a, _ = graft_torso_and_legs(armed_upper_tuple, eight_poses[frame_idx], isolate_legs_only=True)
        if abs(lean_deg) > 0.1:
            a_frame = a_img.rotate(lean_deg * 0.85, resample=Image.Resampling.BICUBIC, center=(cx_a, 350 - 90))
        else:
            a_frame = a_img

        a_arr = np.array(a_frame)
        ys_a = np.where(a_arr[:, :, 3] > 120)[0]
        actual_bot_a = int(ys_a.max()) if len(ys_a) > 0 else 350

        cell_a = place_anchored(a_frame, cx_a, actual_bot_a, SCALE_WALK_X, SCALE_WALK_Y, y_offset=0)
        armed_walk_cells.append(cell_a)

    return unarmed_walk_cells, armed_walk_cells


def extract_whirlwind_row_v2():
    """
    Extracts the 7 full-body frames of Row 6 (Green Whirlwind & Earth-Shatter Club Slam)
    from RAW_WHIRLWIND_V2 Row 3 (which has 100% full legs, feet, club, green cyclone, and fissure!).
    """
    v2 = np.array(Image.open(RAW_WHIRLWIND_V2).convert("RGB"))
    strip = v2[485:765, :, :]
    h, w, _ = strip.shape

    # Background in v2 Row 3 is uniform dark grey ~(55, 55, 55)
    bg_med = np.median(strip[:8, :, :], axis=(0, 1))
    diff = np.max(np.abs(strip.astype(float) - bg_med), axis=2)

    # Convert dark grey background to pure black so our 2D seam & solid bg remover work seamlessly
    fg_mask = (diff > 19).astype(np.uint8)
    closed = cv2.morphologyEx(fg_mask, cv2.MORPH_CLOSE, np.ones((5, 5), np.uint8))
    filled = binary_fill_holes(closed).astype(np.uint8)

    # Erode 1px grey halo on outer edge
    eroded = cv2.erode(filled, np.ones((3, 3), np.uint8))
    edge = (filled > 0) & (eroded == 0)
    grey_halo = edge & (diff < 36)
    filled[grey_halo] = 0

    strip_rgba = np.zeros((h, w, 4), dtype=np.uint8)
    strip_rgba[:, :, :3] = np.where(filled[:, :, None] > 0, strip, 0)
    strip_rgba[:, :, 3] = filled * 255

    seam_hints = [196, 382, 615, 822, 978, 1158]
    extracted = extract_row_by_seams_black(strip_rgba, seam_hints, min_comp_size=25)

    # Ground line in v2 Row 3 (y=485..765) is at y = 264 (global y = 749)
    gy_w = 264
    cells = []
    for idx, (_, frame_img) in enumerate(extracted):
        cx, _ = find_torso_center(frame_img, gy_w)
        cells.append(place_anchored(frame_img, cx, gy_w, SCALE_WHIRLWIND_X, SCALE_WHIRLWIND_Y))
    return cells


def main():
    print("Loading sprite sheets...")
    s1 = np.array(Image.open(RAW_S1).convert("RGBA"))
    s2 = np.array(Image.open(RAW_S2).convert("RGBA"))

    # Master Spritesheet: 10 columns x 9 rows of (384 x 288) = (3840 x 2592)
    master = Image.new("RGBA", (10 * CELL_W, 9 * CELL_H), (0, 0, 0, 0))

    # -------------------------------------------------------------------------
    # ROW 0: Phase 1 Unarmed Idle — 8 frames (Sheet 1 Row 0)
    # -------------------------------------------------------------------------
    print("Processing Row 0: Phase 1 Unarmed Idle...")
    y0_0, y1_0 = 10, 170
    gy_0 = 162 - y0_0
    idle_hints = [137, 260, 388, 516, 648, 777, 909]
    idle_frames = extract_row_by_seams_black(s1[y0_0:y1_0], idle_hints, min_comp_size=35)
    for i, (_, c) in enumerate(idle_frames):
        cx, _ = find_torso_center(c, gy_0)
        cell = place_anchored(c, cx, gy_0, SCALE_S1)
        master.paste(cell, (i * CELL_W, 0 * CELL_H))
    master.paste(master.crop((0 * CELL_W, 0, 1 * CELL_W, CELL_H)), (8 * CELL_W, 0))
    master.paste(master.crop((1 * CELL_W, 0, 2 * CELL_W, CELL_H)), (9 * CELL_W, 0))

    # -------------------------------------------------------------------------
    # ROW 1 & ROW 8: Smooth 8-Frame Unarmed Walk (Row 1) & Armed Walk (Row 8)
    # -------------------------------------------------------------------------
    print("Processing Row 1 (Unarmed Walk) & Row 8 (Phase 2 Armed Walk)...")
    unarmed_walk_cells, armed_walk_cells = build_walk_cycles(idle_frames[0][1])
    for i in range(8):
        master.paste(unarmed_walk_cells[i], (i * CELL_W, 1 * CELL_H))
        master.paste(armed_walk_cells[i], (i * CELL_W, 8 * CELL_H))
    # Fill cols 8 & 9 for seamless wrap safety
    for i in range(2):
        master.paste(unarmed_walk_cells[i], ((8 + i) * CELL_W, 1 * CELL_H))
        master.paste(armed_walk_cells[i], ((8 + i) * CELL_W, 8 * CELL_H))

    # -------------------------------------------------------------------------
    # ROW 2: Phase 1 Attack 1 (Claw Swipe Combo) — 8 frames (Sheet 2 Row 0)
    # -------------------------------------------------------------------------
    print("Processing Row 2: Phase 1 Attack 1 (Claw Swipe Combo)...")
    y0_2, y1_2 = 10, 123
    gy_2 = 117 - y0_2
    a1_hints = [115, 236, 360, 466, 600, 742, 906]
    a1_frames = extract_row_by_seams_black(s2[y0_2:y1_2], a1_hints, min_comp_size=25)
    for i, (_, c) in enumerate(a1_frames):
        cx, _ = find_torso_center(c, gy_2)
        cell = place_anchored(c, cx, gy_2, SCALE_S2)
        master.paste(cell, (i * CELL_W, 2 * CELL_H))

    # -------------------------------------------------------------------------
    # ROW 3: Phase 1 Attack 2 (Dual-Fist Earth Slam) — 9 frames (Sheet 2 Row 1)
    # -------------------------------------------------------------------------
    print("Processing Row 3: Phase 1 Attack 2 (Dual-Fist Earth Slam)...")
    y0_3, y1_3 = 123, 236
    gy_3 = 228 - y0_3
    a2_hints = [108, 224, 330, 435, 545, 652, 760, 906]
    a2_frames = extract_row_by_seams_black(s2[y0_3:y1_3], a2_hints, min_comp_size=18)
    for i, (_, c) in enumerate(a2_frames):
        cx, _ = find_torso_center(c, gy_3)
        cell = place_anchored(c, cx, gy_3, SCALE_S2_COMPACT)
        master.paste(cell, (i * CELL_W, 3 * CELL_H))

    # -------------------------------------------------------------------------
    # ROW 4: Phase Transition (Weapon Pickup & Regen) — 9 frames (Sheet 2 Row 2)
    # -------------------------------------------------------------------------
    print("Processing Row 4: Phase Transition (Weapon Pickup & Regen)...")
    y0_4, y1_4 = 236, 342
    gy_4 = 337 - y0_4
    p_hints = [106, 227, 345, 474, 589, 706, 800, 919]
    p_frames = extract_row_by_seams_black(s2[y0_4:y1_4], p_hints, min_comp_size=25)
    for i, (_, c) in enumerate(p_frames):
        cx, _ = find_torso_center(c, gy_4)
        cell = place_anchored(c, cx, gy_4, SCALE_S2_COMPACT)
        master.paste(cell, (i * CELL_W, 4 * CELL_H))

    # -------------------------------------------------------------------------
    # ROW 5: Phase 2 Attack 3 (Spiked Club Combo) — 7 frames (Sheet 2 Row 3)
    # -------------------------------------------------------------------------
    print("Processing Row 5: Phase 2 Attack 3 (Spiked Club Combo)...")
    y0_5, y1_5 = 336, 444
    gy_5 = 442 - y0_5
    a3_hints = [131, 298, 437, 596, 701, 882]
    a3_frames = extract_row_by_seams_black(s2[y0_5:y1_5], a3_hints, min_comp_size=20)
    for i, (_, c) in enumerate(a3_frames):
        cx, _ = find_torso_center(c, gy_5)
        cell = place_anchored(c, cx, gy_5, SCALE_S2_COMPACT)
        master.paste(cell, (i * CELL_W, 5 * CELL_H))

    # -------------------------------------------------------------------------
    # ROW 6: Phase 2 Attack 4 (Green Whirlwind & Earth-Shatter) — 7 full-body frames
    # -------------------------------------------------------------------------
    print("Processing Row 6: Phase 2 Attack 4 (Full-Body Green Whirlwind & Earth-Shatter)...")
    w_cells = extract_whirlwind_row_v2()
    for i, cell in enumerate(w_cells):
        master.paste(cell, (i * CELL_W, 6 * CELL_H))

    # -------------------------------------------------------------------------
    # ROW 7: Death Sequence — 8 frames (Sheet 1 Row 2)
    # -------------------------------------------------------------------------
    print("Processing Row 7: Death Sequence...")
    y0_7, y1_7 = 350, 505
    gy_7 = 496 - y0_7
    d_hints = [134, 253, 356, 467, 615, 748, 888]
    d_frames = extract_row_by_seams_black(s1[y0_7:y1_7], d_hints, min_comp_size=35)
    for i, (_, c) in enumerate(d_frames):
        cx, _ = find_torso_center(c, gy_7)
        cell = place_anchored(c, cx, gy_7, SCALE_S1)
        master.paste(cell, (i * CELL_W, 7 * CELL_H))

    master.save(OUT_PATH)
    print(f"Master Spritesheet successfully saved to: {OUT_PATH}")
    print(f"Resolution: {master.size} (10 cols x 9 rows, {CELL_W}x{CELL_H} per frame)")


if __name__ == "__main__":
    main()
