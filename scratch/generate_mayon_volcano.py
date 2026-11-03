import math
import numpy as np
from PIL import Image, ImageFilter

def generate_mayon_layer():
    width = 2160
    height = 720
    
    # Create RGBA array
    img_arr = np.zeros((height, width, 4), dtype=np.uint8)
    
    # Parameters for Mayon Volcano
    center_x = 1080.0
    crater_y = 70.0
    crater_w = 42.0   # half-width of crater rim
    crater_depth = 12.0
    
    # 1. Heightmap generation for Mount Mayon & surrounding Albay mountain range
    # We want seamless tiling at x=0 and x=width
    x_coords = np.arange(width, dtype=np.float32)
    
    # Smooth mountain ridges on the sides (seamless: f(0) == f(width))
    def side_mountains(x):
        # Base undulating ridges
        phase = 2.0 * math.pi * x / width
        h = 390.0 + 45.0 * np.sin(phase * 2.0 + 0.4) + 30.0 * np.sin(phase * 4.0 - 0.8) + 18.0 * np.cos(phase * 7.0 + 1.2)
        # Extra jagged ridges near edges
        h += 12.0 * np.sin(x * 0.04) * np.cos(x * 0.015)
        return h

    ridge_h = side_mountains(x_coords)
    
    # Mayon cone profile
    dist_from_center = np.abs(x_coords - center_x)
    
    # Mayon cone shape: classic concave stratovolcano curve
    # y = crater_y + A * (dist)^power
    cone_h = np.zeros_like(x_coords)
    in_crater = dist_from_center <= crater_w
    # Crater has a slight dip in the middle
    cone_h[in_crater] = crater_y + crater_depth * (1.0 - (dist_from_center[in_crater] / crater_w)**2)
    
    # Flanks
    flank_mask = ~in_crater
    flank_dist = dist_from_center[flank_mask] - crater_w
    # Concave curve from crater_y to ground around y=560 at dist=600
    # 560 - 70 = 490
    cone_h[flank_mask] = crater_y + 490.0 * ((flank_dist / 620.0) ** 1.38)
    
    # Combine volcano with side ridges (volcano is in front / higher, so takes min y)
    skyline_y = np.minimum(cone_h, ridge_h)
    
    # Add high-frequency rocky jaggedness to the skyline (seamless)
    rock_noise = 2.5 * np.sin(x_coords * 0.2) + 1.8 * np.cos(x_coords * 0.45)
    # Less noise at the very rim of Mayon to preserve its iconic clean silhouette
    rim_damp = np.clip(dist_from_center / 180.0, 0.2, 1.0)
    skyline_y += rock_noise * rim_damp
    
    # 2. Shading and texturing
    # Seeded random for reproducible natural rock facets
    np.random.seed(42)
    
    # Radial gully offsets from the crater
    num_gullies = 24
    gully_angles = np.linspace(-0.85, 0.85, num_gullies)
    
    for y in range(height):
        # Active horizontal pixels where y >= skyline_y
        active_x = np.where(y >= skyline_y)[0]
        if len(active_x) == 0:
            continue
            
        depth_from_peak = (y - skyline_y[active_x])
        altitude = (height - y) / height # 1.0 at top, 0.0 at bottom
        
        for x in active_x:
            dx = x - center_x
            d = abs(dx)
            
            # Is this pixel on the Mayon cone or side ridges?
            is_mayon = (d < 680.0) and (y < ridge_h[x] or cone_h[x] < ridge_h[x] + 40.0)
            
            if is_mayon:
                # Radial angle on cone
                angle_ratio = dx / max(1.0, (y - crater_y) * 0.95 + 40.0)
                angle_ratio = np.clip(angle_ratio, -1.2, 1.2)
                
                # Slope steepness
                slope_t = np.clip((y - crater_y) / 520.0, 0.0, 1.0) # 0 at summit, 1 at base
                
                # Gullies & ravines texture
                gully_factor = 0.0
                for ga in gully_angles:
                    diff = abs(angle_ratio - ga)
                    if diff < 0.06:
                        gully_factor += (0.06 - diff) / 0.06
                gully_factor = np.clip(gully_factor, 0.0, 1.0)
                
                # Fine rock striations
                rock_detail = 0.5 + 0.3 * math.sin(x * 0.12 + y * 0.08) + 0.2 * math.cos(x * 0.05 - y * 0.15)
                
                # Lighting: Twilight directional key light from upper-left (moonlit cool ivory/silver),
                # fill light on right (deep volcanic twilight purple/indigo),
                # and subtle geothermal warm rim inside gullies
                light_val = 0.5 - 0.38 * (dx / 600.0) + (0.15 * rock_detail) - (0.28 * gully_factor)
                light_val = np.clip(light_val, 0.15, 0.95)
                
                # Altitude-based color blending:
                # Summit (slope_t < 0.25): Dark obsidian volcanic rock, ash scree, pumice
                # Mid-slopes (0.25 <= slope_t < 0.65): Weathered basalt with mossy patches
                # Base (slope_t >= 0.65): Lush dark tropical emerald foothills
                
                if slope_t < 0.30:
                    # Volcanic summit: Dark charcoal basalt, dark slate
                    r = int(28 + light_val * 42)
                    g = int(32 + light_val * 46)
                    b = int(46 + light_val * 62)
                    
                    # Geothermal/lava warmth in the crater throat (top 45px of Mayon)
                    if y < crater_y + 45.0 and d < crater_w * 1.4:
                        crater_prox = 1.0 - (d / (crater_w * 1.4))
                        crater_glow = max(0.0, 1.0 - (y - crater_y) / 45.0) * crater_prox
                        # Warm ember glow
                        r = int(r * (1.0 - crater_glow) + 210 * crater_glow)
                        g = int(g * (1.0 - crater_glow) + 75 * crater_glow)
                        b = int(b * (1.0 - crater_glow) + 35 * crater_glow)
                elif slope_t < 0.65:
                    # Mid-slope: Dark basalt transitioning to deep forest green
                    t_mid = (slope_t - 0.30) / 0.35
                    # Basalt color
                    r1, g1, b1 = 26 + light_val * 35, 30 + light_val * 40, 42 + light_val * 54
                    # Forest slope color
                    r2, g2, b2 = 22 + light_val * 28, 48 + light_val * 52, 45 + light_val * 48
                    r = int(r1 * (1 - t_mid) + r2 * t_mid)
                    g = int(g1 * (1 - t_mid) + g2 * t_mid)
                    b = int(b1 * (1 - t_mid) + b2 * t_mid)
                else:
                    # Foothills: Rich emerald forest canopy
                    t_base = (slope_t - 0.65) / 0.35
                    r = int(18 + light_val * 24 + t_base * 4)
                    g = int(46 + light_val * 48 + t_base * 10)
                    b = int(40 + light_val * 42 + t_base * 8)
                    
                # Soft atmospheric haze at very bottom
                if y > 580:
                    haze_t = (y - 580) / 140.0
                    r = int(r * (1 - haze_t * 0.45) + 38 * haze_t * 0.45)
                    g = int(g * (1 - haze_t * 0.45) + 52 * haze_t * 0.45)
                    b = int(b * (1 - haze_t * 0.45) + 68 * haze_t * 0.45)
                    
            else:
                # Distant side mountain ridges
                # Shaded in soft atmospheric indigo/slate
                light_val = 0.5 + 0.3 * math.sin(x * 0.08 + y * 0.05) - 0.2 * math.cos(x * 0.03)
                light_val = np.clip(light_val, 0.2, 0.85)
                
                # Dark mountain range silhouette with atmospheric distance
                r = int(24 + light_val * 32)
                g = int(34 + light_val * 42)
                b = int(48 + light_val * 58)
                
                # Base haze
                if y > 540:
                    haze_t = (y - 540) / 180.0
                    r = int(r * (1 - haze_t * 0.5) + 36 * haze_t * 0.5)
                    g = int(g * (1 - haze_t * 0.5) + 50 * haze_t * 0.5)
                    b = int(b * (1 - haze_t * 0.5) + 66 * haze_t * 0.5)

            # Set pixel
            img_arr[y, x] = [r, g, b, 255]
            
    # 3. Volcanic Smoke / Steam Plume from the crater
    # Plume drifts upwards and slightly to the right, dispersing into the twilight sky
    smoke_layer = np.zeros((height, width, 4), dtype=np.float32)
    for sy in range(12, int(crater_y) + 8):
        dist_y = (crater_y + 8 - sy) # 0 at crater, ~65 at top
        t = dist_y / 65.0 # 0 at crater, 1 at top
        
        # Plume width widens as it ascends
        plume_w = crater_w * 0.8 + t * 48.0
        # Drift slightly right
        drift_x = center_x + t * 35.0
        
        for sx in range(int(drift_x - plume_w * 1.5), int(drift_x + plume_w * 1.5)):
            if sx < 0 or sx >= width:
                continue
            dx = abs(sx - drift_x)
            if dx > plume_w:
                continue
            
            # Gaussian bell curve density
            density = math.exp(-2.5 * (dx / plume_w)**2)
            # Fade as it rises
            alpha = density * (1.0 - t * 0.75) * 0.42
            
            # Subtle billowing smoke noise
            noise = 0.8 + 0.2 * math.sin(sx * 0.15 + sy * 0.25)
            alpha *= noise
            
            # Smoke color: warm volcanic ash / sulfur gold near bottom, cool pale white-silver at top
            sr = 220 * (1 - t) + 180 * t
            sg = 180 * (1 - t) + 190 * t
            sb = 140 * (1 - t) + 210 * t
            
            smoke_layer[sy, sx] = [sr, sg, sb, alpha * 255.0]

    # Composite smoke over the mountain
    out_img = Image.fromarray(img_arr, mode="RGBA")
    smoke_img = Image.fromarray(smoke_layer.astype(np.uint8), mode="RGBA")
    # Soft blur on smoke for smooth atmospheric steam
    smoke_img = smoke_img.filter(ImageFilter.GaussianBlur(1.2))
    
    final_img = Image.alpha_composite(out_img, smoke_img)
    final_img.save("scratch/test_mayon_volcano.png")
    print("Saved test_mayon_volcano.png successfully!")

if __name__ == "__main__":
    generate_mayon_layer()
