import os
import numpy as np
from PIL import Image
from scipy.ndimage import binary_fill_holes, binary_dilation

def extract_and_solidify(img_path: str, bbox=None, thresh: int = 18) -> Image.Image:
    im = Image.open(img_path).convert('RGB')
    if bbox:
        im = im.crop(bbox)
    arr = np.array(im, dtype=np.uint8)
    rgb = arr[:, :, :3]
    
    # Non-black mask
    b = np.max(rgb, axis=2)
    is_fg = b > thresh
    
    # Fill internal holes
    solid = binary_fill_holes(is_fg)
    
    # Dilate 1px for smooth edge
    dil = binary_dilation(solid)
    edge = np.logical_and(dil, ~solid)
    
    alpha = np.zeros(solid.shape, dtype=np.uint8)
    alpha[solid] = 255
    alpha[edge] = 130
    
    # Fill holes in RGB with dark stone tone
    hole = np.logical_and(solid, b <= thresh)
    if np.any(hole):
        mean_r = max(20, int(np.mean(rgb[solid, 0]) * 0.45))
        mean_g = max(18, int(np.mean(rgb[solid, 1]) * 0.45))
        mean_b = max(28, int(np.mean(rgb[solid, 2]) * 0.45))
        arr[hole, 0] = mean_r
        arr[hole, 1] = mean_g
        arr[hole, 2] = mean_b
        
    out = np.dstack((arr, alpha))
    return Image.fromarray(out, 'RGBA')


