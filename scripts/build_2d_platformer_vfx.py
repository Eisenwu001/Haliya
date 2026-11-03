import os
import numpy as np
from PIL import Image

def build_2d_platformer_warning(src_path, out_path):
    """
    Builds a 2D side-scrolling platformer electric hazard warning telegraph.
    Source: platform_warning_ledge_1791201605587.jpg
    The image shows electric plasma surging across a horizontal platform ledge.
    """
    src = Image.open(src_path)
    # Center x: 705, ground ledge line: y = 490
    # Crop centered at x = 705, width 860, height 260 (y: 300 to 560)
    crop_box = (705 - 430, 300, 705 + 430, 560)
    cropped = src.crop(crop_box)
    
    # Clean additive alpha
    arr = np.array(cropped.convert('RGB')).astype(np.float32)
    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    # Electric cyan luminance
    energy = np.maximum(g * 0.95 + b * 0.80, r * 0.9)
    black_thresh = 14.0
    alpha = np.clip((energy - black_thresh) / (255.0 - black_thresh), 0.0, 1.0)
    alpha = np.power(alpha, 1.15) * 255.0
    
    rgba = np.zeros((cropped.height, cropped.width, 4), dtype=np.uint8)
    rgba[:, :, :3] = cropped
    rgba[:, :, 3] = alpha.astype(np.uint8)
    
    img_rgba = Image.fromarray(rgba)
    # Resize to 512x256 (power-of-two)
    img_out = img_rgba.resize((512, 256), Image.Resampling.LANCZOS)
    
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img_out.save(out_path, "PNG")
    print(f"Saved 2D Platformer Warning VFX: {out_path} ({img_out.size})")

