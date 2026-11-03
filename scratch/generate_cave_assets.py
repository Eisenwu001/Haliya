"""
High-Fidelity Cave Platformer Asset Generator for Haliya: Mask of Sorrows
Generates:
1. assets/cave_platformer/cave_rock_tiles.png (256x128)
2. assets/cave_platformer/cave_platforms.png (256x160)
3. assets/cave_platformer/cave_props.png (256x160)

Color palette and artistic direction directly sampled and harmonized with
assets/Cave/BG-Parallax/ (Layer 9 midnight-slate bedrock, Layer 7 deep teal,
Layer 1 glowing cyan/turquoise, and volumetric god-ray luminances).
"""

import math
import random
from PIL import Image, ImageDraw, ImageFilter
import numpy as np

# Seed for reproducible organic rock details
random.seed(42)
np.random.seed(42)

# ── Color Palette (Extracted & Harmonized from Cave BG-Parallax) ─────────────
PALETTE = {
    "deep_void": (2, 18, 30, 255),
    "bedrock_dark": (4, 38, 59, 255),
    "bedrock_mid": (6, 48, 72, 255),
    "bedrock_light": (10, 68, 98, 255),
    "strata_accent": (14, 88, 122, 255),
    "rim_highlight": (22, 128, 168, 255),
    "rim_specular": (56, 196, 224, 255),
    
    # Glowing Cyan / Lumafly / Resonant Crystal
    "crystal_deep": (12, 64, 110, 255),
    "crystal_mid": (0, 140, 200, 255),
    "crystal_cyan": (0, 229, 255, 255),
    "crystal_bright": (120, 245, 255, 255),
    "crystal_core": (220, 255, 255, 255),
    "crystal_glow": (0, 200, 255, 120),
    
    # Forged Wrought-Iron Metal & Chains
    "iron_dark": (8, 16, 24, 255),
    "iron_mid": (18, 30, 42, 255),
    "iron_light": (36, 54, 72, 255),
    "iron_rim": (70, 110, 138, 255),
    "iron_specular": (140, 185, 210, 255),
    
    # Crumble Stress / Violet-Cyan Fissures
    "fissure_core": (180, 255, 255, 255),
    "fissure_cyan": (0, 235, 255, 240),
    "fissure_violet": (120, 70, 220, 200),
    
    # Translucent Glass & Motes
    "glass_tint": (40, 120, 160, 90),
    "glass_specular": (200, 245, 255, 160),
    "lumafly_amber": (255, 240, 180, 255),
}


def create_supersampled_canvas(w, h, scale=4):
    """Creates a high-res image canvas for rendering sub-pixel antialiased details."""
    return Image.new("RGBA", (w * scale, h * scale), (0, 0, 0, 0)), scale


