"""
Generate all 4 Rice Field parallax background layers to perfectly match the user-provided
Layer 1 style (pixel art, warm daylight, rich material colors, authentic Mount Mayon).
"""
import math
import numpy as np
from PIL import Image, ImageFilter

def make_fractal_noise(width, height, base_scale=64, octaves=5, persistence=0.5, seed=42):
    np.random.seed(seed)
    noise = np.zeros((height, width), dtype=np.float32)
    amp = 1.0
    total_amp = 0.0
    for o in range(octaves):
        s = max(2, int(base_scale / (2 ** o)))
        gh = (height // s) + 3
        gw = (width // s) + 3
        rand_grid = np.random.rand(gh, gw).astype(np.float32)
        y_indices = np.linspace(0, gh - 2, height)
        x_indices = np.linspace(0, gw - 2, width)
        y0 = np.floor(y_indices).astype(int)
        y1 = y0 + 1
        x0 = np.floor(x_indices).astype(int)
        x1 = x0 + 1
        fy = (y_indices - y0)[:, None]
        fx = (x_indices - x0)[None, :]
        fy = fy * fy * (3.0 - 2.0 * fy)
        fx = fx * fx * (3.0 - 2.0 * fx)
        top = rand_grid[y0[:, None], x0[None, :]] * (1.0 - fx) + rand_grid[y0[:, None], x1[None, :]] * fx
        bot = rand_grid[y1[:, None], x0[None, :]] * (1.0 - fx) + rand_grid[y1[:, None], x1[None, :]] * fx
        noise += (top * (1.0 - fy) + bot * fy) * amp
        total_amp += amp
        amp *= persistence
    return noise / total_amp

def seamless_blend(arr, width, blend_width=32):
    """Smooth cosine ease-blend on the right border to match left border."""
    for i in range(blend_width):
        t = float(i + 1) / float(blend_width)
        w = 0.5 * (1.0 - math.cos(math.pi * t))
        arr[:, width - blend_width + i] = (1.0 - w) * arr[:, width - blend_width + i] + w * arr[:, i]
    return arr

def build_layer1():
    print("Building Layer 1 from user image...")
    src_path = r"C:\Users\Lin\.gemini\antigravity\brain\92bde1ae-ac0c-4d62-8cfc-e89de1ad59d2\.user_uploaded\media_1791088885584.png"
    img = Image.open(src_path).convert('RGB')
    arr = np.array(img, dtype=float)
    H, W, _ = arr.shape

    # 1. Clean transparency extraction
    max_val = np.max(arr, axis=2)
    alpha = np.clip((max_val - 3.0) / (18.0 - 3.0), 0.0, 1.0)

    # Defringe / unpremultiply black background
    rgb = np.zeros_like(arr)
    for c in range(3):
        rgb[:, :, c] = np.where(alpha > 0.05, np.clip(arr[:, :, c] / np.maximum(alpha, 0.2), 0, 255), 0)

    rgba = np.dstack([rgb, alpha * 255.0])

    # 2. Perfect seamless looping on the edges:
    # Right edge banana leaf connects to left edge banana leaf:
    for i in range(8):
        x = W - 8 + i
        target_y_max = int(212 + (i + 1) * (219 - 212) / 8.0)
        for y in range(212, target_y_max + 1):
            rgba[y, x] = rgba[y, 0]

    # Ground & dirt seamless blend (y >= 290) across border
    for i in range(6):
        x = W - 6 + i
        t = float(i + 1) / 7.0
        for y in range(290, H):
            rgba[y, x] = (1.0 - t) * rgba[y, x] + t * rgba[y, 0]

    # Resize to 2160x720 using LANCZOS for high-DPI crisp pixel art
    out_img = Image.fromarray(rgba.astype(np.uint8)).resize((2160, 720), Image.Resampling.LANCZOS)
    out_img.save("assets/bicol_bg/Rice_Field_Layer1.png")
    print("  -> assets/bicol_bg/Rice_Field_Layer1.png saved!")

def build_layer2():
    print("Building Layer 2 (Midground Terraces & Farmsteads)...")
    W, H = 2160, 720
    orig2 = Image.open("assets/bicol_bg/Rice_Field_Layer2_orig.png").resize((W, H), Image.Resampling.LANCZOS)
    arr = np.array(orig2, dtype=float)
    lum = (0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2])
    alpha = arr[:, :, 3]

    # Layer 1 Palette Profiles
    # Thatch roof
    thatch_high = np.array([220.0, 160.0, 95.0])
    thatch_mid = np.array([175.0, 125.0, 65.0])
    thatch_shadow = np.array([85.0, 58.0, 35.0])

    # Woven bamboo walls
    bamboo_high = np.array([190.0, 135.0, 75.0])
    bamboo_mid = np.array([145.0, 100.0, 55.0])
    bamboo_shadow = np.array([75.0, 50.0, 32.0])

    # Timber stilts & beams
    timber_high = np.array([70.0, 50.0, 35.0])
    timber_shadow = np.array([32.0, 24.0, 16.0])

    # Base background hills palette (warm tropical green matching Layer 1)
    hill_dark = np.array([32.0, 60.0, 28.0])   # deep shade
    hill_mid = np.array([58.0, 102.0, 48.0])   # midtone green
    hill_high = np.array([92.0, 142.0, 60.0])  # sunlit green

    # Lower terraces & water reflections
    water_mid = np.array([135.0, 185.0, 210.0])  # bright surface
    water_sheen = np.array([175.0, 218.0, 235.0])# sun glint

    # Dikes and soil
    soil_dark = np.array([42.0, 28.0, 18.0])   # dark volcanic earth
    soil_mid = np.array([68.0, 48.0, 32.0])    # loam
    grass_edge = np.array([88.0, 135.0, 52.0]) # fresh grass on dikes

    l3 = lum[:, :, None] / 255.0
    paddy_weight = np.clip((np.arange(H)[:, None, None] - 440.0) / 70.0, 0.0, 1.0)

    # Base hill coloring
    hill_col = np.where(
        l3 < 0.5,
        hill_dark + (l3 / 0.5) * (hill_mid - hill_dark),
        hill_mid + ((l3 - 0.5) / 0.5) * (hill_high - hill_mid)
    )

    # Terrace water / dikes
    water_t = np.clip((l3 - 0.48) / 0.40, 0.0, 1.0)
    water_col = water_mid + water_t * (water_sheen - water_mid)

    dike_t = np.clip(l3 / 0.48, 0.0, 1.0)
    dike_col = np.where(
        dike_t < 0.5,
        soil_dark + (dike_t / 0.5) * (soil_mid - soil_dark),
        soil_mid + ((dike_t - 0.5) / 0.5) * (grass_edge - soil_mid)
    )
    terrace_col = np.where(l3 > 0.48, water_col, dike_col)

    # Blend hills and terraces
    out_rgb = (1.0 - paddy_weight) * hill_col + paddy_weight * terrace_col

    # Rice seedling sprouts in flooded paddies
    np.random.seed(42)
    paddy_water_mask = (paddy_weight[:, 0, 0, None] > 0.6) & (l3[:, :, 0] > 0.50) & (alpha > 50)
    seedling_noise = np.random.rand(H, W)
    seedling_mask = paddy_water_mask & (seedling_noise > 0.88)
    out_rgb[seedling_mask] = np.array([115.0, 168.0, 52.0])

    # Palms: rich tropical palm green
    palm_clusters = [
        (0, 280, 210, 450),
        (1080, 1260, 240, 420),
        (1400, 1620, 240, 365),
        (1940, 2160, 210, 450),
    ]
    for x0, x1, y0, y1 in palm_clusters:
        p_mask = np.zeros((H, W), dtype=bool)
        p_mask[y0:y1, x0:x1] = (alpha[y0:y1, x0:x1] > 100) & (lum[y0:y1, x0:x1] < 112)
        l_p = np.clip(lum[p_mask, None] / 120.0, 0.0, 1.0)
        p_col = np.where(
            l_p < 0.45,
            np.array([22.0, 42.0, 18.0]) + (l_p / 0.45) * (np.array([55.0, 95.0, 42.0]) - np.array([22.0, 42.0, 18.0])),
            np.array([55.0, 95.0, 42.0]) + ((l_p - 0.45) / 0.55) * (np.array([125.0, 175.0, 58.0]) - np.array([55.0, 95.0, 42.0]))
        )
        out_rgb[p_mask] = p_col

    # Coordinate grids
    ys_grid = np.arange(H)[:, None]
    xs_grid = np.arange(W)[None, :]

    # Exact hut segmentation (no rectangular bounding box artifacts)
    # Group 1:
    h1_roof = (xs_grid >= 208) & (xs_grid < 395) & (ys_grid >= 350) & (ys_grid <= 415) & (lum < 105)
    h1_wall = (xs_grid >= 225) & (xs_grid < 335) & (ys_grid > 415) & (ys_grid <= 440) & (lum < 108)
    h1_porch = (xs_grid >= 335) & (xs_grid < 390) & (ys_grid > 415) & (ys_grid <= 440) & (lum < 95)
    h1_stilt = (xs_grid >= 225) & (xs_grid < 390) & (ys_grid > 440) & (ys_grid <= 462) & (lum < 92)

    h2_roof = (xs_grid >= 395) & (xs_grid <= 468) & (ys_grid >= 380) & (ys_grid <= 430) & (lum < 105)
    h2_wall = (xs_grid >= 405) & (xs_grid <= 465) & (ys_grid > 430) & (ys_grid <= 445) & (lum < 108)
    h2_stilt = (xs_grid >= 405) & (xs_grid <= 465) & (ys_grid > 445) & (ys_grid <= 460) & (lum < 92)

    # Group 2:
    h3_roof = (xs_grid >= 1180) & (xs_grid < 1270) & (ys_grid >= 380) & (ys_grid <= 425) & (lum < 105)
    h3_wall = (xs_grid >= 1185) & (xs_grid < 1270) & (ys_grid > 425) & (ys_grid <= 445) & (lum < 108)
    h3_stilt = (xs_grid >= 1185) & (xs_grid < 1270) & (ys_grid > 445) & (ys_grid <= 460) & (lum < 92)

    h4_roof = (xs_grid >= 1270) & (xs_grid < 1400) & (ys_grid >= 365) & (ys_grid <= 415) & (lum < 105)
    h4_wall = (xs_grid >= 1285) & (xs_grid < 1400) & (ys_grid > 415) & (ys_grid <= 445) & (lum < 108)
    h4_stilt = (xs_grid >= 1285) & (xs_grid < 1400) & (ys_grid > 445) & (ys_grid <= 460) & (lum < 92)

    h5_roof = (xs_grid >= 1400) & (xs_grid <= 1485) & (ys_grid >= 365) & (ys_grid <= 412) & (lum < 105)
    h5_wall = (xs_grid >= 1410) & (xs_grid <= 1475) & (ys_grid > 412) & (ys_grid <= 445) & (lum < 108)
    h5_stilt = (xs_grid >= 1410) & (xs_grid <= 1475) & (ys_grid > 445) & (ys_grid <= 460) & (lum < 92)

    # Group 3:
    h6_roof = (xs_grid >= 1630) & (xs_grid < 1765) & (ys_grid >= 380) & (ys_grid <= 412) & (lum < 105)
    h6_wall = (xs_grid >= 1650) & (xs_grid < 1750) & (ys_grid > 412) & (ys_grid <= 445) & (lum < 108)
    h6_stilt = (xs_grid >= 1650) & (xs_grid < 1750) & (ys_grid > 445) & (ys_grid <= 460) & (lum < 92)

    h7_roof = (xs_grid >= 1765) & (xs_grid <= 1945) & (ys_grid >= 335) & (ys_grid <= 405) & (lum < 105)
    h7_wall = (xs_grid >= 1790) & (xs_grid < 1880) & (ys_grid > 405) & (ys_grid <= 442) & (lum < 108)
    h7_porch = (xs_grid >= 1880) & (xs_grid <= 1935) & (ys_grid > 405) & (ys_grid <= 442) & (lum < 95)
    h7_stilt = (xs_grid >= 1790) & (xs_grid <= 1935) & (ys_grid > 442) & (ys_grid <= 458) & (lum < 92)

    all_elements = [
        (h1_roof, True, False), (h1_wall, False, True), (h1_porch, False, False), (h1_stilt, False, False),
        (h2_roof, True, False), (h2_wall, False, True), (h2_stilt, False, False),
        (h3_roof, True, False), (h3_wall, False, True), (h3_stilt, False, False),
        (h4_roof, True, False), (h4_wall, False, True), (h4_stilt, False, False),
        (h5_roof, True, False), (h5_wall, False, True), (h5_stilt, False, False),
        (h6_roof, True, False), (h6_wall, False, True), (h6_stilt, False, False),
        (h7_roof, True, False), (h7_wall, False, True), (h7_porch, False, False), (h7_stilt, False, False),
    ]

    for mask, is_r, is_w in all_elements:
        sub_l = np.clip((lum[mask, None] - 50.0) / (110.0 - 50.0), 0.0, 1.0)
        if is_r:
            col = np.where(sub_l < 0.5, thatch_shadow + (sub_l / 0.5) * (thatch_mid - thatch_shadow), thatch_mid + ((sub_l - 0.5) / 0.5) * (thatch_high - thatch_mid))
        elif is_w:
            col = np.where(sub_l < 0.4, bamboo_shadow + (sub_l / 0.4) * (bamboo_mid - bamboo_shadow), bamboo_mid + ((sub_l - 0.4) / 0.6) * (bamboo_high - bamboo_mid))
        else:
            col = timber_shadow + sub_l * (timber_high - timber_shadow)
        out_rgb[mask] = col

    # Seamless horizontal wrap
    out_rgb = seamless_blend(out_rgb, W, blend_width=32)
    alpha = seamless_blend(alpha, W, blend_width=32)

    out_rgba = np.dstack([np.clip(out_rgb, 0, 255), alpha]).astype(np.uint8)
    Image.fromarray(out_rgba).save("assets/bicol_bg/Rice_Field_Layer2.png")
    print("  -> assets/bicol_bg/Rice_Field_Layer2.png saved!")

def build_layer3():
    print("Building Layer 3 (Distant Mountain Ridges & Terraces)...")
    W, H = 2160, 720
    orig3 = Image.open("assets/bicol_bg/Rice_Field_Layer3_orig.png").resize((W, H), Image.Resampling.LANCZOS)
    arr = np.array(orig3, dtype=float)
    alpha = arr[:, :, 3]
    lum = (0.299 * arr[:, :, 0] + 0.587 * arr[:, :, 1] + 0.114 * arr[:, :, 2]) / 255.0

    # Layer 3: distant rolling mountains with agricultural terraces
    # Atmospheric perspective: soft lush mountain teal-greens with morning sunlight
    dist_dark = np.array([42.0, 78.0, 68.0])     # deep atmospheric mountain green
    dist_mid = np.array([68.0, 115.0, 98.0])    # sunlit mountain slope
    dist_high = np.array([115.0, 168.0, 142.0]) # terrace crests & sunlit rims
    valley_mist = np.array([195.0, 225.0, 230.0])# soft warm morning valley haze

    l3 = lum[:, :, None]
    l3_col = np.where(
        l3 < 0.45,
        dist_dark + (l3 / 0.45) * (dist_mid - dist_dark),
        dist_mid + ((l3 - 0.45) / 0.55) * (dist_high - dist_mid)
    )

    # Valley mist pooling at lower elevations (y > 450)
    mist_amount = np.clip((np.arange(H)[:, None, None] - 460.0) / 220.0, 0.0, 0.45)
    l3_col = (1.0 - mist_amount) * l3_col + mist_amount * valley_mist

    # Seamless horizontal wrap
    l3_col = seamless_blend(l3_col, W, blend_width=32)
    alpha = seamless_blend(alpha, W, blend_width=32)

    out_rgba = np.dstack([np.clip(l3_col, 0, 255), alpha]).astype(np.uint8)
    Image.fromarray(out_rgba).save("assets/bicol_bg/Rice_Field_Layer3.png")
    print("  -> assets/bicol_bg/Rice_Field_Layer3.png saved!")

def build_layer4():
    print("Building Layer 4 (Mount Mayon & Distant Horizon)...")
    width = 2160
    height = 720
    center_x = 1080.0
    crater_y = 92.0
    crater_hw = 44.0

    x = np.arange(width, dtype=np.float32)
    dx = np.abs(x - center_x)

    in_crater = dx <= crater_hw
    cone_sky = np.zeros(width, dtype=np.float32)
    cone_sky[in_crater] = crater_y + 11.0 * (1.0 - (dx[in_crater] / crater_hw)**2)
    flank_dx = dx[~in_crater] - crater_hw
    cone_sky[~in_crater] = crater_y + 510.0 * np.power(flank_dx / 750.0, 1.34)

    # Flanking mountain ranges (strictly periodic harmonics for 100% seamless wrap)
    theta = 2.0 * math.pi * x / width
    flanks_sky = (
        430.0 
        + 52.0 * np.cos(theta * 2.0 - 0.4) 
        + 28.0 * np.sin(theta * 4.0 + 0.6) 
        + 16.0 * np.cos(theta * 6.0 - 0.3) 
        + 8.0 * np.sin(theta * 8.0)
        + 12.0 * np.abs(np.sin(theta * 16.0 + 0.3))
        - 6.0 * np.abs(np.cos(theta * 32.0))
    )

    # Blend Mayon cone and flanking mountains
    bw = np.clip(1.0 - (dx - 450.0) / 360.0, 0.0, 1.0)
    bw = 0.5 * (1.0 + np.cos(math.pi * (1.0 - bw)))
    skyline = cone_sky * bw + flanks_sky * (1.0 - bw)

    # Subtle rock crags on cone
    cone_rough = 2.2 * np.sin(theta * 40.0) + 1.2 * np.cos(theta * 80.0)
    skyline += cone_rough * np.clip(dx / 90.0, 0.15, 1.0) * bw

    # Smooth seam on skyline directly so terrain height matches at borders
    for i in range(16):
        t = float(i + 1) / 17.0
        skyline[width - 16 + i] = (1.0 - t) * skyline[width - 16 + i] + t * skyline[i]

    y_grid = np.arange(height)[:, None]
    depth = y_grid - skyline[None, :]
    in_mountain = depth >= 0

    # Multi-octave 2D fractal noise (NO radial bicycle spokes!)
    rock_macro = make_fractal_noise(width, height, base_scale=140, octaves=5, persistence=0.55, seed=12)
    rock_med = make_fractal_noise(width, height, base_scale=48, octaves=4, persistence=0.52, seed=34)
    rock_fine = make_fractal_noise(width, height, base_scale=16, octaves=3, persistence=0.50, seed=56)

    # Directional surface normal lighting: Sun from upper-left
    dir_slope = - (x[None, :] - center_x) / 780.0
    dNx = (rock_med[:, 2:] - rock_med[:, :-2]) * 0.5
    dNy = (rock_med[2:, :] - rock_med[:-2, :]) * 0.5
    rock_facets = np.zeros((height, width), dtype=np.float32)
    rock_facets[1:-1, 1:-1] = - dNx[1:-1, :] * 1.8 - dNy[:, 1:-1] * 1.2

    elev_t = np.clip((y_grid - crater_y) / 470.0, 0.0, 1.0)
    cone_presence = np.clip(1.0 - dx[None, :] / 820.0, 0.0, 1.0)

    light = 0.52 + 0.32 * dir_slope + 0.18 * rock_facets + 0.12 * (rock_fine - 0.5)
    light = np.clip(light, 0.10, 0.98)

    # 1. Volcanic Basalt Rock Palette (Upper Peak & Ridges)
    r_rock = 35.0 + light * 80.0
    g_rock = 40.0 + light * 85.0
    b_rock = 50.0 + light * 92.0

    # 2. Lush Tropical Forest Mantle (Lower Slopes & Ravines)
    r_veg = 25.0 + light * 70.0
    g_veg = 45.0 + light * 105.0
    b_veg = 22.0 + light * 43.0

    # Transition from upper volcanic rock to lush tropical forest on lower slopes:
    forest_t = np.clip((elev_t - 0.32) / 0.38, 0.0, 1.0)
    timberline_noise = rock_macro * 0.25 + rock_med * 0.15 - 0.20
    forest_t = np.clip(forest_t + timberline_noise, 0.0, 1.0) * cone_presence

    r_cone = r_rock * (1.0 - forest_t) + r_veg * forest_t
    g_cone = g_rock * (1.0 - forest_t) + g_veg * forest_t
    b_cone = b_rock * (1.0 - forest_t) + b_veg * forest_t

    # 3. Flanking Mountain Ranges (Atmospheric slate-green ridges)
    r_flank = 40.0 + light * 45.0
    g_flank = 58.0 + light * 62.0
    b_flank = 68.0 + light * 68.0

    r_final = r_cone * cone_presence + r_flank * (1.0 - cone_presence)
    g_final = g_cone * cone_presence + g_flank * (1.0 - cone_presence)
    b_final = b_cone * cone_presence + b_flank * (1.0 - cone_presence)

    # Atmospheric valley haze at base
    base_haze = np.clip((y_grid - 500.0) / 220.0, 0.0, 1.0)
    haze_col = np.array([75.0, 105.0, 125.0])
    r_final = r_final * (1.0 - base_haze * 0.35) + haze_col[0] * (base_haze * 0.35)
    g_final = g_final * (1.0 - base_haze * 0.35) + haze_col[1] * (base_haze * 0.35)
    b_final = b_final * (1.0 - base_haze * 0.35) + haze_col[2] * (base_haze * 0.35)

    # Summit crater caldera: dark inner cavity + subtle sulfur glow
    c_dist_x = np.abs(x[None, :] - center_x)
    c_dist_y = y_grid - crater_y
    in_crater_lip = (c_dist_x < crater_hw * 0.85) & (c_dist_y >= 0) & (c_dist_y < 24.0)
    if np.any(in_crater_lip):
        c_lip_t = np.clip(1.0 - c_dist_x / (crater_hw * 0.85), 0.0, 1.0) * in_crater_lip
        r_final[in_crater_lip] = r_final[in_crater_lip] * 0.5 + 170.0 * c_lip_t[in_crater_lip] * 0.35
        g_final[in_crater_lip] = g_final[in_crater_lip] * 0.5 + 105.0 * c_lip_t[in_crater_lip] * 0.35
        b_final[in_crater_lip] = b_final[in_crater_lip] * 0.5 + 45.0 * c_lip_t[in_crater_lip] * 0.35

    rgba = np.zeros((height, width, 4), dtype=np.uint8)
    rgba[in_mountain, 0] = np.clip(r_final[in_mountain], 0, 255).astype(np.uint8)
    rgba[in_mountain, 1] = np.clip(g_final[in_mountain], 0, 255).astype(np.uint8)
    rgba[in_mountain, 2] = np.clip(b_final[in_mountain], 0, 255).astype(np.uint8)
    rgba[in_mountain, 3] = 255

    # Volumetric Steam Plume at summit
    smoke = np.zeros((height, width, 4), dtype=np.float32)
    smoke_noise = make_fractal_noise(width, height, base_scale=28, octaves=4, seed=555)

    puffs = [
        (5.0, 2.0, 22.0, 0.88),
        (16.0, 10.0, 30.0, 0.82),
        (30.0, 22.0, 40.0, 0.76),
        (46.0, 38.0, 52.0, 0.68),
        (64.0, 60.0, 65.0, 0.58),
        (84.0, 88.0, 80.0, 0.45),
        (106.0, 122.0, 96.0, 0.32),
    ]

    for p_dy, p_dx, p_rad, p_dense in puffs:
        py = crater_y - p_dy
        px = center_x + p_dx
        ymin = max(0, int(py - p_rad * 1.3))
        ymax = min(height - 1, int(py + p_rad * 1.3))
        xmin = max(0, int(px - p_rad * 1.6))
        xmax = min(width - 1, int(px + p_rad * 1.6))
        for sy in range(ymin, ymax + 1):
            for sx in range(xmin, xmax + 1):
                ddx = (sx - px) / 1.3
                ddy = (sy - py)
                dist = math.sqrt(ddx*ddx + ddy*ddy)
                if dist > p_rad:
                    continue
                n = smoke_noise[sy, sx]
                edge = dist / p_rad + (n - 0.5) * 0.35
                if edge > 1.0:
                    continue
                val = math.exp(-2.4 * edge**2) * p_dense
                norm_lx = - ddx / p_rad
                norm_ly = - ddy / p_rad
                cl = np.clip(0.52 + 0.35 * norm_lx + 0.22 * norm_ly + 0.15 * (n - 0.5), 0.2, 1.0)
                cr = 180.0 + cl * 75.0
                cg = 190.0 + cl * 65.0
                cb = 200.0 + cl * 55.0
                cur_a = smoke[sy, sx, 3] / 255.0
                add_a = val * (1.0 - cur_a)
                new_a = cur_a + add_a
                if new_a > 0.001:
                    smoke[sy, sx, 0] = (smoke[sy, sx, 0] * cur_a + cr * add_a) / new_a
                    smoke[sy, sx, 1] = (smoke[sy, sx, 1] * cur_a + cg * add_a) / new_a
                    smoke[sy, sx, 2] = (smoke[sy, sx, 2] * cur_a + cb * add_a) / new_a
                    smoke[sy, sx, 3] = min(255.0, new_a * 255.0)

    b_img = Image.fromarray(rgba, mode='RGBA')
    s_img = Image.fromarray(smoke.astype(np.uint8), mode='RGBA').filter(ImageFilter.GaussianBlur(1.2))
    res = Image.alpha_composite(b_img, s_img)

    # 100% seamless horizontal border wrapping of RGB only
    res_arr = np.array(res, dtype=float)
    for i in range(16):
        t = float(i + 1) / 17.0
        res_arr[:, width - 16 + i, :3] = (1.0 - t) * res_arr[:, width - 16 + i, :3] + t * res_arr[:, i, :3]

    final_mayon = Image.fromarray(np.clip(res_arr, 0, 255).astype(np.uint8))
    final_mayon.save("assets/bicol_bg/Rice_Field_Layer4.png")
    print("  -> assets/bicol_bg/Rice_Field_Layer4.png saved!")

if __name__ == "__main__":
    build_layer1()
    build_layer2()
    build_layer3()
    build_layer4()
    print("ALL 4 RICE FIELD LAYERS SUCCESSFULLY REBUILT!")