def build_2d_platformer_scorch(crater_src_path, burst_src_path, out_path):
    """
    Builds a 5-frame 2D side-scrolling platformer scorch spritesheet.
    Frame 0: High-energy electric impact burst on platform ledge
    Frame 1: Sizzling surface arcs on the ledge
    Frame 2: Cooling magma fissures & embers (Stage 1)
    Frame 3: Fresh scorch with warm fissure lines (Stage 2)
    Frame 4: Cooled permanent carbon soot & vertical cracks (Stage 3, zero bumps)
    """
    crater_src = Image.open(crater_src_path)
    burst_src = Image.open(burst_src_path)
    
    # 1. Frame 4: Stage 3 (Cooled carbon rock on platform ledge)
    # X: 950 to 1330, Y: 270 to 520
    s3 = crater_src.crop((950, 270, 1330, 520))
    arr_s3 = np.array(s3.convert('RGB')).astype(np.float32)
    lum3 = np.mean(arr_s3, axis=2)
    # Burn alpha: where lum < 55 (darkened rock and cracks)
    burn_alpha3 = np.clip((55.0 - lum3) / 45.0, 0.0, 1.0)
    burn_alpha3[:6, :] = 0.0 # Clear air above tile line
    
    out_s3 = np.zeros((s3.height, s3.width, 4), dtype=np.uint8)
    out_s3[:, :, 0] = np.clip(arr_s3[:, :, 0] * 0.7, 10, 35).astype(np.uint8)
    out_s3[:, :, 1] = np.clip(arr_s3[:, :, 1] * 0.7, 10, 35).astype(np.uint8)
    out_s3[:, :, 2] = np.clip(arr_s3[:, :, 2] * 0.7, 12, 40).astype(np.uint8)
    out_s3[:, :, 3] = (burn_alpha3 * 245.0).astype(np.uint8)
    f4_img = Image.fromarray(out_s3)
    
    # 2. Frame 3: Stage 2 (Fresh scorch with warm fissure lines)
    # X: 480 to 880, Y: 270 to 520
    s2 = crater_src.crop((480, 270, 880, 520))
    arr_s2 = np.array(s2.convert('RGB')).astype(np.float32)
    lum2 = np.mean(arr_s2, axis=2)
    burn_alpha2 = np.clip((58.0 - lum2) / 48.0, 0.0, 1.0)
    # Enhance warm embers (where red > green + 15)
    ember_mask2 = (arr_s2[:, :, 0] > arr_s2[:, :, 1] + 15) & (arr_s2[:, :, 0] > 70)
    burn_alpha2[ember_mask2] = 1.0
    burn_alpha2[:6, :] = 0.0
    
    out_s2 = np.zeros((s2.height, s2.width, 4), dtype=np.uint8)
    out_s2[:, :, :3] = np.clip(arr_s2 * 0.85, 0, 255).astype(np.uint8)
    out_s2[ember_mask2, 0] = np.clip(arr_s2[ember_mask2, 0] * 1.2, 0, 255).astype(np.uint8)
    out_s2[ember_mask2, 1] = np.clip(arr_s2[ember_mask2, 1] * 0.9, 0, 255).astype(np.uint8)
    out_s2[:, :, 3] = (burn_alpha2 * 250.0).astype(np.uint8)
    f3_img = Image.fromarray(out_s2)
    
    # 3. Frame 2: Stage 1 (Cooling magma fissures & embers)
    # X: 50 to 440, Y: 260 to 520
    s1 = crater_src.crop((50, 260, 440, 520))
    arr_s1 = np.array(s1.convert('RGB')).astype(np.float32)
    lum1 = np.mean(arr_s1, axis=2)
    burn_alpha1 = np.clip((60.0 - lum1) / 50.0, 0.0, 1.0)
    ember_mask1 = (arr_s1[:, :, 0] > arr_s1[:, :, 1] + 20) & (arr_s1[:, :, 0] > 80)
    burn_alpha1[ember_mask1] = 1.0
    burn_alpha1[:6, :] = 0.0
    
    out_s1 = np.zeros((s1.height, s1.width, 4), dtype=np.uint8)
    out_s1[:, :, :3] = np.clip(arr_s1, 0, 255).astype(np.uint8)
    out_s1[:, :, 3] = (burn_alpha1 * 255.0).astype(np.uint8)
    f2_img = Image.fromarray(out_s1)
    
    # 4. Frame 0: High-energy electric impact burst on ledge
    # From burst_src (platform_warning_ledge_1791201605587.jpg)
    b0_crop = burst_src.crop((705 - 400, 310, 705 + 400, 560))
    arr_b0 = np.array(b0_crop.convert('RGB')).astype(np.float32)
    r, g, b = arr_b0[:, :, 0], arr_b0[:, :, 1], arr_b0[:, :, 2]
    energy0 = np.maximum(g * 1.0 + b * 0.85, r * 1.0)
    alpha0 = np.clip((energy0 - 16.0) / (255.0 - 16.0), 0.0, 1.0)
    alpha0 = np.power(alpha0, 1.1) * 255.0
    out_b0 = np.zeros((b0_crop.height, b0_crop.width, 4), dtype=np.uint8)
    out_b0[:, :, :3] = arr_b0.astype(np.uint8)
    out_b0[:, :, 3] = alpha0.astype(np.uint8)
    f0_img = Image.fromarray(out_b0)
    
    # 5. Frame 1: Sizzling surface arcs on ledge (dissipating)
    arr_b1 = arr_b0.copy()
    alpha1 = alpha0 * 0.65
    out_b1 = np.zeros((b0_crop.height, b0_crop.width, 4), dtype=np.uint8)
    out_b1[:, :, :3] = arr_b1.astype(np.uint8)
    out_b1[:, :, 3] = alpha1.astype(np.uint8)
    f1_img = Image.fromarray(out_b1)
    
    FRAME_W = 256
    FRAME_H = 160
    # Scale width to fit in 256 (around 220 px)
    TARGET_W = 220
    
    master = Image.new("RGBA", (FRAME_W * 5, FRAME_H), (0, 0, 0, 0))
    
    # In Godot, offset is Vector2(-128, -20) or Vector2(-128, -RIM_Y)
    # If the walking rim line is placed at Y = 20 in the frame:
    # Then y = 20 is at world y = 0 (the top of the tile).
    # y = 0..19 is air above the tile (zero or minimal soot).
    # y = 20..159 is the tile body (cracks and charred soot extending down).
    
    # Helper to paste frame:
    def format_frame(img, target_w, rim_y_in_crop, target_rim_y=20):
        scale = target_w / float(img.width)
        new_w = target_w
        new_h = int(img.height * scale)
        resized = img.resize((new_w, new_h), Image.Resampling.LANCZOS)
        
        canvas = Image.new("RGBA", (FRAME_W, FRAME_H), (0, 0, 0, 0))
        px = (FRAME_W - new_w) // 2
        scaled_rim_y = int(rim_y_in_crop * scale)
        py = target_rim_y - scaled_rim_y
        canvas.paste(resized, (px, py), resized)
        return canvas
    
    # In s3, rim line is at y = 8 in crop
    c_f4 = format_frame(f4_img, TARGET_W, 8, target_rim_y=20)
    master.paste(c_f4, (4 * FRAME_W, 0), c_f4)
    
    c_f3 = format_frame(f3_img, TARGET_W, 8, target_rim_y=20)
    master.paste(c_f3, (3 * FRAME_W, 0), c_f3)
    
    c_f2 = format_frame(f2_img, TARGET_W, 8, target_rim_y=20)
    master.paste(c_f2, (2 * FRAME_W, 0), c_f2)
    
    # In b0, rim line is at y = 180 in crop
    c_f0 = format_frame(f0_img, TARGET_W, 180, target_rim_y=20)
    master.paste(c_f0, (0 * FRAME_W, 0), c_f0)
    
    c_f1 = format_frame(f1_img, TARGET_W, 180, target_rim_y=20)
    master.paste(c_f1, (1 * FRAME_W, 0), c_f1)
    
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    master.save(out_path, "PNG")
    print(f"Saved 2D Platformer Scorch Spritesheet: {out_path} ({master.size})")

if __name__ == "__main__":
    brain = r"C:\Users\Lin\.gemini\antigravity\brain\c7718a4a-5c4f-4a83-8604-730ecde0e295"
    base = r"c:\Users\Lin\OneDrive\Pictures\Camera Roll\Documents\project-1-test"
    
    warn_src = os.path.join(brain, "platform_warning_ledge_1791201605587.jpg")
    warn_out = os.path.join(base, "assets", "vfx", "vfx_lightning_warning.png")
    
    crater_src = os.path.join(brain, "platform_crater_scorch_1791201576097.jpg")
    scorch_out = os.path.join(base, "assets", "vfx", "vfx_lightning_scorch.png")
    
    build_2d_platformer_warning(warn_src, warn_out)
    build_2d_platformer_scorch(crater_src, warn_src, scorch_out)