def downscale_canvas(img, scale=4):
    """Downscales the canvas back to native target resolution with high quality lanczos/box."""
    return img.resize((img.width // scale, img.height // scale), Image.Resampling.LANCZOS)


# ═════════════════════════════════════════════════════════════════════════════
# 1. GENERATE CAVE ROCK TILES (256x128)
# ═════════════════════════════════════════════════════════════════════════════
def generate_rock_tiles():
    target_w, target_h = 256, 128
    hi_img, S = create_supersampled_canvas(target_w, target_h, scale=4)
    draw = ImageDraw.Draw(hi_img)
    
    def sc(x, y):
        return (x * S, y * S)
    
    def sc_rect(x, y, w, h):
        return [x * S, y * S, (x + w) * S, (y + h) * S]

    # Helper: draw textured bedrock slab
    def draw_bedrock_slab(bx, by, bw, bh, is_left_edge=False, is_right_edge=False, has_runes=True, crack_seed=0):
        # Base polygon
        pts = []
        # Top edge with subtle chiseled bevel
        top_y = by + 2
        pts.append((bx, top_y + (4 if is_left_edge else 0)))
        if is_left_edge:
            pts.append((bx + 3, top_y))
        pts.append((bx + bw - (3 if is_right_edge else 0), top_y))
        if is_right_edge:
            pts.append((bx + bw, top_y + 4))
        pts.append((bx + bw, by + bh))
        pts.append((bx, by + bh))
        
        scaled_pts = [(p[0] * S, p[1] * S) for p in pts]
        draw.polygon(scaled_pts, fill=PALETTE["bedrock_dark"])
        
        # Horizontal strata layers
        for row in range(3, bh - 1, 4):
            strata_col = PALETTE["bedrock_mid"] if (row + crack_seed) % 8 == 3 else PALETTE["bedrock_light"]
            lx1 = bx + (1 if not is_left_edge else 3)
            lx2 = bx + bw - (1 if not is_right_edge else 3)
            draw.line([(lx1 * S, (by + row) * S), (lx2 * S, (by + row) * S)], fill=strata_col, width=S)
            # Subtle jitter
            if (row + crack_seed) % 3 == 0:
                jx = bx + 6 + ((crack_seed * 7 + row * 5) % (bw - 12))
                draw.rectangle(sc_rect(jx, by + row - 1, 4, 3), fill=PALETTE["strata_accent"])
        
        # Top chiseled rim highlight
        rx1 = bx + (3 if is_left_edge else 0)
        rx2 = bx + bw - (3 if is_right_edge else 0)
        draw.line([(rx1 * S, (top_y * S)), (rx2 * S, (top_y * S))], fill=PALETTE["rim_specular"], width=max(1, S))
        draw.line([(rx1 * S, (top_y + 1) * S), (rx2 * S, (top_y + 1) * S)], fill=PALETTE["rim_highlight"], width=max(1, S))
        
        # Outer beveled edges
        if is_left_edge:
            draw.line([(bx * S, (top_y + 4) * S), ((bx + 3) * S, top_y * S)], fill=PALETTE["rim_specular"], width=max(1, S))
            draw.line([(bx * S, (top_y + 4) * S), (bx * S, (by + bh) * S)], fill=PALETTE["bedrock_light"], width=max(1, S))
        if is_right_edge:
            draw.line([((bx + bw - 3) * S, top_y * S), ((bx + bw) * S, (top_y + 4) * S)], fill=PALETTE["rim_highlight"], width=max(1, S))
            draw.line([((bx + bw) * S, (top_y + 4) * S), ((bx + bw) * S, (by + bh) * S)], fill=PALETTE["deep_void"], width=max(1, S))
        
        # Glowing cyan rune inlays
        if has_runes:
            rune_cx = bx + bw * 0.5
            rune_cy = by + 9
            # Crescent or diamond rune
            if crack_seed % 2 == 0:
                # Small diamond rune
                r_pts = [
                    (rune_cx * S, (rune_cy - 3) * S),
                    ((rune_cx + 4) * S, rune_cy * S),
                    (rune_cx * S, (rune_cy + 3) * S),
                    ((rune_cx - 4) * S, rune_cy * S),
                ]
                draw.polygon(r_pts, outline=PALETTE["crystal_cyan"], fill=PALETTE["crystal_deep"], width=max(1, S // 2))
                draw.rectangle(sc_rect(rune_cx - 1, rune_cy - 1, 2, 2), fill=PALETTE["crystal_core"])
            else:
                # Inscribed lunar crescent
                draw.arc(sc_rect(rune_cx - 4, rune_cy - 3, 8, 7), 60, 300, fill=PALETTE["crystal_cyan"], width=max(1, S))
                draw.point((rune_cx * S, rune_cy * S), fill=PALETTE["crystal_core"])

    # --- ROW 0 (y = 0..32): Top Ground Slabs ---
    draw_bedrock_slab(0, 0, 32, 32, is_left_edge=True, is_right_edge=False, has_runes=True, crack_seed=1)
    draw_bedrock_slab(32, 0, 32, 32, is_left_edge=False, is_right_edge=False, has_runes=True, crack_seed=2)
    draw_bedrock_slab(64, 0, 32, 32, is_left_edge=False, is_right_edge=True, has_runes=True, crack_seed=3)

    # --- Carved Ancient Ruin Pillar (96, 0, 32, 96) ---
    px, py, pw, ph = 96, 0, 32, 96
    # Base shaft
    draw.rectangle(sc_rect(px + 4, py + 14, pw - 8, ph - 28), fill=PALETTE["bedrock_dark"])
    # Fluted vertical grooves
    for col_x in [px + 8, px + 14, px + 20, px + 26]:
        draw.line([(col_x * S, (py + 15) * S), (col_x * S, (py + ph - 15) * S)], fill=PALETTE["bedrock_mid"], width=max(1, S))
        draw.line([((col_x + 1) * S, (py + 15) * S), ((col_x + 1) * S, (py + ph - 15) * S)], fill=PALETTE["bedrock_light"], width=max(1, S))
    # Capital (top molding)
    draw.polygon([
        sc(px + 1, py + 1), sc(px + pw - 1, py + 1),
        sc(px + pw - 3, py + 6), sc(px + 3, py + 6)
    ], fill=PALETTE["rim_specular"])
    draw.rectangle(sc_rect(px + 2, py + 6, pw - 4, 8), fill=PALETTE["bedrock_mid"], outline=PALETTE["rim_highlight"], width=max(1, S // 2))
    # Glowing gem in capital center
    draw.rectangle(sc_rect(px + 14, py + 8, 4, 4), fill=PALETTE["crystal_cyan"])
    draw.rectangle(sc_rect(px + 15, py + 9, 2, 2), fill=PALETTE["crystal_core"])
    
    # Plinth Base (bottom molding)
    draw.rectangle(sc_rect(px + 2, py + ph - 14, pw - 4, 6), fill=PALETTE["bedrock_mid"], outline=PALETTE["bedrock_light"], width=max(1, S // 2))
    draw.polygon([
        sc(px + 1, py + ph - 8), sc(px + pw - 1, py + ph - 8),
        sc(px + pw, py + ph - 1), sc(px, py + ph - 1)
    ], fill=PALETTE["bedrock_dark"])
    draw.line([sc(px, py + ph - 1), sc(px + pw, py + ph - 1)], fill=PALETTE["deep_void"], width=max(1, S))
    
    # Spiraling etched glowing runes up the shaft
    for r_y in [py + 25, py + 42, py + 58, py + 72]:
        draw.arc(sc_rect(px + 9, r_y - 3, 14, 7), 30, 240, fill=PALETTE["crystal_cyan"], width=max(1, S))
        draw.rectangle(sc_rect(px + 15, r_y, 2, 2), fill=PALETTE["crystal_core"])

    # --- Ashlar Masonry Blocks (128..256, 0, 32, 32) ---
    for mi, mx in enumerate([128, 160, 192, 224]):
        draw.rectangle(sc_rect(mx, 0, 32, 32), fill=PALETTE["bedrock_dark"])
        # Mortar lines
        draw.line([sc(mx, 16), sc(mx + 32, 16)], fill=PALETTE["deep_void"], width=max(1, S))
        draw.line([sc(mx + 16, 0), sc(mx + 16, 16)], fill=PALETTE["deep_void"], width=max(1, S))
        draw.line([sc(mx + 8, 16), sc(mx + 8, 32)], fill=PALETTE["deep_void"], width=max(1, S))
        draw.line([sc(mx + 24, 16), sc(mx + 24, 32)], fill=PALETTE["deep_void"], width=max(1, S))
        # Top bevel
        draw.line([sc(mx, 1), sc(mx + 32, 1)], fill=PALETTE["rim_highlight"], width=max(1, S))
        
        # Variation details
        if mi == 0:
            # Weathered cracked stone
            draw.line([sc(mx + 4, 4), sc(mx + 12, 11)], fill=PALETTE["rim_specular"], width=max(1, S // 2))
        elif mi == 1:
            # Embedded raw cyan crystal nodule
            c_pts = [sc(mx + 14, 20), sc(mx + 19, 23), sc(mx + 17, 28), sc(mx + 12, 26)]
            draw.polygon(c_pts, fill=PALETTE["crystal_cyan"])
            draw.point(sc(mx + 16, 24), fill=PALETTE["crystal_core"])
        elif mi == 2:
            # Crescent lunar crest
            draw.arc(sc_rect(mx + 10, 5, 12, 10), 45, 290, fill=PALETTE["crystal_cyan"], width=max(1, S))
        elif mi == 3:
            # Hexagonal rune medallion
            draw.polygon([
                sc(mx + 16, 6), sc(mx + 21, 9), sc(mx + 21, 14),
                sc(mx + 16, 17), sc(mx + 11, 14), sc(mx + 11, 9)
            ], outline=PALETTE["crystal_cyan"], fill=PALETTE["crystal_deep"], width=max(1, S // 2))

    # --- ROW 1 (y = 32..64): Subterranean Bedrock Strata ---
    for bi, bx in enumerate([0, 32, 64, 128, 160, 192, 224]):
        draw.rectangle(sc_rect(bx, 32, 32, 32), fill=PALETTE["bedrock_dark"])
        # Organic horizontal strata lines
        for sy in [36, 42, 48, 54, 60]:
            col = PALETTE["bedrock_mid"] if (sy + bi * 3) % 2 == 0 else PALETTE["bedrock_light"]
            draw.line([sc(bx, sy), sc(bx + 32, sy)], fill=col, width=max(1, S))
        # Diagonal crystal veins branching through bedrock
        if bi in [1, 3, 5]:
            v_pts = [
                sc(bx + 4, 38), sc(bx + 14, 44), sc(bx + 18, 52), sc(bx + 28, 58)
            ]
            draw.line(v_pts, fill=PALETTE["crystal_cyan"], width=max(1, S))
            draw.rectangle(sc_rect(bx + 14, 43, 2, 2), fill=PALETTE["crystal_core"])

    # --- ROW 2 (y = 64..96): Underbelly & Stalactite Teeth ---
    # Left underbelly corner (tapers right)
    draw.polygon([
        sc(0, 64), sc(32, 64), sc(24, 76), sc(16, 88), sc(8, 74), sc(0, 68)
    ], fill=PALETTE["bedrock_dark"])
    draw.line([sc(0, 64), sc(16, 88)], fill=PALETTE["rim_highlight"], width=max(1, S))
    
    # Middle underbelly: 3 hanging stalactites (32..64, 64..96)
    draw.rectangle(sc_rect(32, 64, 32, 6), fill=PALETTE["bedrock_dark"])
    # Stalactite 1
    draw.polygon([sc(34, 70), sc(42, 70), sc(38, 92)], fill=PALETTE["bedrock_mid"])
    draw.line([sc(34, 70), sc(38, 92)], fill=PALETTE["rim_highlight"], width=max(1, S))
    draw.point(sc(38, 92), fill=PALETTE["rim_specular"]) # glistening water droplet
    # Stalactite 2 (longest)
    draw.polygon([sc(44, 70), sc(54, 70), sc(49, 95)], fill=PALETTE["bedrock_dark"])
    draw.line([sc(44, 70), sc(49, 95)], fill=PALETTE["rim_highlight"], width=max(1, S))
    draw.point(sc(49, 95), fill=PALETTE["crystal_cyan"])
    # Stalactite 3
    draw.polygon([sc(56, 70), sc(62, 70), sc(59, 86)], fill=PALETTE["bedrock_light"])
    
    # Right underbelly corner (tapers left)
    draw.polygon([
        sc(64, 64), sc(96, 64), sc(96, 68), sc(88, 74), sc(80, 88), sc(72, 76)
    ], fill=PALETTE["bedrock_dark"])
    draw.line([sc(96, 64), sc(80, 88)], fill=PALETTE["deep_void"], width=max(1, S))

    return downscale_canvas(hi_img, S)


# ═════════════════════════════════════════════════════════════════════════════
# 2. GENERATE CAVE PLATFORMS (256x160)
# ═════════════════════════════════════════════════════════════════════════════
def generate_platforms():
    target_w, target_h = 256, 160
    hi_img, S = create_supersampled_canvas(target_w, target_h, scale=4)
    draw = ImageDraw.Draw(hi_img)
    
    def sc(x, y):
        return (x * S, y * S)
    
    def sc_rect(x, y, w, h):
        return [x * S, y * S, (x + w) * S, (y + h) * S]

    # --- 1. Large Cavern Island ("island_lg", 0, 0, 128, 64) ---
    ix, iy, iw, ih = 0, 0, 128, 64
    # Top landing surface (flat at y = 8..12)
    deck_y = iy + 8
    # Organic jagged rock polygon tapering down into hanging stalactite clusters
    island_pts = [
        (ix + 6, deck_y + 2),
        (ix + 10, deck_y),
        (ix + iw - 10, deck_y),
        (ix + iw - 6, deck_y + 2),
        (ix + iw - 8, deck_y + 16),
        (ix + iw - 16, deck_y + 30),
        (ix + iw - 26, deck_y + 44),
        (ix + iw - 38, deck_y + 58), # Right stalactite tip
        (ix + iw - 46, deck_y + 42),
        (ix + 64, deck_y + 60),      # Center deep stalactite tip
        (ix + 52, deck_y + 46),
        (ix + 38, deck_y + 54),      # Left stalactite tip
        (ix + 24, deck_y + 36),
        (ix + 12, deck_y + 20),
    ]
    draw.polygon([(p[0] * S, p[1] * S) for p in island_pts], fill=PALETTE["bedrock_dark"])
    
    # Shading & strata bands
    for layer_i in range(1, 4):
        inset_pts = [
            (p[0] * 0.92 + (ix + 64) * 0.08, p[1] * 0.90 + (deck_y + 12) * 0.10)
            for p in island_pts[4:-1]
        ]
        inset_pts = [(ix + 14, deck_y + 12)] + inset_pts + [(ix + iw - 14, deck_y + 12)]
        col = PALETTE["bedrock_mid"] if layer_i == 1 else PALETTE["bedrock_light"]
        draw.polygon([(p[0] * S, p[1] * S) for p in inset_pts], fill=col)
    
    # Top carved stone slab with cyan edge trim
    draw.rectangle(sc_rect(ix + 8, deck_y, iw - 16, 4), fill=PALETTE["bedrock_mid"])
    draw.line([sc(ix + 8, deck_y), sc(ix + iw - 8, deck_y)], fill=PALETTE["rim_specular"], width=max(1, S))
    draw.line([sc(ix + 8, deck_y + 1), sc(ix + iw - 8, deck_y + 1)], fill=PALETTE["rim_highlight"], width=max(1, S))
    
    # Glowing crystal clusters embedded in the underside
    for cx, cy in [(ix + 40, deck_y + 32), (ix + 84, deck_y + 28), (ix + 62, deck_y + 40)]:
        draw.polygon([
            sc(cx, cy), sc(cx + 6, cy - 4), sc(cx + 10, cy + 4), sc(cx + 2, cy + 8)
        ], fill=PALETTE["crystal_cyan"])
        draw.point(sc(cx + 5, cy), fill=PALETTE["crystal_core"])
        
    # Dual wrought-iron chain anchor shackles on top
    for ax in [ix + 18, ix + iw - 22]:
        draw.arc(sc_rect(ax - 3, deck_y - 6, 7, 8), 180, 360, fill=PALETTE["iron_light"], width=max(1, S))
        draw.arc(sc_rect(ax - 3, deck_y - 6, 7, 8), 180, 360, fill=PALETTE["iron_rim"], width=max(1, S // 2))
        draw.rectangle(sc_rect(ax - 4, deck_y - 1, 9, 3), fill=PALETTE["iron_dark"], outline=PALETTE["iron_mid"])

    # --- 2. Medium Cavern Island ("island_md", 128, 0, 96, 56) ---
    mx, my, mw, mh = 128, 0, 96, 56
    m_deck = my + 8
    m_pts = [
        (mx + 6, m_deck + 2),
        (mx + 10, m_deck),
        (mx + mw - 10, m_deck),
        (mx + mw - 6, m_deck + 2),
        (mx + mw - 8, m_deck + 16),
        (mx + mw - 18, m_deck + 34),
        (mx + mw - 28, m_deck + 52), # Right tip
        (mx + 48, m_deck + 48),      # Center tip
        (mx + 28, m_deck + 50),      # Left tip
        (mx + 14, m_deck + 30),
        (mx + 8, m_deck + 16),
    ]
    draw.polygon([(p[0] * S, p[1] * S) for p in m_pts], fill=PALETTE["bedrock_dark"])
    # Shading
    m_inset = [
        (p[0] * 0.88 + (mx + 48) * 0.12, p[1] * 0.88 + (m_deck + 10) * 0.12)
        for p in m_pts[4:-1]
    ]
    draw.polygon([(mx + 12, m_deck + 8)] + [(p[0] * S, p[1] * S) for p in m_inset] + [(mx + mw - 12, m_deck + 8)], fill=PALETTE["bedrock_mid"])
    # Deck
    draw.line([sc(mx + 8, m_deck), sc(mx + mw - 8, m_deck)], fill=PALETTE["rim_specular"], width=max(1, S))
    draw.line([sc(mx + 8, m_deck + 1), sc(mx + mw - 8, m_deck + 1)], fill=PALETTE["rim_highlight"], width=max(1, S))
    # Center chain shackle
    draw.arc(sc_rect(mx + 45, m_deck - 6, 7, 8), 180, 360, fill=PALETTE["iron_light"], width=max(1, S))
    draw.rectangle(sc_rect(mx + 44, m_deck - 1, 9, 3), fill=PALETTE["iron_dark"])

    # --- 3. Wrought-Iron Ruin Bridge ("bridge", 0, 64, 128, 40) ---
    bx, by, bw, bh = 0, 64, 128, 40
    b_deck = by + 6
    # Walking deck slab
    draw.rectangle(sc_rect(bx + 4, b_deck, bw - 8, 5), fill=PALETTE["iron_dark"])
    draw.line([sc(bx + 4, b_deck), sc(bx + bw - 4, b_deck)], fill=PALETTE["rim_specular"], width=max(1, S))
    # Gothic arch under-trusses
    num_arches = 4
    arch_w = (bw - 12) / num_arches
    for ai in range(num_arches):
        ax1 = bx + 6 + ai * arch_w
        ax2 = ax1 + arch_w
        acx = (ax1 + ax2) * 0.5
        # Gothic pointed arch curve
        arch_pts = [
            sc(ax1, b_deck + 5),
            sc(ax1 + 3, b_deck + 16),
            sc(acx, b_deck + 28), # Arch apex hanging down
            sc(ax2 - 3, b_deck + 16),
            sc(ax2, b_deck + 5),
        ]
        draw.line(arch_pts, fill=PALETTE["iron_light"], width=max(1, S))
        # Decorative vertical strut
        draw.line([sc(acx, b_deck + 5), sc(acx, b_deck + 28)], fill=PALETTE["iron_mid"], width=max(1, S // 2))
        # Glowing cyan crystal rivet at arch apex
        draw.rectangle(sc_rect(acx - 1, b_deck + 27, 3, 3), fill=PALETTE["crystal_cyan"])
    # End support masonry pillars
    draw.rectangle(sc_rect(bx + 2, b_deck - 2, 6, 24), fill=PALETTE["bedrock_dark"], outline=PALETTE["rim_highlight"], width=max(1, S // 2))
    draw.rectangle(sc_rect(bx + bw - 8, b_deck - 2, 6, 24), fill=PALETTE["bedrock_dark"], outline=PALETTE["rim_highlight"], width=max(1, S // 2))

    # --- 4. Crumbling Ancient Stone Ledge ("crumble", 128, 64, 96, 48) ---
    cx, cy, cw, ch = 128, 64, 96, 48
    c_deck = cy + 4
    # Fractured polygon
    c_pts = [
        (cx + 4, c_deck + 2), (cx + 8, c_deck), (cx + cw - 8, c_deck), (cx + cw - 4, c_deck + 2),
        (cx + cw - 6, c_deck + 14), (cx + cw - 14, c_deck + 28), (cx + cw - 26, c_deck + 40),
        (cx + 48, c_deck + 36), (cx + 28, c_deck + 42), (cx + 12, c_deck + 26), (cx + 6, c_deck + 14)
    ]
    draw.polygon([(p[0] * S, p[1] * S) for p in c_pts], fill=PALETTE["bedrock_dark"])
    # Top rim
    draw.line([sc(cx + 8, c_deck), sc(cx + cw - 8, c_deck)], fill=PALETTE["rim_highlight"], width=max(1, S))
    
    # Glowing electric-cyan/violet stress fissures through the stone
    fissures = [
        # Crack 1
        [(cx + 18, c_deck), (cx + 22, c_deck + 12), (cx + 16, c_deck + 24), (cx + 24, c_deck + 38)],
        # Crack 2 (major central split)
        [(cx + 46, c_deck), (cx + 52, c_deck + 14), (cx + 48, c_deck + 26), (cx + 54, c_deck + 42)],
        # Crack 3
        [(cx + 72, c_deck), (cx + 68, c_deck + 16), (cx + 76, c_deck + 30)],
    ]
    for fissure in fissures:
        scaled_f = [(p[0] * S, p[1] * S) for p in fissure]
        # Outer glow
        draw.line(scaled_f, fill=PALETTE["fissure_violet"], width=max(1, S * 2))
        # Cyan vein
        draw.line(scaled_f, fill=PALETTE["fissure_cyan"], width=max(1, S))
        # Core spark
        draw.line(scaled_f, fill=PALETTE["fissure_core"], width=max(1, S // 2))

    # --- 5. Boss Sanctuary Platform ("sanctuary", 0, 104, 160, 56) ---
    sx, sy, sw, sh = 0, 104, 160, 56
    s_deck = sy + 6
    # Wide ceremonial stone platform with ornate stepped trim
    draw.rectangle(sc_rect(sx + 6, s_deck, sw - 12, 10), fill=PALETTE["bedrock_mid"])
    # Polished obsidian top slab
    draw.rectangle(sc_rect(sx + 8, s_deck, sw - 16, 4), fill=PALETTE["deep_void"])
    draw.line([sc(sx + 8, s_deck), sc(sx + sw - 8, s_deck)], fill=PALETTE["rim_specular"], width=max(1, S))
    
    # Running lunar glyph trim along the rim
    for gx in range(sx + 14, sx + sw - 16, 12):
        draw.arc(sc_rect(gx, s_deck + 5, 6, 4), 0, 360, fill=PALETTE["crystal_cyan"], width=max(1, S // 2))
        draw.point(sc(gx + 3, s_deck + 7), fill=PALETTE["crystal_core"])
    
    # Bedrock under-mass with stalactite fringe
    sanct_base_pts = [
        (sx + 10, s_deck + 10),
        (sx + sw - 10, s_deck + 10),
        (sx + sw - 14, s_deck + 26),
        (sx + sw - 28, s_deck + 44),
        (sx + sw - 42, s_deck + 34),
        (sx + 80, s_deck + 50), # Center stalactite
        (sx + 42, s_deck + 34),
        (sx + 28, s_deck + 44),
        (sx + 14, s_deck + 26),
    ]
    draw.polygon([(p[0] * S, p[1] * S) for p in sanct_base_pts], fill=PALETTE["bedrock_dark"])
    
    # Dual heavy chain anchor eyelets
    for shackle_x in [sx + 22, sx + sw - 26]:
        draw.arc(sc_rect(shackle_x - 4, s_deck - 6, 8, 9), 180, 360, fill=PALETTE["iron_light"], width=max(1, S))
        draw.rectangle(sc_rect(shackle_x - 5, s_deck - 1, 10, 3), fill=PALETTE["iron_dark"])

    return downscale_canvas(hi_img, S)


# ═════════════════════════════════════════════════════════════════════════════
# 3. GENERATE CAVE PROPS (256x160)
# ═════════════════════════════════════════════════════════════════════════════
def generate_props():
    target_w, target_h = 256, 160
    hi_img, S = create_supersampled_canvas(target_w, target_h, scale=4)
    draw = ImageDraw.Draw(hi_img)
    
    def sc(x, y):
        return (x * S, y * S)
    
    def sc_rect(x, y, w, h):
        return [x * S, y * S, (x + w) * S, (y + h) * S]

    # --- 1. Hollow Knight Lumafly Streetlamp ("streetlamp", 0, 0, 64, 96) ---
    lx, ly, lw, lh = 0, 0, 64, 96
    # Pole center at x = 32
    pcx = lx + 32
    # Heavy bolted iron base (y = 86..94)
    draw.polygon([
        sc(pcx - 12, ly + 94), sc(pcx + 12, ly + 94),
        sc(pcx + 6, ly + 86), sc(pcx - 6, ly + 86)
    ], fill=PALETTE["iron_dark"])
    draw.line([sc(pcx - 12, ly + 94), sc(pcx + 12, ly + 94)], fill=PALETTE["iron_light"], width=max(1, S))
    # Bolted rivets
    draw.point(sc(pcx - 8, ly + 91), fill=PALETTE["iron_specular"])
    draw.point(sc(pcx + 8, ly + 91), fill=PALETTE["iron_specular"])
    
    # Slender vertical wrought-iron pole with decorative spiral knot
    draw.line([sc(pcx, ly + 36), sc(pcx, ly + 86)], fill=PALETTE["iron_mid"], width=max(1, S * 2))
    draw.line([sc(pcx - 1, ly + 36), sc(pcx - 1, ly + 86)], fill=PALETTE["iron_light"], width=max(1, S))
    # Mid-pole decorative knot & leaf bracket
    draw.rectangle(sc_rect(pcx - 4, ly + 60, 9, 5), fill=PALETTE["iron_light"], outline=PALETTE["iron_dark"])
    
    # Elegant curved swan-neck lantern arm arching out to x = 42
    arm_pts = [
        sc(pcx, ly + 40),
        sc(pcx + 4, ly + 26),
        sc(pcx + 12, ly + 14),
        sc(pcx + 22, ly + 14),
        sc(pcx + 24, ly + 22)
    ]
    draw.line(arm_pts, fill=PALETTE["iron_light"], width=max(1, S * 2))
    # Scrollwork bracket
    draw.arc(sc_rect(pcx, ly + 20, 16, 16), 180, 315, fill=PALETTE["iron_rim"], width=max(1, S))
    
    # Lantern Housing centered at x = 44, y = 22..52
    hx, hy = pcx + 12, ly + 22
    # Lantern Roof (pointed hexagonal cap)
    draw.polygon([
        sc(hx - 10, hy + 6), sc(hx + 10, hy + 6),
        sc(hx + 6, hy), sc(hx - 6, hy)
    ], fill=PALETTE["iron_dark"])
    draw.line([sc(hx - 10, hy + 6), sc(hx + 10, hy + 6)], fill=PALETTE["iron_specular"], width=max(1, S))
    
    # Glass Bell Jar (semi-translucent with radial lumafly core)
    draw.ellipse(sc_rect(hx - 9, hy + 6, 18, 20), fill=PALETTE["glass_tint"], outline=PALETTE["iron_mid"], width=max(1, S))
    # Inner radiant Lumafly / Spirit Orb!
    draw.ellipse(sc_rect(hx - 6, hy + 9, 12, 14), fill=PALETTE["crystal_glow"])
    draw.ellipse(sc_rect(hx - 4, hy + 11, 8, 10), fill=PALETTE["crystal_cyan"])
    draw.ellipse(sc_rect(hx - 2, hy + 13, 5, 6), fill=PALETTE["crystal_core"])
    # Glass specular glint
    draw.arc(sc_rect(hx - 8, hy + 7, 16, 18), 200, 260, fill=PALETTE["glass_specular"], width=max(1, S))
    
    # Lantern Bottom Cage & Finial
    draw.polygon([
        sc(hx - 7, hy + 26), sc(hx + 7, hy + 26),
        sc(hx, hy + 33)
    ], fill=PALETTE["iron_dark"])
    draw.point(sc(hx, hy + 33), fill=PALETTE["crystal_cyan"])

    # --- 2. Hanging Wrought-Iron Chain ("chain", 64, 0, 32, 128) ---
    cx, cy, cw, ch = 64, 0, 32, 128
    chain_x = cx + 16
    link_h = 14
    for li in range(ch // link_h + 1):
        ly_pos = cy + li * link_h
        if li % 2 == 0:
            # Vertical link (elongated oval)
            draw.ellipse(sc_rect(chain_x - 4, ly_pos, 8, 13), outline=PALETTE["iron_light"], width=max(1, S))
            draw.line([sc(chain_x - 3, ly_pos + 2), sc(chain_x - 3, ly_pos + 11)], fill=PALETTE["iron_specular"], width=max(1, S // 2))
        else:
            # Horizontal link (turned edge-on)
            draw.ellipse(sc_rect(chain_x - 3, ly_pos + 1, 6, 11), outline=PALETTE["iron_mid"], fill=PALETTE["iron_dark"], width=max(1, S))

    # --- 3. Resonant Pogo Crystal Bloom ("pogo_crystal", 96, 0, 64, 48) ---
    # Centered at (128, 24)
    px, py, pw, ph = 96, 0, 64, 48
    pcx, pcy = px + 32, py + 26
    
    # Outer ambient crystal glow aura
    draw.ellipse(sc_rect(pcx - 22, pcy - 20, 44, 40), fill=(0, 229, 255, 35))
    draw.ellipse(sc_rect(pcx - 16, pcy - 15, 32, 30), fill=(0, 229, 255, 60))
    
    # Flanking Crystal Prisms (branching left & right)
    # Left flank crystal
    draw.polygon([
        sc(pcx - 12, pcy + 10), sc(pcx - 24, pcy - 2), sc(pcx - 16, pcy - 14), sc(pcx - 6, pcy - 2)
    ], fill=PALETTE["crystal_deep"], outline=PALETTE["crystal_mid"], width=max(1, S // 2))
    draw.line([sc(pcx - 24, pcy - 2), sc(pcx - 16, pcy - 14)], fill=PALETTE["crystal_cyan"], width=max(1, S))
    
    # Right flank crystal
    draw.polygon([
        sc(pcx + 12, pcy + 10), sc(pcx + 24, pcy - 2), sc(pcx + 16, pcy - 14), sc(pcx + 6, pcy - 2)
    ], fill=PALETTE["crystal_deep"], outline=PALETTE["crystal_mid"], width=max(1, S // 2))
    draw.line([sc(pcx + 16, pcy - 14), sc(pcx + 24, pcy - 2)], fill=PALETTE["crystal_cyan"], width=max(1, S))

    # Main Central Bipyramidal Crystal (Tall Hexagonal Prism)
    # Top apex at (pcx, pcy - 22), Bottom apex at (pcx, pcy + 18)
    # Left facet
    draw.polygon([
        sc(pcx, pcy - 22), sc(pcx - 10, pcy - 4), sc(pcx - 8, pcy + 12), sc(pcx, pcy + 18)
    ], fill=PALETTE["crystal_mid"])
    # Center facet (brightest face)
    draw.polygon([
        sc(pcx, pcy - 22), sc(pcx + 6, pcy - 4), sc(pcx + 4, pcy + 12), sc(pcx, pcy + 18)
    ], fill=PALETTE["crystal_cyan"])
    # Right facet
    draw.polygon([
        sc(pcx + 6, pcy - 4), sc(pcx + 11, pcy - 2), sc(pcx + 9, pcy + 10), sc(pcx + 4, pcy + 12)
    ], fill=PALETTE["crystal_deep"])
    
    # Sharp specular facet edges & diamond core
    draw.line([sc(pcx, pcy - 22), sc(pcx, pcy + 18)], fill=PALETTE["crystal_core"], width=max(1, S))
    draw.line([sc(pcx, pcy - 22), sc(pcx - 10, pcy - 4)], fill=PALETTE["crystal_bright"], width=max(1, S))
    draw.line([sc(pcx, pcy - 22), sc(pcx + 6, pcy - 4)], fill=PALETTE["crystal_core"], width=max(1, S))
    # Glowing diamond highlight in apex
    draw.polygon([
        sc(pcx, pcy - 20), sc(pcx + 3, pcy - 14), sc(pcx, pcy - 8), sc(pcx - 3, pcy - 14)
    ], fill=PALETTE["crystal_core"])
    
    # Floating Orbital Motes (4 sparkles)
    for mx, my in [(pcx - 18, pcy - 16), (pcx + 20, pcy - 14), (pcx - 14, pcy + 14), (pcx + 16, pcy + 12)]:
        draw.rectangle(sc_rect(mx - 1, my - 1, 3, 3), fill=PALETTE["crystal_cyan"])
        draw.point(sc(mx, my), fill=PALETTE["crystal_core"])

    # --- 4. Subterranean Crystal Spike Hazard Bed ("spikes", 160, 0, 96, 32) ---
    kx, ky, kw, kh = 160, 0, 96, 32
    # Base bedrock ground strip (y = 24..32)
    draw.rectangle(sc_rect(kx, ky + 24, kw, 8), fill=PALETTE["bedrock_dark"])
    draw.line([sc(kx, ky + 24), sc(kx + kw, ky + 24)], fill=PALETTE["bedrock_light"], width=max(1, S))
    
    # 7 Razor-sharp crystal stalagmites of varying heights
    spike_configs = [
        (kx + 6, 20), (kx + 18, 28), (kx + 32, 24), (kx + 46, 30),
        (kx + 60, 22), (kx + 74, 29), (kx + 88, 23)
    ]
    for sp_x, sp_h in spike_configs:
        tip_y = ky + 24 - sp_h
        # Left facet
        draw.polygon([
            sc(sp_x, tip_y), sc(sp_x - 5, ky + 24), sc(sp_x, ky + 24)
        ], fill=PALETTE["crystal_mid"])
        # Right facet
        draw.polygon([
            sc(sp_x, tip_y), sc(sp_x, ky + 24), sc(sp_x + 5, ky + 24)
        ], fill=PALETTE["crystal_deep"])
        # Spine & lethal glowing needle tip
        draw.line([sc(sp_x, tip_y), sc(sp_x, ky + 24)], fill=PALETTE["crystal_cyan"], width=max(1, S))
        draw.line([sc(sp_x - 5, ky + 24), sc(sp_x, tip_y)], fill=PALETTE["crystal_bright"], width=max(1, S))
        draw.rectangle(sc_rect(sp_x - 1, tip_y, 2, 3), fill=PALETTE["crystal_core"])

    # --- 5. Ancient Lunar Lore Stele ("lore_stele", 96, 48, 64, 112) ---
    tx, ty, tw, th = 96, 48, 64, 112
    tcx = tx + 32
    # Heavy stone plinth base (y = 96..108)
    draw.rectangle(sc_rect(tcx - 18, ty + 96, 36, 12), fill=PALETTE["bedrock_dark"], outline=PALETTE["bedrock_mid"], width=max(1, S))
    draw.line([sc(tcx - 18, ty + 96), sc(tcx + 18, ty + 96)], fill=PALETTE["rim_highlight"], width=max(1, S))
    
    # Standing Stele Monolith with arched crest
    stele_pts = [
        sc(tcx - 14, ty + 96),
        sc(tcx - 14, ty + 18),
        sc(tcx - 8, ty + 8),
        sc(tcx, ty + 6),
        sc(tcx + 8, ty + 8),
        sc(tcx + 14, ty + 18),
        sc(tcx + 14, ty + 96),
    ]
    draw.polygon(stele_pts, fill=PALETTE["bedrock_dark"])
    # Rim bevel
    draw.line(stele_pts[:6], fill=PALETTE["rim_highlight"], width=max(1, S))
    draw.line([sc(tcx - 8, ty + 8), sc(tcx + 8, ty + 8)], fill=PALETTE["rim_specular"], width=max(1, S))
    
    # Etched Crescent Moon Medallion in Crest
    draw.arc(sc_rect(tcx - 8, ty + 14, 16, 14), 45, 315, fill=PALETTE["crystal_cyan"], width=max(1, S))
    draw.ellipse(sc_rect(tcx - 2, ty + 19, 5, 5), fill=PALETTE["crystal_core"])
    
    # Vertical inscribed ancient Tagalog / Baybayin inspired runic script glowing softly
    for rune_row in range(ty + 34, ty + 88, 9):
        rx = tcx
        if (rune_row // 9) % 2 == 0:
            # Diamond glyph
            draw.polygon([
                sc(rx, rune_row - 3), sc(rx + 4, rune_row), sc(rx, rune_row + 3), sc(rx - 4, rune_row)
            ], outline=PALETTE["crystal_cyan"], fill=PALETTE["crystal_deep"], width=max(1, S // 2))
        else:
            # Curved glyph
            draw.arc(sc_rect(rx - 4, rune_row - 3, 8, 6), 90, 270, fill=PALETTE["crystal_cyan"], width=max(1, S))
            draw.line([sc(rx - 2, rune_row), sc(rx + 4, rune_row)], fill=PALETTE["crystal_core"], width=max(1, S // 2))

    # --- 6. Ceiling Stalactite Cluster ("ceiling_stalactite", 160, 32, 96, 128) ---
    sx, sy, sw, sh = 160, 32, 96, 128
    # Top bedrock ceiling root (y = 32..42)
    draw.rectangle(sc_rect(sx + 2, sy, sw - 4, 10), fill=PALETTE["bedrock_dark"])
    draw.line([sc(sx + 2, sy + 10), sc(sx + sw - 2, sy + 10)], fill=PALETTE["rim_highlight"], width=max(1, S))
    
    # 5 Massive hanging stalactite columns tapering downward
    stal_configs = [
        (sx + 12, 14, 55),
        (sx + 30, 20, 95), # Longest primary column
        (sx + 52, 16, 75),
        (sx + 70, 18, 110), # Deepest primary column
        (sx + 86, 12, 45)
    ]
    for st_x, st_w, st_len in stal_configs:
        st_tip_y = sy + 10 + st_len
        st_pts = [
            sc(st_x - st_w * 0.5, sy + 10),
            sc(st_x - st_w * 0.35, sy + 10 + st_len * 0.4),
            sc(st_x, st_tip_y),
            sc(st_x + st_w * 0.35, sy + 10 + st_len * 0.4),
            sc(st_x + st_w * 0.5, sy + 10),
        ]
        draw.polygon(st_pts, fill=PALETTE["bedrock_dark"])
        # Highlight along the left flank
        draw.line([sc(st_x - st_w * 0.5, sy + 10), sc(st_x, st_tip_y)], fill=PALETTE["rim_highlight"], width=max(1, S))
        # Deep shadow along the right flank
        draw.line([sc(st_x, st_tip_y), sc(st_x + st_w * 0.5, sy + 10)], fill=PALETTE["deep_void"], width=max(1, S))
        # Glistening wet droplet at the needle tip
        draw.point(sc(st_x, st_tip_y), fill=PALETTE["crystal_cyan"])

    return downscale_canvas(hi_img, S)


# ═════════════════════════════════════════════════════════════════════════════
# MAIN EXECUTION
# ═════════════════════════════════════════════════════════════════════════════
if __name__ == "__main__":
    import os

    out_dir = r"assets/cave_platformer"
    os.makedirs(out_dir, exist_ok=True)

    print("Generating cave_rock_tiles.png...")
    rock_tiles = generate_rock_tiles()
    rock_tiles.save(os.path.join(out_dir, "cave_rock_tiles.png"))
    print(f" -> Saved {rock_tiles.size} to {out_dir}/cave_rock_tiles.png")

    print("Generating cave_platforms.png...")
    platforms = generate_platforms()
    platforms.save(os.path.join(out_dir, "cave_platforms.png"))
    print(f" -> Saved {platforms.size} to {out_dir}/cave_platforms.png")

    print("Generating cave_props.png...")
    props = generate_props()
    props.save(os.path.join(out_dir, "cave_props.png"))
    print(f" -> Saved {props.size} to {out_dir}/cave_props.png")

    print("All Cave Platformer image assets generated successfully!")
