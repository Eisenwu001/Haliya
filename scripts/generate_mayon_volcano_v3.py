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
        
        # Smoothstep interpolation
        fy = fy * fy * (3.0 - 2.0 * fy)
        fx = fx * fx * (3.0 - 2.0 * fx)
        
        top = rand_grid[y0[:, None], x0[None, :]] * (1.0 - fx) + rand_grid[y0[:, None], x1[None, :]] * fx
        bot = rand_grid[y1[:, None], x0[None, :]] * (1.0 - fx) + rand_grid[y1[:, None], x1[None, :]] * fx
        layer = top * (1.0 - fy) + bot * fy
        
        noise += layer * amp
        total_amp += amp
        amp *= persistence
        
    return noise / total_amp

def generate_mayon_volcano(out_path="assets/bicol_bg/Rice_Field_Layer4.png", thumb_path="scratch/mayon_v3_thumb.png"):
    width = 2160
    height = 720
    center_x = 1080.0
    crater_y = 88.0
    crater_hw = 48.0
    
    x = np.arange(width, dtype=np.float32)
    
    # 1. Iconic Mayon Cone Skyline
    dx = np.abs(x - center_x)
    cone_profile = np.zeros(width, dtype=np.float32)
    
    in_crater = dx <= crater_hw
    # Shallow crater depression at the summit
    cone_profile[in_crater] = crater_y + 12.0 * (1.0 - (dx[in_crater] / crater_hw)**2)
    
    # Famous Mayon parabolic concave curve
    flank_dx = dx[~in_crater] - crater_hw
    max_w = 720.0
    cone_profile[~in_crater] = crater_y + 500.0 * np.power(flank_dx / max_w, 1.35)
    
    # 2. Flanking mountain ranges (seamless horizontal wrap at x=0 and x=width)
    theta = 2.0 * math.pi * x / width
    flank_ranges = (
        390.0
        + 50.0 * np.cos(theta * 2.0 - 0.4)
        + 28.0 * np.sin(theta * 4.0 + 0.8)
        + 16.0 * np.cos(theta * 6.0)
        + 8.0 * np.sin(theta * 8.0)
    )
    
    # Smooth blend between Mayon cone and flanking ranges
    # Within dx < 500, Mayon dominates; dx 500..800 blends smoothly into flanking mountains
    mayon_weight = np.clip(1.0 - (dx - 480.0) / 320.0, 0.0, 1.0)
    # Cosine smoothing for seamless transition
    mayon_weight = 0.5 * (1.0 + np.cos(math.pi * (1.0 - mayon_weight)))
    
    skyline = cone_profile * mayon_weight + flank_ranges * (1.0 - mayon_weight)
    
    # Subtle organic roughness on ridgeline (suppressed at the iconic crater rim)
    ridge_noise = 2.0 * np.sin(x * 0.12) + 1.2 * np.cos(x * 0.28 + 0.5) + 0.8 * np.sin(x * 0.55)
    crater_protect = np.clip(dx / 100.0, 0.15, 1.0)
    skyline += ridge_noise * crater_protect
    
    # Precompute noise maps
    print("Generating procedural mountain textures...")
    macro_noise = make_fractal_noise(width, height, base_scale=128, octaves=4, persistence=0.5, seed=111)
    couloir_noise = make_fractal_noise(width, height, base_scale=48, octaves=4, persistence=0.5, seed=222)
    micro_noise = make_fractal_noise(width, height, base_scale=16, octaves=3, persistence=0.5, seed=333)
    
    rgba = np.zeros((height, width, 4), dtype=np.uint8)
    
    print("Shading terrain & volcanic features...")
    # Compute 2D height field / depth for normal estimation
    # Y down slope: depth = y - skyline[x]
    y_grid = np.arange(height)[:, None]
    depth = y_grid - skyline[None, :]
    in_mountain = depth >= 0
    
    # Compute volcanic slopes and radial erosion
    # Natural erosion couloirs: follow slope gradient down from crater
    rad_x = (x[None, :] - center_x) # shape (1, width)
    rad_y = np.maximum(10.0, y_grid - crater_y) # shape (height, 1)
    slope_angle = rad_x / (rad_y * 1.1 + 80.0) # radial angle down cone
    
    # Organic erosion gullies: modulated by noise so they look like real carved ravines
    gully_pattern = np.sin(slope_angle * 32.0 + couloir_noise * 4.0)
    gully_pattern = np.clip(gully_pattern * 1.5, -1.0, 1.0)
    
    # Directional twilight lighting:
    # Key light from upper left (moonlit cool slate/silver)
    # Slope direction factor: left side (dx < 0) receives primary light, right side in shadow
    left_light = - (x[None, :] - center_x) / 720.0 # positive on left, negative on right
    
    # Vertical slope factor (steeper near top = catch more sky light)
    vert_factor = np.clip(1.0 - (depth / 350.0), 0.0, 1.0)
    
    # Natural illumination value
    illum = (
        0.52 
        + 0.32 * left_light 
        + 0.14 * gully_pattern 
        + 0.18 * (couloir_noise - 0.5) 
        + 0.10 * (micro_noise - 0.5)
        + 0.08 * vert_factor
    )
    illum = np.clip(illum, 0.10, 0.95)
    
    # Elevation factor along mountain:
    # 0.0 = high alpine peak / summit basalt
    # 0.5 = mid montane forest
    # 1.0 = lowland jungle / foothills
    elev_t = np.clip((y_grid - crater_y) / 450.0, 0.0, 1.0)
    # Distance from center for Mayon presence
    cone_dist_t = np.clip(np.abs(x[None, :] - center_x) / 680.0, 0.0, 1.0)
    
    # Define Palette (Dark Fantasy Twilight Philippines)
    # 1. Volcanic Summit (Obsidian ash & twilight basalt):
    # Lit: #4d5b78 (77, 91, 120) | Mid: #313a4f (49, 58, 79) | Shadow: #1d2332 (29, 35, 50)
    r_summit = 28.0 + illum * 52.0
    g_summit = 34.0 + illum * 60.0
    b_summit = 48.0 + illum * 76.0
    
    # 2. Mid Montane Forest (Lush dark emerald slopes):
    # Lit: #347055 (52, 112, 85) | Mid: #224a38 (34, 74, 56) | Shadow: #142e23 (20, 46, 35)
    r_forest = 18.0 + illum * 36.0
    g_forest = 42.0 + illum * 74.0
    b_forest = 32.0 + illum * 56.0
    
    # 3. Flanking Mountain Ranges (Atmospheric twilight ridges):
    # Lit: #3c4c68 (60, 76, 104) | Mid: #273347 (39, 51, 71) | Shadow: #18202d (24, 32, 45)
    r_flank = 22.0 + illum * 40.0
    g_flank = 30.0 + illum * 48.0
    b_flank = 44.0 + illum * 64.0
    
    # Seamless transition:
    # Upper cone is summit basalt (elev_t < 0.25)
    # Transition to forest between elev_t 0.25 and 0.65
    forest_blend = np.clip((elev_t - 0.25) / 0.40, 0.0, 1.0)
    # Smoothstep
    forest_blend = forest_blend * forest_blend * (3.0 - 2.0 * forest_blend)
    
    r_cone = r_summit * (1.0 - forest_blend) + r_forest * forest_blend
    g_cone = g_summit * (1.0 - forest_blend) + g_forest * forest_blend
    b_cone = b_summit * (1.0 - forest_blend) + b_forest * forest_blend
    
    # Blend cone into flanking mountains towards the sides
    flank_blend = np.clip((cone_dist_t - 0.45) / 0.55, 0.0, 1.0)
    flank_blend = flank_blend * flank_blend * (3.0 - 2.0 * flank_blend)
    
    r_final = r_cone * (1.0 - flank_blend) + r_flank * flank_blend
    g_final = g_cone * (1.0 - flank_blend) + g_flank * flank_blend
    b_final = b_cone * (1.0 - flank_blend) + b_flank * flank_blend
    
    # Atmospheric base haze (y > 480) to blend softly with Layer 3 foreground
    base_haze = np.clip((y_grid - 480.0) / 240.0, 0.0, 1.0)
    haze_r, haze_g, haze_b = 36.0, 52.0, 68.0
    r_final = r_final * (1.0 - base_haze * 0.40) + haze_r * (base_haze * 0.40)
    g_final = g_final * (1.0 - base_haze * 0.40) + haze_g * (base_haze * 0.40)
    b_final = b_final * (1.0 - base_haze * 0.40) + haze_b * (base_haze * 0.40)
    
    # Active Geothermal Magma Glow in Crater Throat
    # Radial distance from crater center
    crater_dist_x = np.abs(x[None, :] - center_x)
    crater_dist_y = np.abs(y_grid - (crater_y + 12.0))
    in_crater_glow = (crater_dist_x < crater_hw * 1.4) & (y_grid >= crater_y - 8.0) & (y_grid < crater_y + 45.0)
    
    glow_x_norm = np.clip(crater_dist_x / (crater_hw * 1.4), 0.0, 1.0)
    glow_y_norm = np.clip(crater_dist_y / 32.0, 0.0, 1.0)
    glow_intensity = (1.0 - glow_x_norm**2) * (1.0 - glow_y_norm**2)
    glow_intensity = np.clip(glow_intensity * in_crater_glow, 0.0, 1.0)
    
    # Molten magma / incandescent lava colors:
    # Core: #ffaa44 (255, 170, 68), Rim: #e64a19 (230, 74, 25)
    lava_r = 255.0 * (1.0 - glow_x_norm * 0.3)
    lava_g = 140.0 * (1.0 - glow_x_norm * 0.5)
    lava_b = 40.0 * (1.0 - glow_x_norm * 0.6)
    
    r_final = r_final * (1.0 - glow_intensity * 0.85) + lava_r * (glow_intensity * 0.85)
    g_final = g_final * (1.0 - glow_intensity * 0.85) + lava_g * (glow_intensity * 0.85)
    b_final = b_final * (1.0 - glow_intensity * 0.85) + lava_b * (glow_intensity * 0.85)
    
    # Apply to image
    rgba[in_mountain, 0] = np.clip(r_final[in_mountain], 0, 255).astype(np.uint8)
    rgba[in_mountain, 1] = np.clip(g_final[in_mountain], 0, 255).astype(np.uint8)
    rgba[in_mountain, 2] = np.clip(b_final[in_mountain], 0, 255).astype(np.uint8)
    rgba[in_mountain, 3] = 255
    
    # 4. Volcanic Ash & Steam Plume drifting from Crater
    print("Generating atmospheric volcanic plume...")
    smoke = np.zeros((height, width, 4), dtype=np.float32)
    plume_noise = make_fractal_noise(width, height, base_scale=32, octaves=4, persistence=0.5, seed=555)
    
    # Plume rises from y = crater_y + 10 up to y = 10
    plume_top = 10
    plume_base = int(crater_y + 12)
    
    for sy in range(plume_top, plume_base):
        t = (plume_base - sy) / float(plume_base - plume_top) # 0 at crater, 1 at top
        
        # Plume expands as it rises
        plume_width = crater_hw * 0.6 + t * 65.0
        # Gentle rightward wind drift with natural wavy turbulence
        drift_x = center_x + t * 50.0 + 10.0 * math.sin(t * 4.0)
        
        x_min = max(0, int(drift_x - plume_width * 1.8))
        x_max = min(width - 1, int(drift_x + plume_width * 1.8))
        
        x_sub = np.arange(x_min, x_max + 1, dtype=np.float32)
        dist_x = np.abs(x_sub - drift_x)
        
        # Gaussian density profile
        density = np.exp(- 2.4 * (dist_x / plume_width)**2)
        
        # Density modulation by multi-scale turbulence
        n = plume_noise[sy, x_min:x_max + 1]
        density *= (0.65 + 0.70 * n)
        
        # Vertical fading: dense at crater, dissipating into wisps
        alpha = density * (1.0 - t * 0.65) * 0.50
        
        # Ash/steam color gradient:
        # Near crater: warmed by subterranean magma (#e08850 -> 224, 136, 80)
        # Higher up: cool silvery twilight ash (#b0b8c8 -> 176, 184, 200)
        sr = 225.0 * (1.0 - t) + 170.0 * t
        sg = 145.0 * (1.0 - t) + 180.0 * t
        sb = 95.0 * (1.0 - t) + 205.0 * t
        
        smoke[sy, x_min:x_max + 1, 0] = sr
        smoke[sy, x_min:x_max + 1, 1] = sg
        smoke[sy, x_min:x_max + 1, 2] = sb
        smoke[sy, x_min:x_max + 1, 3] = np.clip(alpha * 255.0, 0.0, 255.0)
        
    base_img = Image.fromarray(rgba, mode="RGBA")
    smoke_img = Image.fromarray(smoke.astype(np.uint8), mode="RGBA")
    # Soft blur on smoke for authentic vapor appearance
    smoke_img = smoke_img.filter(ImageFilter.GaussianBlur(1.2))
    
    # Composite
    final_img = Image.alpha_composite(base_img, smoke_img)
    final_img.save(out_path)
    print(f"Mount Mayon asset saved to {out_path}")
    
    # Save thumbnail
    thumb = final_img.copy()
    thumb.thumbnail((540, 180))
    thumb.save(thumb_path)
    print(f"Thumbnail saved to {thumb_path}")

if __name__ == "__main__":
    generate_mayon_volcano()
