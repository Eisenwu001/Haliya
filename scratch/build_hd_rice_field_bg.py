import os
import math
import cv2
import numpy as np
from PIL import Image
from scipy.ndimage import (
    distance_transform_edt,
    gaussian_filter,
    minimum_filter,
    maximum_filter,
    binary_erosion,
    binary_fill_holes,
)

RAW_DIR = "C:/Users/Lin/.gemini/antigravity/brain/feb5818d-94e6-427e-b0af-0b238400ce42/.user_uploaded/"
OUT_DIR = "assets/bicol_bg/"
os.makedirs(OUT_DIR, exist_ok=True)

# 1080p HD Canvas: 3840 x 1080 (2 seamless tiles of 1920 x 1080)
# In Godot's 640 x 360 logical viewport:
# scale_factor = 360.0 / 1080.0 = 1/3 -> 1 tile (1920px) = 640 logical pixels wide (zero zoom-in!)
TILE_W = 1920
CANVAS_W = 3840
CANVAS_H = 1080

# Proportional scale from 1024px raw width to 1920px HD tile width (640 logical px at 1/3 scale)
SCALE_HD = TILE_W / 1024.0  # 1.875x in HD pixels = 0.625x in 640x360 logical viewport (un-zoomed!)
Y_RAW_ANCHOR = 293.0
Y_HD_ANCHOR = 870.0  # 290.0 * 3


def raw_y_to_hd_y(y_raw: float) -> int:
    return int(round(Y_HD_ANCHOR - SCALE_HD * (Y_RAW_ANCHOR - y_raw)))


def inpaint_rgb_from_interior(rgb_float, core_mask, smooth_sigma=0.5):
    """
    Propagates true interior foreground RGB values outward into any transparent or semi-transparent
    fringe pixels using exact 2D Euclidean Nearest Neighbor (distance_transform_edt).
    """
    outside = ~core_mask
    if not np.any(outside) or not np.any(core_mask):
        return rgb_float.copy()
    _, indices = distance_transform_edt(outside, return_indices=True)
    filled = rgb_float[indices[0], indices[1]].copy()
    if smooth_sigma > 0:
        for c in range(3):
            blurred = gaussian_filter(filled[:, :, c], sigma=smooth_sigma)
            filled[outside, c] = blurred[outside]
    return filled


def guided_shock_super_resolve(
    rgb_clean_u8,
    alpha_clean_f32,
    target_w,
    target_h,
    shock_iters=2,
    shock_dt=0.42,
    detail_gain=0.65,
):
    """
    High-Definition Super-Resolution & Detail Reconstruction:
    1. Pre-sharpens the source at native resolution using local min/max clamped detail boost.
    2. Upscales with INTER_LANCZOS4.
    3. Applies iterative Kramer-Bruckner / Osher-Rudin Morphological Shock Filtering to compress
       blurry interpolation ramps into crisp 1px edges with ZERO overshoot halos.
    4. Enhances micro-contrast strictly clamped to local 3x3 min/max.
    """
    src_f = rgb_clean_u8.astype(np.float32)
    for c in range(3):
        ch = src_f[:, :, c]
        blur = gaussian_filter(ch, sigma=0.8)
        loc_min = minimum_filter(ch, size=3)
        loc_max = maximum_filter(ch, size=3)
        src_f[:, :, c] = np.clip(ch + 0.60 * (ch - blur), loc_min, loc_max)
    src_pre = np.clip(src_f, 0, 255).astype(np.uint8)

    up_rgb = cv2.resize(src_pre, (target_w, target_h), interpolation=cv2.INTER_LANCZOS4)
    up_alpha = cv2.resize(alpha_clean_f32, (target_w, target_h), interpolation=cv2.INTER_LANCZOS4)

    cur = up_rgb.astype(np.float32)
    for _ in range(shock_iters):
        for c in range(3):
            ch = cur[:, :, c]
            loc_min = minimum_filter(ch, size=3)
            loc_max = maximum_filter(ch, size=3)
            blur = gaussian_filter(ch, sigma=0.85)
            diff = ch - blur
            span = np.maximum(loc_max - loc_min, 1.0)
            weight = np.tanh(diff / (span * 0.22 + 2.0))
            target_val = np.where(weight >= 0, loc_max, loc_min)
            cur[:, :, c] = ch + shock_dt * np.abs(weight) * (target_val - ch)

    for c in range(3):
        ch = cur[:, :, c]
        blur = gaussian_filter(ch, sigma=0.9)
        loc_min = minimum_filter(ch, size=3)
        loc_max = maximum_filter(ch, size=3)
        cur[:, :, c] = np.clip(ch + detail_gain * (ch - blur), loc_min, loc_max)

    out_rgb = np.clip(cur, 0, 255).astype(np.uint8)
    out_alpha = np.clip((up_alpha - 128.0) * 1.35 + 128.0, 0.0, 255.0).astype(np.uint8)
    return out_rgb, out_alpha


