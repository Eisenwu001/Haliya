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

width = 2160
height = 720
center_x = 1080.0
crater_y = 92.0
crater_hw = 44.0

x = np.arange(width, dtype=np.float32)
dx = np.abs(x - center_x)

# Iconic Mayon Profile
in_crater = dx <= crater_hw
cone_sky = np.zeros(width, dtype=np.float32)
# Summit crater caldera
cone_sky[in_crater] = crater_y + 11.0 * (1.0 - (dx[in_crater] / crater_hw)**2)
flank_dx = dx[~in_crater] - crater_hw
cone_sky[~in_crater] = crater_y + 510.0 * np.power(flank_dx / 750.0, 1.34)

# Flanking mountain ranges (rocky peaks matching orig style, seamless wrap)
theta = 2.0 * math.pi * x / width
flanks_sky = (
    430.0 
    + 52.0 * np.cos(theta * 2.0 - 0.4) 
    + 28.0 * np.sin(theta * 4.0 + 0.6) 
    + 16.0 * np.cos(theta * 6.0 - 0.3) 
    + 8.0 * np.sin(theta * 8.0)
)
# Add rocky sharp crags to flanking mountains
rocky_crags = 14.0 * np.abs(np.sin(x * 0.045 + 0.3)) - 8.0 * np.abs(np.cos(x * 0.08))
flanks_sky += rocky_crags

# Blend Mayon cone and flanking mountains
bw = np.clip(1.0 - (dx - 450.0) / 360.0, 0.0, 1.0)
bw = 0.5 * (1.0 + np.cos(math.pi * (1.0 - bw)))
skyline = cone_sky * bw + flanks_sky * (1.0 - bw)

# Subtle rock roughness along the cone (crater rim preserved)
cone_rough = 2.2 * np.sin(x * 0.12) + 1.2 * np.cos(x * 0.28)
skyline += cone_rough * np.clip(dx / 90.0, 0.15, 1.0) * bw

# 2D Heightfield / depth
y_grid = np.arange(height)[:, None]
depth = y_grid - skyline[None, :]
in_mountain = depth >= 0

# Multi-octave rock fractal noise
rock_macro = make_fractal_noise(width, height, base_scale=140, octaves=5, persistence=0.55, seed=12)
rock_med = make_fractal_noise(width, height, base_scale=48, octaves=4, persistence=0.52, seed=34)
rock_fine = make_fractal_noise(width, height, base_scale=16, octaves=3, persistence=0.50, seed=56)

# Directional lighting: Sun from upper-left
# 1. Left vs Right slope of Mayon
dir_slope = - (x[None, :] - center_x) / 780.0
# 2. Rock facet texture from noise gradients
dNx = (rock_med[:, 2:] - rock_med[:, :-2]) * 0.5
dNy = (rock_med[2:, :] - rock_med[:-2, :]) * 0.5
rock_facets = np.zeros((height, width), dtype=np.float32)
rock_facets[1:-1, 1:-1] = - dNx[1:-1, :] * 1.8 - dNy[:, 1:-1] * 1.2

# Elevation down cone
elev_t = np.clip((y_grid - crater_y) / 470.0, 0.0, 1.0)
cone_presence = np.clip(1.0 - dx[None, :] / 820.0, 0.0, 1.0)

# Total illumination
light = 0.52 + 0.32 * dir_slope + 0.18 * rock_facets + 0.12 * (rock_fine - 0.5)
light = np.clip(light, 0.10, 0.98)

# Palette: Real Volcanic Basalt Slate Gray & Charcoal
# Sunlit rock: cool basalt slate gray [128, 140, 156]
# Midtone rock: charcoal basalt [75, 84, 96]
# Shadowed crevice: dark obsidian [32, 36, 44]
r_rock = 30.0 + light * 100.0
g_rock = 34.0 + light * 108.0
b_rock = 42.0 + light * 118.0

# Mid-lower mountain vegetation: subtle dark moss & montane forest in lower ravines
veg_t = np.clip((elev_t - 0.40) / 0.45, 0.0, 1.0) * cone_presence
r_veg = 24.0 + light * 45.0
g_veg = 46.0 + light * 68.0
b_veg = 32.0 + light * 46.0

r_cone = r_rock * (1.0 - veg_t * 0.35) + r_veg * (veg_t * 0.35)
g_cone = g_rock * (1.0 - veg_t * 0.35) + g_veg * (veg_t * 0.35)
b_cone = b_rock * (1.0 - veg_t * 0.35) + b_veg * (veg_t * 0.35)

# Flanking mountain range: atmospheric blue-slate ridges
r_flank = 40.0 + light * 55.0
g_flank = 52.0 + light * 68.0
b_flank = 70.0 + light * 82.0

r_final = r_cone * cone_presence + r_flank * (1.0 - cone_presence)
g_final = g_cone * cone_presence + g_flank * (1.0 - cone_presence)
b_final = b_cone * cone_presence + b_flank * (1.0 - cone_presence)

# Atmospheric base haze
base_haze = np.clip((y_grid - 490.0) / 230.0, 0.0, 1.0)
haze_col = np.array([62.0, 88.0, 115.0])
r_final = r_final * (1.0 - base_haze * 0.38) + haze_col[0] * (base_haze * 0.38)
g_final = g_final * (1.0 - base_haze * 0.38) + haze_col[1] * (base_haze * 0.38)
b_final = b_final * (1.0 - base_haze * 0.38) + haze_col[2] * (base_haze * 0.38)

# Summit crater caldera: dark inner rock cavity + subtle sulfur warmth
c_dist_x = np.abs(x[None, :] - center_x)
c_dist_y = y_grid - crater_y
in_crater_lip = (c_dist_x < crater_hw * 0.85) & (c_dist_y >= 0) & (c_dist_y < 24.0)
if np.any(in_crater_lip):
    c_lip_t = np.clip(1.0 - c_dist_x / (crater_hw * 0.85), 0.0, 1.0) * in_crater_lip
    r_final[in_crater_lip] = r_final[in_crater_lip] * 0.5 + 160.0 * c_lip_t[in_crater_lip] * 0.35
    g_final[in_crater_lip] = g_final[in_crater_lip] * 0.5 + 95.0 * c_lip_t[in_crater_lip] * 0.35
    b_final[in_crater_lip] = b_final[in_crater_lip] * 0.5 + 40.0 * c_lip_t[in_crater_lip] * 0.35

rgba = np.zeros((height, width, 4), dtype=np.uint8)
rgba[in_mountain, 0] = np.clip(r_final[in_mountain], 0, 255).astype(np.uint8)
rgba[in_mountain, 1] = np.clip(g_final[in_mountain], 0, 255).astype(np.uint8)
rgba[in_mountain, 2] = np.clip(b_final[in_mountain], 0, 255).astype(np.uint8)
rgba[in_mountain, 3] = 255

# Volumetric White-Gray Steam & Ash Plume
smoke = np.zeros((height, width, 4), dtype=np.float32)
smoke_noise = make_fractal_noise(width, height, base_scale=28, octaves=4, seed=555)

puffs = [
    # (dy, dx, rad, dense)
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
            cr = 160.0 + cl * 95.0
            cg = 170.0 + cl * 85.0
            cb = 185.0 + cl * 70.0
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
res.save('scratch/mayon_master_full.png')
res.thumbnail((540, 180))
res.save('scratch/mayon_master_thumb.png')
print('Mayon master saved')
