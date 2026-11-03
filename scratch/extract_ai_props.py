import os
import cv2
import numpy as np
from PIL import Image

out_dir = "scratch/extracted_ai_props"
os.makedirs(out_dir, exist_ok=True)

def extract_from_im2():
    im = Image.open(r"C:\Users\Lin\.gemini\antigravity\brain\e5c63084-b9ad-4add-8dcb-68444de8a484\philippine_cave_platforms_spritesheet_1792544043909.jpg").convert("RGBA")
    arr = np.array(im)
    
    # Threshold background: background is very dark (values < 28)
    # Let's create an alpha mask
    gray = cv2.cvtColor(arr[:,:,:3], cv2.COLOR_RGB2GRAY)
    
    # Soft background keying for dark background
    # Keep colors, set alpha based on brightness
    alpha = np.clip((gray.astype(float) - 15.0) / 25.0 * 255.0, 0, 255).astype(np.uint8)
    arr[:,:,3] = alpha
    im_keyed = Image.fromarray(arr)
    
    # Save keyed full sheet
    im_keyed.save(f"{out_dir}/im2_keyed_full.png")
    
    # Bounding boxes for prominent objects in im2:
    # 1. Bamboo Suspension Bridge
    bridge = im_keyed.crop((44, 98, 680, 285))
    bridge.save(f"{out_dir}/ai_bamboo_bridge.png")
    
    # 2. Island large / Medium / Sanctuary
    plat_ledge1 = im_keyed.crop((725, 100, 865, 260))
    plat_ledge1.save(f"{out_dir}/ai_plat_ledge1.png")
    
    plat_terrace = im_keyed.crop((870, 100, 1100, 270))
    plat_terrace.save(f"{out_dir}/ai_plat_terrace.png")
    
    plat_crumble = im_keyed.crop((1100, 100, 1210, 265))
    plat_crumble.save(f"{out_dir}/ai_plat_crumble.png")
    
    plat_island = im_keyed.crop((1220, 100, 1335, 270))
    plat_island.save(f"{out_dir}/ai_plat_island.png")
    
    # Row 2 items
    row2_1 = im_keyed.crop((40, 335, 160, 420))
    row2_1.save(f"{out_dir}/ai_row2_1.png")
    
    row2_2 = im_keyed.crop((165, 335, 285, 420))
    row2_2.save(f"{out_dir}/ai_row2_2.png")
    
    row2_long = im_keyed.crop((290, 335, 530, 425))
    row2_long.save(f"{out_dir}/ai_row2_long.png")
    
    row2_spikes = im_keyed.crop((535, 335, 655, 455))
    row2_spikes.save(f"{out_dir}/ai_row2_spikes.png")
    
    row2_blocks = im_keyed.crop((720, 335, 1135, 455))
    row2_blocks.save(f"{out_dir}/ai_row2_blocks.png")
    
    # Row 3 props
    # Totem
    prop_totem = im_keyed.crop((40, 545, 138, 705))
    prop_totem.save(f"{out_dir}/ai_prop_totem.png")
    
    # Sulo Torch
    prop_torch = im_keyed.crop((200, 545, 260, 685))
    prop_torch.save(f"{out_dir}/ai_prop_torch.png")
    
    # Pot
    prop_pot = im_keyed.crop((255, 545, 340, 645))
    prop_pot.save(f"{out_dir}/ai_prop_pot.png")
    
    # Manunggul Jar
    prop_jar = im_keyed.crop((360, 545, 485, 705))
    prop_jar.save(f"{out_dir}/ai_prop_jar.png")
    
    # Moon Pearl (Mutya ng Haliya)
    prop_pearl = im_keyed.crop((540, 540, 700, 705))
    prop_pearl.save(f"{out_dir}/ai_prop_pearl.png")
    
    # Fern / Stalactite / Stalagmite
    prop_stalactite = im_keyed.crop((760, 560, 910, 690))
    prop_stalactite.save(f"{out_dir}/ai_prop_stalactite.png")
    
    prop_ferns = im_keyed.crop((980, 535, 1135, 700))
    prop_ferns.save(f"{out_dir}/ai_prop_ferns.png")
    
    print("Extracted all components from Image 2!")

extract_from_im2()