def make_seamless_horizon_tile(rgb_raw, alpha_raw, target_w, target_h, erode_px=2, blend_raw_px=64):
    """
    Cleans boundary RGB, aligns right-edge horizon contour with left-edge contour, performs
    a C1-continuous circular overlap blend with contour warping, and super-resolves to HD.
    """
    H_r, W_r = alpha_raw.shape
    mask_bin = alpha_raw > 215
    core_mask = binary_erosion(mask_bin, iterations=erode_px) if erode_px > 0 else mask_bin
    rgb_clean = inpaint_rgb_from_interior(rgb_raw.astype(np.float32), core_mask, smooth_sigma=0.4)
    alpha_clean = alpha_raw.astype(np.float32).copy()

    ext_w = W_r + blend_raw_px
    rgb_ext = cv2.resize(rgb_clean, (ext_w, H_r), interpolation=cv2.INTER_LANCZOS4)
    a_ext = cv2.resize(alpha_clean, (ext_w, H_r), interpolation=cv2.INTER_LANCZOS4)

    B = blend_raw_px
    head_rgb = rgb_ext[:, :B].copy()
    tail_rgb = rgb_ext[:, W_r : W_r + B].copy()
    head_a = a_ext[:, :B].copy()
    tail_a = a_ext[:, W_r : W_r + B].copy()

    y_coords = np.arange(H_r, dtype=np.float32)
    for i in range(B):
        t = float(i + 1) / float(B + 1)
        w_head = 0.5 * (1.0 - math.cos(math.pi * t))
        w_tail = 1.0 - w_head

        ys_h = np.where(head_a[:, i] > 128)[0]
        ys_t = np.where(tail_a[:, i] > 128)[0]
        if len(ys_h) > 0 and len(ys_t) > 0:
            dh = float(ys_h[0]) - float(ys_t[0])
            sh_h = -dh * w_tail
            sh_t = dh * w_head

            sy_h = np.clip(y_coords - sh_h, 0.0, float(H_r - 1))
            yh0 = np.floor(sy_h).astype(int)
            yh1 = np.minimum(yh0 + 1, H_r - 1)
            fyh = sy_h - yh0
            col_h_rgb = head_rgb[yh0, i] * (1.0 - fyh[:, None]) + head_rgb[yh1, i] * fyh[:, None]
            col_h_a = head_a[yh0, i] * (1.0 - fyh) + head_a[yh1, i] * fyh

            sy_t = np.clip(y_coords - sh_t, 0.0, float(H_r - 1))
            yt0 = np.floor(sy_t).astype(int)
            yt1 = np.minimum(yt0 + 1, H_r - 1)
            fyt = sy_t - yt0
            col_t_rgb = tail_rgb[yt0, i] * (1.0 - fyt[:, None]) + tail_rgb[yt1, i] * fyt[:, None]
            col_t_a = tail_a[yt0, i] * (1.0 - fyt) + tail_a[yt1, i] * fyt
        else:
            col_h_rgb, col_h_a = head_rgb[:, i], head_a[:, i]
            col_t_rgb, col_t_a = tail_rgb[:, i], tail_a[:, i]

        comb_a = w_tail * col_t_a + w_head * col_h_a
        wt_eff = w_tail * (col_t_a / 255.0 + 0.01)
        wh_eff = w_head * (col_h_a / 255.0 + 0.01)
        comb_rgb = (col_t_rgb * wt_eff[:, None] + col_h_rgb * wh_eff[:, None]) / (wt_eff + wh_eff)[:, None]

        rgb_ext[:, i] = comb_rgb
        a_ext[:, i] = comb_a

    rgb_seamless_raw = np.clip(rgb_ext[:, :W_r], 0, 255).astype(np.uint8)
    a_seamless_raw = np.clip(a_ext[:, :W_r], 0, 255).astype(np.float32)

    core2 = a_seamless_raw > 215
    rgb_seamless_padded = np.clip(
        inpaint_rgb_from_interior(rgb_seamless_raw.astype(np.float32), core2, smooth_sigma=0.3),
        0,
        255,
    ).astype(np.uint8)

    hd_rgb, hd_a = guided_shock_super_resolve(rgb_seamless_padded, a_seamless_raw, target_w, target_h)
    zero_a = hd_a < 3
    hd_a[zero_a] = 0
    hd_rgb[zero_a] = 0

    return np.concatenate([hd_rgb, hd_rgb], axis=1), np.concatenate([hd_a, hd_a], axis=1)


