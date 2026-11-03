import os
import numpy as np
from PIL import Image, ImageFilter, ImageDraw

def build_seamless_warning(warn_src_path, out_path):
    """
    Builds a seamless 2D platformer lightning telegraph warning VFX.
    Source: platformer_warning_seamless_1791203871193.jpg (1376x768)
    Floor contact line: Y = 642, Center sky column: X = 687
    """
    warn = Image.open(warn_src_path)
    arr = np.array(warn.convert('RGB')).astype(np.float32)
    
    # We want the sky pillar extending high up and the ground plasma spreading wide.
    # Center X: 687, Floor line Y: 642
    # Width: 1160 (from 687 - 580 to 687 + 580 = 107 to 1267)
    # Height: 660 (from Y = 0 to Y = 660)
    crop = arr[0:660, 687 - 580:687 + 580]
    h, w = crop.shape[:2]
    
    # Additive energy extraction
    r, g, b = crop[:, :, 0], crop[:, :, 1], crop[:, :, 2]
    energy = np.maximum(g * 0.95 + b * 0.75, r * 0.9)
    thresh = 10.0
    alpha = np.clip((energy - thresh) / (255.0 - thresh), 0.0, 1.0)
    alpha = np.power(alpha, 1.08)
    
    # Feather horizontally towards left and right edges over 140 pixels so NO cutoff
    x_indices = np.arange(w)
    dist_from_edge = np.minimum(x_indices, (w - 1) - x_indices).astype(np.float32)
    feather_dist = 140.0
    h_feather = np.clip(dist_from_edge / feather_dist, 0.0, 1.0)
    # Smooth cosine easing for natural plasma dissipation
    h_feather = 0.5 - 0.5 * np.cos(h_feather * np.pi)
    alpha *= h_feather[None, :]
    
    # Feather bottom 16 pixels smoothly into ground
    y_indices = np.arange(h)
    dist_from_bottom = ((h - 1) - y_indices).astype(np.float32)
    b_feather = np.clip(dist_from_bottom / 16.0, 0.0, 1.0)
    alpha *= b_feather[:, None]
    
    # Top 30 pixels smooth fade into clouds
    t_feather = np.clip(y_indices / 30.0, 0.0, 1.0)
    alpha *= t_feather[:, None]
    
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[:, :, :3] = np.clip(crop, 0, 255).astype(np.uint8)
    rgba[:, :, 3] = np.clip(alpha * 255.0, 0, 255).astype(np.uint8)
    
    img = Image.fromarray(rgba)
    # Target size: 512x384 (proportional to 1160x660 = ~1.75:1)
    target_w = 512
    target_h = int(660.0 / 1160.0 * 512.0) # ~291
    img_out = img.resize((target_w, target_h), Image.Resampling.LANCZOS)
    
    # Pad to standard 512x384 canvas
    canvas = Image.new("RGBA", (512, 384), (0, 0, 0, 0))
    # Place floor line (originally at 642 / 660 * target_h = ~283) at canvas Y = 360
    floor_in_resized = int(642.0 / 660.0 * target_h)
    paste_y = 360 - floor_in_resized
    canvas.paste(img_out, (0, paste_y), img_out)
    
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    canvas.save(out_path, "PNG")
    print(f"Saved Seamless Warning VFX: {out_path} ({canvas.size}), Floor at Y = 360")