def main():
    base_dir = r'assets\cave_platformer'
    os.makedirs(base_dir, exist_ok=True)
    
    # =========================================================================
    # 1. REBAKE CAVE_PROPS.PNG (320 x 160)
    # =========================================================================
    props_sheet = Image.new('RGBA', (320, 160), (0, 0, 0, 0))
    
    # A. Anito stone idol -> Rect2(0, 0, 48, 48)
    anito = extract_and_solidify('scratch/extracted_props/prop_13_104x122.png', thresh=20)
    anito_48 = anito.resize((42, 46), Image.Resampling.LANCZOS)
    props_sheet.paste(anito_48, (3, 2), anito_48)
    
    # B. Intact Palayok pot -> Rect2(48, 0, 48, 48)
    pot_intact = extract_and_solidify('scratch/extracted_props/prop_3_155x142.png', thresh=20)
    pot_i_48 = pot_intact.resize((42, 42), Image.Resampling.LANCZOS)
    props_sheet.paste(pot_i_48, (51, 6), pot_i_48)
    
    # C. Cracked Palayok pot -> Rect2(96, 0, 48, 48)
    pot_crack = extract_and_solidify('scratch/extracted_props/prop_4_155x142.png', thresh=20)
    pot_c_48 = pot_crack.resize((42, 42), Image.Resampling.LANCZOS)
    props_sheet.paste(pot_c_48, (99, 6), pot_c_48)
    
    # D. Blue Glow Moss -> Rect2(144, 0, 32, 32)
    moss = extract_and_solidify('scratch/extracted_props/prop_24_52x40.png', thresh=16)
    moss_32 = moss.resize((30, 24), Image.Resampling.LANCZOS)
    props_sheet.paste(moss_32, (145, 8), moss_32)
    
    # E. Obsidian Spikes -> Rect2(0, 96, 64, 48)
    spikes = extract_and_solidify('scratch/extracted_props/prop_38_94x51.png', thresh=20)
    spikes_64 = spikes.resize((64, 44), Image.Resampling.LANCZOS)
    props_sheet.paste(spikes_64, (0, 96 + 4), spikes_64)
    
    # F. Kulintang Pogo Bell / Gong -> Rect2(64, 96, 64, 64)
    bell = extract_and_solidify('scratch/extracted_props/prop_14_126x175.png', thresh=20)
    bell_64 = bell.resize((46, 62), Image.Resampling.LANCZOS)
    props_sheet.paste(bell_64, (64 + 9, 96 + 1), bell_64)
    
    props_sheet.save(os.path.join(base_dir, 'cave_props.png'), 'PNG')
    print('1. cave_props.png successfully saved!')

    # =========================================================================
    # 2. REBAKE CAVE_PLATFORMS.PNG (224 x 160)
    # =========================================================================
    plat_raw_src = r'C:\Users\Lin\.gemini\antigravity\brain\351a0af0-87d2-4735-aa24-b03d486d3110\platforms_and_stalactites_raw_1792489085961.jpg'
    
    # A. Mossy ledge: (38, 330, 690, 725)
    plat_moss = extract_and_solidify(plat_raw_src, (38, 330, 690, 725), thresh=14)
    # B. Runic altar: (1025, 270, 1340, 540)
    plat_runic = extract_and_solidify(plat_raw_src, (1025, 270, 1340, 540), thresh=14)
    
    platforms_atlas = Image.new('RGBA', (224, 160), (0, 0, 0, 0))
    
    # 1. island_md: 96x48 at (128, 0)
    moss_md = plat_moss.resize((96, 52), Image.Resampling.LANCZOS).crop((0, 0, 96, 48))
    platforms_atlas.paste(moss_md, (128, 0), moss_md)
    
    # 2. island_lg: 128x56 at (0, 0)
    runic_lg = plat_runic.resize((128, 56), Image.Resampling.LANCZOS)
    platforms_atlas.paste(runic_lg, (0, 0), runic_lg)
    
    # 3. bridge: 128x40 at (0, 64)
    moss_br = plat_moss.crop((20, 20, 630, 240)).resize((128, 40), Image.Resampling.LANCZOS)
    platforms_atlas.paste(moss_br, (0, 64), moss_br)
    
    # 4. sanctuary: 160x56 at (0, 104)
    sanct = plat_runic.crop((0, 0, 315, 220)).resize((160, 56), Image.Resampling.LANCZOS)
    platforms_atlas.paste(sanct, (0, 104), sanct)
    
    platforms_atlas.save(os.path.join(base_dir, 'cave_platforms.png'), 'PNG')
    print('2. cave_platforms.png successfully saved!')

    # =========================================================================
    # 3. REBAKE PLAT_BASALT_STRUT.PNG (48 x 128)
    # =========================================================================
    plat_basalt = extract_and_solidify(plat_raw_src, (750, 160, 980, 645), thresh=14)
    strut_48x128 = plat_basalt.resize((48, 128), Image.Resampling.LANCZOS)
    strut_48x128.save(os.path.join(base_dir, 'plat_basalt_strut.png'), 'PNG')
    print('3. plat_basalt_strut.png successfully saved!')

    # =========================================================================
    # 4. REBAKE CAVERN_CEILING_MODULAR.PNG (640 x 132) with Solid Top Bedrock Cap
    # =========================================================================
    ceiling_raw_src = r'C:\Users\Lin\.gemini\antigravity\brain\351a0af0-87d2-4735-aa24-b03d486d3110\cavern_ceiling_raw_1792489065276.jpg'
    # The raw image is 1376x768. The top cavern rock is in y: 0 to 450
    c_raw = Image.open(ceiling_raw_src).convert('RGB')
    c_crop = c_raw.crop((0, 0, 1376, 420)).resize((640, 108), Image.Resampling.LANCZOS)
    c_arr = np.array(c_crop)
    c_rgb = c_arr[:, :, :3]
    
    # Mask non-black stalactites
    c_b = np.max(c_rgb, axis=2)
    # Stalactite silhouette
    c_fg = c_b > 22
    # The top 35px is guaranteed solid ceiling bedrock
    c_fg[0:35, :] = True
    c_solid = binary_fill_holes(c_fg)
    
    c_dil = binary_dilation(c_solid)
    c_edge = np.logical_and(c_dil, ~c_solid)
    
    c_alpha = np.zeros(c_solid.shape, dtype=np.uint8)
    c_alpha[c_solid] = 255
    c_alpha[c_edge] = 120
    
    # Fill internal holes with rich dark basalt tone
    c_hole = np.logical_and(c_solid, c_b <= 22)
    if np.any(c_hole):
        c_arr[c_hole, 0] = 22
        c_arr[c_hole, 1] = 20
        c_arr[c_hole, 2] = 30
        
    c_108 = Image.fromarray(np.dstack((c_arr, c_alpha)), 'RGBA')
    
    # Create 640x132 texture with 24px extra solid bedrock cap at top:
    ceiling_132 = Image.new('RGBA', (640, 132), (0, 0, 0, 0))
    # Top 24px solid bedrock fill
    bedrock_cap = Image.new('RGBA', (640, 24), (18, 16, 26, 255))
    ceiling_132.paste(bedrock_cap, (0, 0))
    ceiling_132.paste(c_108, (0, 24), c_108)
    
    ceiling_132.save(os.path.join(base_dir, 'cavern_ceiling_modular.png'), 'PNG')
    print('4. cavern_ceiling_modular.png successfully saved!')

if __name__ == '__main__':
    main()
