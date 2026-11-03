import math
import numpy as np
from PIL import Image, ImageFilter

def make_noise(width, height, scale, octaves=4, seed=42):
    np.random.seed(seed)
    # Generate multi-scale value noise
    grid = np.zeros((height, width), dtype=np.float32)
    current_amp = 1.0
    total_amp = 0.0
    for o in range(octaves):
        s = max(2, int(scale / (2 ** o)))
        gh = (height // s) + 2
        gw = (width // s) + 2
        rand_grid = np.random.rand(gh, gw).astype(np.float32)
        
        # Bilinear interpolation
        y_indices = np.linspace(0, gh - 1, height)
        x_indices = np.linspace(0, gw - 1, width)
        y0 = np.floor(y_indices).astype(int)
        y1 = np.minimum(y0 + 1, gh - 1)
        x0 = np.floor(x_indices).astype(int)
        x1 = np.minimum(x0 + 1, gw - 1)
        
        fy = (y_indices - y0)[:, None]
        fx = (x_indices - x0)[None, :]
        
        top = rand_grid[y0[:, None], x0[None, :]] * (1 - fx) + rand_grid[y0[:, None], x1[None, :]] * fx
        bot = rand_grid[y1[:, None], x0[None, :]] * (1 - fx) + rand_grid[y1[:, None], x1[None, :]] * fx
        octave_noise = top * (1 - fy) + bot * fy
        
        grid += octave_noise * current_amp
        total_amp += current_amp
        current_amp *= 0.5
        
    return grid / total_amp

def generate_mayon_volcano_asset(out_path="assets/bicol_bg/Rice_Field_Layer4.png"):
    width = 2160
    height = 720
    center_x = 1080.0
    crater_y = 62.0
    crater_hw = 46.0   # half width of crater
    
    # Generate seamless background mountain profile
    x = np.arange(width, dtype=np.float32)
    
    # 1. Base undulating mountain ridges flanking Mayon (seamless at 0 and width)
    angle = 2.0 * math.pi * x / width
    # Flanking peaks around x=300 (left) and x=1860 (right)
    flank_ridges = (
        370.0 
        + 55.0 * np.cos(angle * 2.0 - 0.2) 
        + 30.0 * np.sin(angle * 4.0 + 0.5) 
        + 18.0 * np.cos(angle * 6.0 - 0.8)
        + 10.0 * np.sin(angle * 8.0)
    )
    
    # 2. Mayon cone profile (world famous symmetrical concave curve)
    dx = np.abs(x - center_x)
    cone_profile = np.zeros(width, dtype=np.float32)
    
    in_crater = dx <= crater_hw
    # Crater has distinct shallow concave depression
    cone_profile[in_crater] = crater_y + 10.0 * (1.0 - (dx[in_crater] / crater_hw)**2)
    
    # Flanks: Mayon's parabolic curve: y = crater_y + A * (dx - crater_hw)^1.36
    flank_dx = dx[~in_crater] - crater_hw
    # Reaches y=580 at dx = 680
    max_flank_w = 660.0
    cone_profile[~in_crater] = crater_y + 510.0 * np.power(flank_dx / max_flank_w, 1.34)
    
    # Combine volcano and side ranges (volcano in front)
    # Beyond max_flank_w, smoothly blend into flank_ridges
    blend_weight = np.clip((dx - 480.0) / 200.0, 0.0, 1.0)
    skyline = np.minimum(cone_profile, flank_ridges)
    
    # Add subtle rock roughness to skyline (seamless)
    roughness = 2.5 * np.sin(x * 0.15) + 1.5 * np.cos(x * 0.35 + 1.0)
    # Keep the upper cone clean and iconic
    crater_damp = np.clip(dx / 120.0, 0.25, 1.0)
    skyline += roughness * crater_damp
    
    # Generate painterly rock textures using multi-octave noise
    rock_noise = make_noise(width, height, scale=48, octaves=4, seed=101)
    fine_noise = make_noise(width, height, scale=16, octaves=3, seed=202)
    
    # Prepare image arrays
    rgba = np.zeros((height, width, 4), dtype=np.uint8)
    
    # Radiating lava couloirs/gullies from crater
    # 20 distinct gullies radiating down the slopes of Mayon
    num_gullies = 22
    gully_positions = np.linspace(-0.88, 0.88, num_gullies)
    # Randomize slightly for natural erosion
    np.random.seed(77)
    gully_offsets = (np.random.rand(num_gullies) - 0.5) * 0.06
    gully_angles = gully_positions + gully_offsets
    
    print("Rasterizing Mayon Volcano & mountain ridges...")
    for y_idx in range(height):
        # find x values where pixel is inside the mountain (y >= skyline)
        mask = (y_idx >= skyline)
        x_indices = np.where(mask)[0]
        if len(x_indices) == 0:
            continue
            
        dx_vals = x_indices - center_x
        abs_dx = np.abs(dx_vals)
        
        # Vertical depth down the slope
        vert_depth = y_idx - skyline[x_indices]
        
        # Calculate whether on Mayon cone
        on_mayon = (abs_dx < 680.0) & (y_idx < flank_ridges[x_indices] + 30.0)
        
        # Distance from crater top
        dy_crater = max(1.0, float(y_idx - crater_y))
        slope_t = np.clip(dy_crater / 540.0, 0.0, 1.0) # 0 at peak, 1 at base
        
        # Light value calculation:
        # Key light from upper left (cool moonlit twilight / silver),
        # Shaded side on right, with ambient fill
        norm_dx = dx_vals / max(1.0, dy_crater * 0.95 + 60.0)
        
        # Gully shadows and highlights
        gully_val = np.zeros_like(dx_vals, dtype=np.float32)
        for ga in gully_angles:
            diff = np.abs(norm_dx - ga)
            gully_mask = diff < 0.05
            gully_val[gully_mask] = np.maximum(gully_val[gully_mask], (0.05 - diff[gully_mask]) / 0.05)
            
        # Shading model:
        # Facing light (dx < 0): brighter, cool silver-indigo
        # Facing away (dx > 0): deeper shadow, rich dark indigo
        # Gullies add dramatic vertical shadows and ridge highlights
        base_light = 0.52 - 0.32 * (dx_vals / 620.0)
        base_light -= 0.26 * gully_val # Gully crevices in shadow
        # Ridge highlights on left rim of each gully
        ridge_highlight = np.clip((gully_val - 0.5) * 2.0, 0.0, 1.0) * (dx_vals < 0) * 0.15
        base_light += ridge_highlight
        
        # Texture variation
        tex_var = (rock_noise[y_idx, x_indices] - 0.5) * 0.22 + (fine_noise[y_idx, x_indices] - 0.5) * 0.14
        light = np.clip(base_light + tex_var, 0.12, 0.92)
        
        # Palette definition (Dark Fantasy Nocturnal / Twilight)
        # Colors:
        # 1. Volcanic Summit / Basalt Rock (top 35% of Mayon):
        #    Lit: #46546e (70, 84, 110)
        #    Mid: #2c3547 (44, 53, 71)
        #    Shadow: #1a202c (26, 32, 44)
        r_summit = 26 + light * 46
        g_summit = 32 + light * 52
        b_summit = 46 + light * 66
        
        # 2. Mid-slope Rainforest / Emerald Foothills (slope_t 0.35 to 0.75):
        #    Transition from dark basalt into lush volcanic jungle ridges
        #    Lit: #306e54 (48, 110, 84)
        #    Mid: #1f4e3b (31, 78, 59)
        #    Shadow: #133024 (19, 48, 36)
        r_forest = 18 + light * 32
        g_forest = 42 + light * 68
        b_forest = 34 + light * 50
        
        # 3. Side Mountain Ranges (distant misty indigo silhouettes):
        #    Lit: #3a4b64 (58, 75, 100)
        #    Mid: #263345 (38, 51, 69)
        #    Shadow: #18202d (24, 32, 45)
        r_side = 24 + light * 36
        g_side = 32 + light * 44
        b_side = 46 + light * 56
        
        # Blend Mayon vs Side Ranges
        r_out = np.where(on_mayon, 
                         np.where(slope_t < 0.35, r_summit, 
                                  r_summit * (1.0 - (slope_t - 0.35)/0.40) + r_forest * ((slope_t - 0.35)/0.40)),
                         r_side)
        g_out = np.where(on_mayon, 
                         np.where(slope_t < 0.35, g_summit, 
                                  g_summit * (1.0 - (slope_t - 0.35)/0.40) + g_forest * ((slope_t - 0.35)/0.40)),
                         g_side)
        b_out = np.where(on_mayon, 
                         np.where(slope_t < 0.35, b_summit, 
                                  b_summit * (1.0 - (slope_t - 0.35)/0.40) + b_forest * ((slope_t - 0.35)/0.40)),
                         b_side)
        
        # 4. Geothermal Magma Glow in Crater Throat (top 45px of Mayon, inside crater)
        crater_mask = on_mayon & (y_idx < crater_y + 40.0) & (abs_dx < crater_hw * 1.3)
        if np.any(crater_mask):
            c_indices = np.where(crater_mask)[0]
            c_dx = abs_dx[c_indices]
            c_dist = 1.0 - (c_dx / (crater_hw * 1.3))
            c_depth = np.clip(1.0 - (y_idx - crater_y) / 40.0, 0.0, 1.0)
            glow_intensity = c_dist * c_depth * 0.85
            
            # Vivid geothermal lava amber/crimson
            r_out[c_indices] = r_out[c_indices] * (1.0 - glow_intensity) + 235.0 * glow_intensity
            g_out[c_indices] = g_out[c_indices] * (1.0 - glow_intensity) + 85.0 * glow_intensity
            b_out[c_indices] = b_out[c_indices] * (1.0 - glow_intensity) + 38.0 * glow_intensity
            
        # 5. Base atmospheric haze (y > 540) to blend with Layer 3
        if y_idx > 540:
            haze_t = np.clip((y_idx - 540.0) / 180.0, 0.0, 1.0)
            haze_r, haze_g, haze_b = 32.0, 48.0, 62.0
            r_out = r_out * (1.0 - haze_t * 0.45) + haze_r * haze_t * 0.45
            g_out = g_out * (1.0 - haze_t * 0.45) + haze_g * haze_t * 0.45
            b_out = b_out * (1.0 - haze_t * 0.45) + haze_b * haze_t * 0.45
            
        rgba[y_idx, x_indices, 0] = np.clip(r_out, 0, 255).astype(np.uint8)
        rgba[y_idx, x_indices, 1] = np.clip(g_out, 0, 255).astype(np.uint8)
        rgba[y_idx, x_indices, 2] = np.clip(b_out, 0, 255).astype(np.uint8)
        rgba[y_idx, x_indices, 3] = 255

    # 4. Volcanic Smoke & Steam Plume
    # Billowing up from the crater throat: from y=62 up to y=10
    smoke = np.zeros((height, width, 4), dtype=np.float32)
    smoke_noise = make_noise(width, height, scale=24, octaves=3, seed=333)
    
    for sy in range(8, int(crater_y) + 6):
        t = (crater_y + 6 - sy) / 58.0 # 0 at crater, 1 at top
        plume_w = crater_hw * 0.65 + t * 54.0
        # Gentle drift slightly to the right with wind
        drift_x = center_x + t * 45.0 + math.sin(t * 3.5) * 8.0
        
        x_min = max(0, int(drift_x - plume_w * 1.6))
        x_max = min(width - 1, int(drift_x + plume_w * 1.6))
        
        for sx in range(x_min, x_max + 1):
            dist_x = abs(sx - drift_x)
            if dist_x > plume_w * 1.5:
                continue
                
            # Gaussian bell curve
            density = math.exp(-2.2 * (dist_x / plume_w)**2)
            # Dissipation with height
            alpha = density * (1.0 - t * 0.70) * 0.55
            # Add billow noise
            n = smoke_noise[sy, sx]
            alpha *= (0.7 + 0.6 * n)
            
            # Color: warm volcanic ash / sulfur gold at crater throat, cool pale silver-white at top
            sr = 225.0 * (1.0 - t) + 185.0 * t
            sg = 160.0 * (1.0 - t) + 195.0 * t
            sb = 120.0 * (1.0 - t) + 215.0 * t
            
            smoke[sy, sx] = [sr, sg, sb, np.clip(alpha * 255.0, 0.0, 255.0)]
            
    base_img = Image.fromarray(rgba, mode="RGBA")
    smoke_img = Image.fromarray(smoke.astype(np.uint8), mode="RGBA")
    smoke_img = smoke_img.filter(ImageFilter.GaussianBlur(1.0))
    
    result = Image.alpha_composite(base_img, smoke_img)
    result.save(out_path)
    print(f"Generated Mayon Volcano saved to {out_path}")
    
    # Save a thumbnail
    thumb = result.copy()
    thumb.thumbnail((540, 180))
    thumb.save("scratch/mayon_v2_thumb.png")
    print("Thumbnail saved to scratch/mayon_v2_thumb.png")

if __name__ == "__main__":
    generate_mayon_volcano_asset()