def extract_crater_stage(crater_img, center_x, ground_y, crop_w=320, crop_h=180, is_molten=False):
    """
    Extracts a seamless crater stage, isolating the crater depression, charred rim,
    and vertical cracks, while eliminating surrounding non-crater dirt and zeroing out air above ground_y.
    """
    x1 = int(center_x - crop_w // 2)
    x2 = x1 + crop_w
    y1 = int(ground_y - 25) # 25px of air above ground line
    y2 = y1 + crop_h
    
    crop = crater_img.crop((x1, y1, x2, y2))
    arr = np.array(crop.convert('RGBA')).astype(np.float32)
    h, w = arr.shape[:2]
    
    lum = np.mean(arr[:, :, :3], axis=2)
    y_grid = np.arange(h)[:, None]
    x_grid = np.arange(w)[None, :]
    
    # Zero out air above ground line (y < 25)
    arr[:25, :, 3] = 0.0
    
    # Distance from crater center
    dist_x = np.abs(x_grid - (w / 2.0)) / (w * 0.38) # 0 at center, 1 at crater rim
    dist_x = np.clip(dist_x, 0.0, 1.0)
    horiz_feather = np.cos(dist_x * (np.pi / 2.0)) # 1 at center, 0 at edge
    
    if is_molten:
        # For Stage 1 & 2: highlight fiery orange/red magma fissures and glowing embers
        # Red minus green/blue
        red_energy = np.maximum(0.0, arr[:, :, 0] - np.maximum(arr[:, :, 1], arr[:, :, 2]) * 0.8)
        charcoal_mask = np.clip((70.0 - lum) / 50.0, 0.0, 1.0)
        molten_mask = np.clip(red_energy / 40.0, 0.0, 1.0)
        crater_alpha = np.maximum(charcoal_mask * 0.85, molten_mask) * horiz_feather
        
        # Depression zone
        depression_zone = (dist_x < 0.72) & (y_grid >= 25) & (y_grid <= 65)
        depression_val = (1.0 - dist_x / 0.72) * 0.95
        crater_alpha = np.where(depression_zone, np.maximum(crater_alpha, depression_val), crater_alpha)
    else:
        # For Stage 3: dark cooled carbon rock and vertical fracture cracks
        charcoal_mask = np.clip((65.0 - lum) / 45.0, 0.0, 1.0)
        crater_alpha = charcoal_mask * horiz_feather
        
        # Depression zone
        depression_zone = (dist_x < 0.75) & (y_grid >= 25) & (y_grid <= 62)
        depression_val = (1.0 - dist_x / 0.75) * 0.96
        crater_alpha = np.where(depression_zone, np.maximum(crater_alpha, depression_val), crater_alpha)
        
        # Vertical fissure cracks extending down
        cracks_zone = (y_grid > 60) & (lum < 42)
        crack_alpha = np.clip((42.0 - lum) / 30.0, 0.0, 1.0) * horiz_feather
        crater_alpha = np.where(cracks_zone, np.maximum(crater_alpha, crack_alpha), crater_alpha)
    
    # Vertical fade out at bottom (y > 130)
    y_fade = np.clip((150 - y_grid) / 35.0, 0.0, 1.0)
    crater_alpha *= y_fade
    
    # Modulate RGB for dark carbon styling
    if not is_molten:
        arr[:, :, 0] = np.clip(arr[:, :, 0] * 0.65, 8, 32)
        arr[:, :, 1] = np.clip(arr[:, :, 1] * 0.65, 8, 32)
        arr[:, :, 2] = np.clip(arr[:, :, 2] * 0.70, 10, 36)
    
    # Strictly zero out air above ground line (y < 25)
    crater_alpha[:25, :] = 0.0
    arr[:, :, 3] = np.clip(crater_alpha * 255.0, 0, 255)
    return Image.fromarray(arr.astype(np.uint8))


def build_seamless_scorch(crater_src_path, warn_src_path, out_path):
    """
    Builds a 5-frame seamless 2D platformer crater scorch spritesheet.
    Frame 0: High-energy electric impact burst on platform floor
    Frame 1: Sizzling surface arcs on the floor
    Frame 2: Cooling magma fissures & embers (Stage 1)
    Frame 3: Fresh scorch with warm embers (Stage 2)
    Frame 4: Permanent cooled blackened carbon crater with vertical soot cracks (Stage 3)
    """
    crater_src = Image.open(crater_src_path)
    warn_src = Image.open(warn_src_path)
    
    # Crater centers: S1 at 220, S2 at 690, S3 at 1150; Ground line at Y = 345
    s1_decal = extract_crater_stage(crater_src, center_x=220, ground_y=345, is_molten=True)
    s2_decal = extract_crater_stage(crater_src, center_x=690, ground_y=345, is_molten=True)
    s3_decal = extract_crater_stage(crater_src, center_x=1150, ground_y=345, is_molten=False)
    
    FRAME_W = 256
    FRAME_H = 160
    TARGET_DECAL_W = 160 # Spans ~80px on screen when scaled 0.50 (2.5 tiles)
    TARGET_RIM_Y = 20    # Baseline floor at Y = 20 in the frame
    
    master = Image.new("RGBA", (FRAME_W * 5, FRAME_H), (0, 0, 0, 0))
    
    # Helper to paste decal with soft feathered ground soot burn underneath
    def composite_crater_frame(decal_img, soot_alpha=190, soot_radius_x=65, soot_radius_y=28, allow_air_embers=False):
        canvas = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
        
        # 1. Soft radial soot burn underneath that chars the tileset naturally
        soot = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
        d = ImageDraw.Draw(soot)
        cx, cy = FRAME_W // 2, TARGET_RIM_Y + 16
        # Confined below ground line so soot darkens the tileset
        d.ellipse([cx - soot_radius_x, cy - soot_radius_y, cx + soot_radius_x, cy + soot_radius_y], fill=(10, 8, 7, soot_alpha))
        soot = soot.filter(ImageFilter.GaussianBlur(radius=8))
        
        # Clean any soot that bled into air above TARGET_RIM_Y
        soot_arr = np.array(soot)
        soot_arr[:TARGET_RIM_Y, :, 3] = 0
        soot = Image.fromarray(soot_arr)
        
        canvas = Image.alpha_composite(canvas, soot)
        
        # 2. Resize and position crater decal
        scale = TARGET_DECAL_W / float(decal_img.width)
        scaled_w = TARGET_DECAL_W
        scaled_h = int(decal_img.height * scale)
        decal_resized = decal_img.resize((scaled_w, scaled_h), Image.Resampling.LANCZOS)
        
        px = (FRAME_W - scaled_w) // 2
        # Rim in decal was at Y = 25
        scaled_rim_y = int(25 * scale)
        py = TARGET_RIM_Y - scaled_rim_y
        
        canvas.paste(decal_resized, (px, py), decal_resized)
        
        # If no air embers allowed (Frame 4 permanent), ensure 100% clean air above TARGET_RIM_Y
        c_arr = np.array(canvas)
        if not allow_air_embers:
            c_arr[:TARGET_RIM_Y, :, 3] = 0
            
        # Ensure zero alpha on outer borders
        c_arr[:, 0, 3] = 0
        c_arr[:, -1, 3] = 0
        c_arr[0, :, 3] = 0
        c_arr[-1, :, 3] = 0
        return Image.fromarray(c_arr)
    
    # Frame 4: Permanent Cooled Carbon Crater (Stage 3, zero air pixels)
    f4 = composite_crater_frame(s3_decal, soot_alpha=215, soot_radius_x=68, soot_radius_y=26, allow_air_embers=False)
    master.paste(f4, (4 * FRAME_W, 0), f4)
    
    # Frame 3: Fresh Scorch with Warm Embers (Stage 2)
    f3 = composite_crater_frame(s2_decal, soot_alpha=220, soot_radius_x=70, soot_radius_y=28, allow_air_embers=True)
    master.paste(f3, (3 * FRAME_W, 0), f3)
    
    # Frame 2: Cooling Magma Fissures & Embers (Stage 1)
    f2 = composite_crater_frame(s1_decal, soot_alpha=230, soot_radius_x=72, soot_radius_y=30, allow_air_embers=True)
    master.paste(f2, (2 * FRAME_W, 0), f2)
    
    # Frame 0: Electrical Ground Impact Burst (from warning plasma center)
    w_crop = warn_src.crop((687 - 350, 642 - 120, 687 + 350, 642 + 40))
    w_arr = np.array(w_crop.convert('RGB')).astype(np.float32)
    r0, g0, b0 = w_arr[:, :, 0], w_arr[:, :, 1], w_arr[:, :, 2]
    e0 = np.maximum(g0 * 1.0 + b0 * 0.8, r0 * 0.95)
    a0 = np.clip((e0 - 14.0) / (255.0 - 14.0), 0.0, 1.0)
    a0 = np.power(a0, 1.1) * 255.0
    
    # Feather horizontally and vertically
    hw, hh = w_crop.width, w_crop.height
    x_idx = np.arange(hw)
    dist_edge = np.minimum(x_idx, (hw - 1) - x_idx).astype(np.float32)
    a0 *= np.clip(dist_edge / 45.0, 0.0, 1.0)[None, :]
    y_idx = np.arange(hh)
    dist_y_top = y_idx.astype(np.float32)
    a0 *= np.clip(dist_y_top / 20.0, 0.0, 1.0)[:, None]
    
    burst_rgba = np.zeros((hh, hw, 4), dtype=np.uint8)
    burst_rgba[:, :, :3] = np.clip(w_arr, 0, 255).astype(np.uint8)
    burst_rgba[:, :, 3] = np.clip(a0, 0, 255).astype(np.uint8)
    burst_img = Image.fromarray(burst_rgba)
    
    burst_scale = TARGET_DECAL_W / float(burst_img.width)
    b_w = TARGET_DECAL_W
    b_h = int(burst_img.height * burst_scale)
    b_resized = burst_img.resize((b_w, b_h), Image.Resampling.LANCZOS)
    
    f0 = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
    px0 = (FRAME_W - b_w) // 2
    py0 = TARGET_RIM_Y - int(120 * burst_scale)
    f0.paste(b_resized, (px0, py0), b_resized)
    f0_arr = np.array(f0)
    f0_arr[:, 0, 3] = 0
    f0_arr[:, -1, 3] = 0
    f0_arr[0, :, 3] = 0
    f0_arr[-1, :, 3] = 0
    master.paste(Image.fromarray(f0_arr), (0 * FRAME_W, 0), Image.fromarray(f0_arr))
    
    # Frame 1: Sizzling surface arcs (dissipating burst + beginning soot)
    f1 = composite_crater_frame(s1_decal, soot_alpha=120, soot_radius_x=55, soot_radius_y=22, allow_air_embers=True)
    b1_arr = np.array(b_resized).astype(np.float32)
    b1_arr[:, :, 3] *= 0.50
    f1.paste(Image.fromarray(b1_arr.astype(np.uint8)), (px0, py0), Image.fromarray(b1_arr.astype(np.uint8)))
    f1_arr = np.array(f1)
    f1_arr[:, 0, 3] = 0
    f1_arr[:, -1, 3] = 0
    f1_arr[0, :, 3] = 0
    f1_arr[-1, :, 3] = 0
    master.paste(Image.fromarray(f1_arr), (1 * FRAME_W, 0), Image.fromarray(f1_arr))
    
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    master.save(out_path, "PNG")
    print(f"Saved Seamless Scorch Spritesheet: {out_path} ({master.size})")
    
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    master.save(out_path, "PNG")
    print(f"Saved Seamless Scorch Spritesheet: {out_path} ({master.size})")


if __name__ == "__main__":
    brain = r"C:\Users\Lin\.gemini\antigravity\brain\c7718a4a-5c4f-4a83-8604-730ecde0e295"
    base = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test"
    
    warn_src = os.path.join(brain, "platformer_warning_seamless_1791203871193.jpg")
    warn_out = os.path.join(base, "assets", "vfx", "vfx_lightning_warning.png")
    
    crater_src = os.path.join(brain, "platformer_crater_seamless_1791203892500.jpg")
    scorch_out = os.path.join(base, "assets", "vfx", "vfx_lightning_scorch.png")
    
    build_seamless_warning(warn_src, warn_out)
    build_seamless_scorch(crater_src, warn_src, scorch_out)
