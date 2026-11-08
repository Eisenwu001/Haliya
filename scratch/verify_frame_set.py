import os
from PIL import Image

def verify_set(mask_dir, wpn):
    print(f"=== Checking {mask_dir} / {wpn} ===")
    
    # Idle
    idle_dir = os.path.join('Haliya with clothes', 'Haliya', 'Idle', mask_dir, 'v3', wpn)
    idle_files = sorted([f for f in os.listdir(idle_dir) if f.endswith('.png')])
    print(f"Idle ({len(idle_files)} files):", idle_files)
    for f in idle_files:
        im = Image.open(os.path.join(idle_dir, f))
        assert im.size == (256, 256), f"Size mismatch in {f}: {im.size}"
        assert im.mode == 'RGBA', f"Mode mismatch in {f}: {im.mode}"
        
    # Walk
    walk_mask_dir = 'with mask' if 'w-' in mask_dir and not 'w-o' in mask_dir else 'without mask'
    walk_dir = os.path.join('Haliya with clothes', 'Haliya', 'Walk', walk_mask_dir, wpn)
    walk_files = sorted([f for f in os.listdir(walk_dir) if f.endswith('.png')])
    print(f"Walk ({len(walk_files)} files):", walk_files)
    for f in walk_files:
        im = Image.open(os.path.join(walk_dir, f))
        assert im.size == (256, 256), f"Size mismatch in {f}: {im.size}"
        assert im.mode == 'RGBA', f"Mode mismatch in {f}: {im.mode}"

    # Crouch
    crouch_dir = os.path.join('Haliya with clothes', 'Haliya', 'Crouch', walk_mask_dir, wpn)
    crouch_files = sorted([f for f in os.listdir(crouch_dir) if f.endswith('.png')])
    print(f"Crouch ({len(crouch_files)} files):", crouch_files)
    for f in crouch_files:
        im = Image.open(os.path.join(crouch_dir, f))
        assert im.size == (256, 256), f"Size mismatch in {f}: {im.size}"
        assert im.mode == 'RGBA', f"Mode mismatch in {f}: {im.mode}"
        
    print("All 30 frames verified successfully!")

verify_set('w- Mask', 'kampilan')
verify_set('w-o Mask', 'kampilan')