def build_all_hd_layers():
    # -------------------------------------------------------------------------
    # LAYER 4: Distant Mount Mayon Volcano, Smoke Plume, Golden Clouds & Sky
    # -------------------------------------------------------------------------
    print("1. Building HD Layer 4 (Mount Mayon Volcano & Golden Sunrise Sky)...")
    raw4 = Image.open(os.path.join(RAW_DIR, "media_1792846446695_992912fa.png")).convert("RGBA")
    arr4 = np.array(raw4)
    rgb4 = arr4[:, :, :3].astype(np.float32)
    max4 = rgb4.max(axis=2)

    fg4 = (max4 > 22) & (np.arange(raw4.height)[:, None] < 278)
    num_l, labels, stats, _ = cv2.connectedComponentsWithStats(fg4.astype(np.uint8), connectivity=8)
    for i in range(1, num_l):
        if stats[i, cv2.CC_STAT_AREA] < 500:
            fg4[labels == i] = False
    fg4 = binary_fill_holes(fg4)

    # Pure interior core: erode by 3px AND exclude any dark smoke/cloud border pixels (y < 110 with max4 < 145)
    core4 = binary_erosion(fg4, iterations=3)
    smoke_dark = (np.arange(raw4.height)[:, None] < 112) & (max4 < 145)
    core4[smoke_dark] = False

    rgb4_int = inpaint_rgb_from_interior(rgb4, core4, smooth_sigma=0.5)
    int_max4 = np.maximum(rgb4_int.max(axis=2), 1.0)

    alpha4 = np.zeros((raw4.height, raw4.width), dtype=np.float32)
    alpha4[core4] = 255.0
    border4 = fg4 & (~core4)
    est_a4 = np.clip((max4[border4] - 14.0) / np.maximum(int_max4[border4] - 14.0, 12.0), 0.0, 1.0)
    alpha4[border4] = (est_a4 ** 0.80) * 255.0

    rgb4_clean = rgb4.copy()
    rgb4_clean[~core4] = rgb4_int[~core4]

    # Include 12px sky headroom above y=78 so warping never clips smoke top
    y0_4, y1_4 = 68, 260
    h_hd_4 = int(round((y1_4 - y0_4) * SCALE_HD))  # 360px
    pan4_rgb, pan4_a = make_seamless_horizon_tile(
        np.clip(rgb4_clean[y0_4:y1_4], 0, 255).astype(np.uint8),
        alpha4[y0_4:y1_4],
        TILE_W,
        h_hd_4,
        erode_px=1,
        blend_raw_px=64,
    )

    # Smoothly fade the dark lower tree base of Layer 4 (below the cloud bank, y_hd > 245)
    # into warm atmospheric mountain mist so no dark foreground tree color ever peeks behind Layer 3
    mist_start = int(round((202 - y0_4) * SCALE_HD))  # ~251
    if mist_start < h_hd_4:
        t_mist = np.linspace(0.0, 1.0, h_hd_4 - mist_start, dtype=np.float32)[:, None, None]
        mist_col = np.array([114.0, 139.0, 115.0], dtype=np.float32)[None, None, :]
        pan4_rgb[mist_start:] = np.clip(
            pan4_rgb[mist_start:].astype(np.float32) * (1.0 - t_mist) + mist_col * t_mist, 0, 255
        ).astype(np.uint8)

    # Build 3840 x 1080 Golden Sunrise Sky
    sky = np.zeros((CANVAS_H, CANVAS_W, 3), dtype=np.float32)
    y_norm = np.clip(np.arange(CANVAS_H, dtype=np.float32) / 720.0, 0.0, 1.0)[:, None]
    c_top = np.array([238.0, 176.0, 124.0])
    c_mid = np.array([250.0, 210.0, 154.0])
    c_bot = np.array([254.0, 236.0, 192.0])
    top_half = y_norm < 0.5
    t_top = y_norm * 2.0
    t_bot = (y_norm - 0.5) * 2.0
    sky[:] = np.where(
        top_half[:, :, None],
        c_top * (1.0 - t_top[:, :, None]) + c_mid * t_top[:, :, None],
        c_mid * (1.0 - t_bot[:, :, None]) + c_bot * t_bot[:, :, None],
    )

    # Shift Layer 4 up by 24 raw px so Mount Mayon, golden clouds, and left sunlit peak tower grandly
    # while its lower foothill ridge stays tucked cleanly behind Layer 3's mountain ridge!
    y_dest_4 = raw_y_to_hd_y(y0_4 - 24)  # 403
    a4_norm = (pan4_a.astype(np.float32) / 255.0)[:, :, None]
    sky[y_dest_4 : y_dest_4 + h_hd_4] = (
        pan4_rgb.astype(np.float32) * a4_norm + sky[y_dest_4 : y_dest_4 + h_hd_4] * (1.0 - a4_norm)
    )
    sky[y_dest_4 + h_hd_4 :] = np.array([72.0, 98.0, 68.0])
    l4_img = Image.fromarray(
        np.dstack([np.clip(sky, 0, 255).astype(np.uint8), np.full((CANVAS_H, CANVAS_W), 255, dtype=np.uint8)])
    )

    # -------------------------------------------------------------------------
    # LAYER 3: Distant Misty Bicol Mountain Range
    # -------------------------------------------------------------------------
    print("2. Building HD Layer 3 (Distant Mountain Range)...")
    raw3 = Image.open(os.path.join(RAW_DIR, "media_1792846446686_4b80700b.png")).convert("RGBA")
    arr3 = np.array(raw3)
    rgb3 = arr3[:, :, :3].copy()
    alpha3 = arr3[:, :, 3].copy()
    # Extend the solid mountain base downward from y=245..268 so Layer 3 has deep coverage behind Layer 2
    for y_ext in range(246, 268):
        rgb3[y_ext] = rgb3[245]
        alpha3[y_ext] = 255
    alpha3[268:, :] = 0

    # Include 15px transparent headroom above y=135 so seam warping never clips a mountain peak!
    y0_3, y1_3 = 120, 268
    h_hd_3 = int(round((y1_3 - y0_3) * SCALE_HD))  # 278px
    pan3_rgb, pan3_a = make_seamless_horizon_tile(
        rgb3[y0_3:y1_3], alpha3[y0_3:y1_3], TILE_W, h_hd_3, erode_px=2, blend_raw_px=64
    )

    canvas3_rgb = np.zeros((CANVAS_H, CANVAS_W, 3), dtype=np.uint8)
    canvas3_a = np.zeros((CANVAS_H, CANVAS_W), dtype=np.uint8)
    # Shift Layer 3 up by 12 raw px so its misty ridges rise prominently between Layer 4 and Layer 2
    y_dest_3 = raw_y_to_hd_y(y0_3 - 12)
    canvas3_rgb[y_dest_3 : y_dest_3 + h_hd_3] = pan3_rgb
    canvas3_a[y_dest_3 : y_dest_3 + h_hd_3] = pan3_a
    l3_img = Image.fromarray(np.dstack([canvas3_rgb, canvas3_a]))

    # -------------------------------------------------------------------------
    # LAYER 2: Midground Rice Terraces, Bahay Kubo Huts & Coconut Palms
    # -------------------------------------------------------------------------
    print("3. Building HD Layer 2 (Midground Rice Terraces, Huts & Palms)...")
    raw2 = Image.open(os.path.join(RAW_DIR, "media_1792846446702_caf620ff.png")).convert("RGBA")
    arr2 = np.array(raw2)
    rgb2 = arr2[:, :, :3].astype(np.float32)
    max2 = rgb2.max(axis=2)

    fg2 = (max2 > 18) & (np.arange(raw2.height)[:, None] <= 289)
    fg2 = binary_fill_holes(fg2)
    core2 = binary_erosion(fg2, iterations=2)
    rgb2_int = inpaint_rgb_from_interior(rgb2, core2, smooth_sigma=0.5)
    int_max2 = np.maximum(rgb2_int.max(axis=2), 1.0)

    alpha2 = np.zeros((raw2.height, raw2.width), dtype=np.float32)
    alpha2[core2] = 255.0
    border2 = fg2 & (~core2)
    est_a2 = np.clip((max2[border2] - 12.0) / np.maximum(int_max2[border2] - 12.0, 10.0), 0.0, 1.0)
    alpha2[border2] = (est_a2 ** 0.85) * 255.0

    rgb2_clean = rgb2.copy()
    rgb2_clean[~core2] = rgb2_int[~core2]

    # Include 15px headroom above y=150 so seam warping never clips a hill peak
    y0_2, y1_2 = 135, 289
    h_hd_2 = int(round((y1_2 - y0_2) * SCALE_HD))  # 289px
    pan2_rgb, pan2_a = make_seamless_horizon_tile(
        np.clip(rgb2_clean[y0_2:y1_2], 0, 255).astype(np.uint8),
        alpha2[y0_2:y1_2],
        TILE_W,
        h_hd_2,
        erode_px=2,
        blend_raw_px=64,
    )

    canvas2_rgb = np.zeros((CANVAS_H, CANVAS_W, 3), dtype=np.uint8)
    canvas2_a = np.zeros((CANVAS_H, CANVAS_W), dtype=np.uint8)
    y_dest_2 = raw_y_to_hd_y(y0_2)
    canvas2_rgb[y_dest_2 : y_dest_2 + h_hd_2] = pan2_rgb
    canvas2_a[y_dest_2 : y_dest_2 + h_hd_2] = pan2_a
    l2_img = Image.fromarray(np.dstack([canvas2_rgb, canvas2_a]))

    # -------------------------------------------------------------------------
    # LAYER 1: Foreground Flooded Rice Paddies & Pilapil Stone/Grass Dikes
    # -------------------------------------------------------------------------
    print("4. Building HD Layer 1 (Foreground Flooded Paddies & Dikes)...")
    raw1 = Image.open(os.path.join(RAW_DIR, "media_1792846446682_96c8ab6c.png")).convert("RGBA")
    arr1 = np.array(raw1)
    rgb1 = arr1[:, :, :3]
    alpha1 = arr1[:, :, 3].copy()
    alpha1[296:, :] = 0

    y0_1, y1_1 = 210, 296
    h_hd_1 = int(round((y1_1 - y0_1) * SCALE_HD))  # 161px
    pan1_rgb, pan1_a = make_seamless_horizon_tile(
        rgb1[y0_1:y1_1], alpha1[y0_1:y1_1], TILE_W, h_hd_1, erode_px=2, blend_raw_px=64
    )

    canvas1_rgb = np.zeros((CANVAS_H, CANVAS_W, 3), dtype=np.uint8)
    canvas1_a = np.zeros((CANVAS_H, CANVAS_W), dtype=np.uint8)
    y_dest_1 = raw_y_to_hd_y(y0_1)
    canvas1_rgb[y_dest_1 : y_dest_1 + h_hd_1] = pan1_rgb
    canvas1_a[y_dest_1 : y_dest_1 + h_hd_1] = pan1_a

    bot_1 = y_dest_1 + h_hd_1 - 3
    rem_h = CANVAS_H - bot_1
    # Composite Layer 2 behind Layer 1 for the source strip so there are zero transparent black gaps
    a1_f = (canvas1_a.astype(np.float32) / 255.0)[:, :, None]
    comp12_rgb = canvas1_rgb.astype(np.float32) * a1_f + canvas2_rgb.astype(np.float32) * (1.0 - a1_f)
    bank_src = np.clip(comp12_rgb[bot_1 - 110 : bot_1, :][::-1], 0, 255).astype(np.uint8)
    src_strip = cv2.resize(bank_src, (CANVAS_W, rem_h), interpolation=cv2.INTER_LANCZOS4).astype(np.float32)
    # Add subtle horizontal water ripple distortion & darkening gradient
    for ry in range(rem_h):
        shift_x = int(round(2.5 * math.sin(ry * 0.35)))
        src_strip[ry] = np.roll(src_strip[ry], shift_x, axis=0)
    fade_y = np.linspace(0.55, 0.18, rem_h, dtype=np.float32)[:, None, None]
    soil_tint = np.array([34.0, 32.0, 24.0], dtype=np.float32)[None, None, :]
    submerged = np.clip(src_strip * fade_y + soil_tint * (1.0 - fade_y), 0, 255).astype(np.uint8)
    canvas1_rgb[bot_1:, :] = submerged
    canvas1_a[bot_1:, :] = 255
    l1_img = Image.fromarray(np.dstack([canvas1_rgb, canvas1_a]))

    # Save production PNGs
    l4_img.save(os.path.join(OUT_DIR, "Rice_Field_Layer4.png"))
    l3_img.save(os.path.join(OUT_DIR, "Rice_Field_Layer3.png"))
    l2_img.save(os.path.join(OUT_DIR, "Rice_Field_Layer2.png"))
    l1_img.save(os.path.join(OUT_DIR, "Rice_Field_Layer1.png"))

    # Save 1080p full-screen composite and seam verification
    comp_full = Image.new("RGBA", (CANVAS_W, CANVAS_H), (0, 0, 0, 255))
    comp_full.alpha_composite(l4_img)
    comp_full.alpha_composite(l3_img)
    comp_full.alpha_composite(l2_img)
    comp_full.alpha_composite(l1_img)

    comp_full.crop((0, 0, TILE_W, CANVAS_H)).save("scratch/hd_unzoomed_composite_1080p.png")
    comp_full.crop((TILE_W - 480, 0, TILE_W + 480, CANVAS_H)).save("scratch/hd_seam_verification.png")
    comp_full.crop((900, 340, 1700, 900)).save("scratch/crop_1080p_detail.png")
    print("All 4 HD layers saved and verified!")


if __name__ == "__main__":
    build_all_hd_layers()
