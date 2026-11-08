import numpy as np
from PIL import Image

# 4x4 Bayer matrix normalized 0..15
BAYER4 = np.array([
    [ 0,  8,  2, 10],
    [12,  4, 14,  6],
    [ 3, 11,  1,  9],
    [15,  7, 13,  5]
], dtype=float) / 16.0

# 8x8 Bayer matrix
BAYER8 = np.array([
    [ 0, 32,  8, 40,  2, 34, 10, 42],
    [48, 16, 56, 24, 50, 18, 58, 26],
    [12, 44,  4, 36, 14, 46,  6, 38],
    [60, 28, 52, 20, 62, 30, 54, 22],
    [ 3, 35, 11, 43,  1, 33,  9, 41],
    [51, 19, 59, 27, 49, 17, 57, 25],
    [15, 47,  7, 39, 13, 45,  5, 37],
    [63, 31, 55, 23, 61, 29, 53, 21]
], dtype=float) / 64.0

def create_bayer_gradient_v(width, height, color_top, color_bottom, alpha_top=0.0, alpha_bottom=0.94):
    """Vertical dither gradient from transparent top to solid dark bottom"""
    img = np.zeros((height, width, 4), dtype=np.uint8)
    for y in range(height):
        # Progress 0 at top, 1 at bottom
        t = y / float(height - 1)
        # Apply smooth S-curve
        t_curve = t * t * (3.0 - 2.0 * t)
        target_a = alpha_top + (alpha_bottom - alpha_top) * t_curve
        col = np.array(color_top) * (1.0 - t) + np.array(color_bottom) * t
        
        for x in range(width):
            b_val = BAYER8[y % 8, x % 8]
            # Ordered dither for alpha transition
            # Add subtle dither noise around threshold
            threshold_a = target_a + (b_val - 0.5) * 0.35
            a_clamped = np.clip(threshold_a, 0.0, 1.0)
            
            # If target_a is high, make it mostly opaque with slight texture
            final_a = int(round(a_clamped * 255.0))
            img[y, x] = [int(col[0]), int(col[1]), int(col[2]), final_a]
    return Image.fromarray(img)

# 1. Lower third gradient for cutscenes: 640x120
# Charcoal base: #101412 (16, 20, 18)
cutscene_grad = create_bayer_gradient_v(640, 120, [16, 20, 18], [14, 17, 16], alpha_top=0.0, alpha_bottom=0.96)
cutscene_grad.save('assets/ui/cutscene_lower_gradient.png')
print('Saved assets/ui/cutscene_lower_gradient.png')

# 2. Level title card gradient: 300x64 (horizontal and vertical fade: dark on left, fading to transparent on right)
def create_title_card_gradient(width, height):
    img = np.zeros((height, width, 4), dtype=np.uint8)
    for y in range(height):
        for x in range(width):
            # Horizontal fade: 1.0 at x=0..80, fading to 0.0 at x=280..300
            t_x = np.clip(1.0 - (x - 60) / 220.0, 0.0, 1.0)
            # Subtle top/bottom edge softening
            t_y = np.sin((y / float(height - 1)) * np.pi)
            target_a = 0.88 * t_x * (0.6 + 0.4 * t_y)
            
            b_val = BAYER8[y % 8, x % 8]
            dithered_a = target_a + (b_val - 0.5) * 0.25
            final_a = int(round(np.clip(dithered_a, 0.0, 1.0) * 255.0))
            img[y, x] = [16, 20, 18, final_a]
    return Image.fromarray(img)

title_grad = create_title_card_gradient(300, 64)
title_grad.save('assets/ui/title_card_gradient.png')
print('Saved assets/ui/title_card_gradient.png')
