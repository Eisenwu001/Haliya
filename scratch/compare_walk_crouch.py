from PIL import Image, ImageDraw

def compare_walk():
    base = Image.open('assets/haliya/common_11_walk01.png').convert('RGBA')
    wom_k = Image.open('Haliya with clothes/Haliya/Walk/without mask/kampilan/haliya_walk_A01.png')
    wm_k = Image.open('Haliya with clothes/Haliya/Walk/with mask/kampilan/haliya_walk_A01.png')
    wom_f = Image.open('Haliya with clothes/Haliya/Walk/without mask/fist/haliya_walk_A01.png')
    wm_f = Image.open('Haliya with clothes/Haliya/Walk/with mask/fist/haliya_walk_A01.png')
    
    crop_box = (80, 115, 180, 250)
    crops = [
        ('1. Base Original', base.crop(crop_box)),
        ('2. w-o Mask + Kampilan', wom_k.crop(crop_box)),
        ('3. w- Mask + Kampilan', wm_k.crop(crop_box)),
        ('4. w-o Mask + Fist', wom_f.crop(crop_box)),
        ('5. w- Mask + Fist', wm_f.crop(crop_box)),
    ]
    cw, ch = crops[0][1].size
    grid = Image.new('RGBA', (cw * len(crops), ch + 40), (25, 25, 35, 255))
    draw = ImageDraw.Draw(grid)
    for i, (name, crp) in enumerate(crops):
        grid.paste(crp, (i * cw, 35), crp)
        draw.text((i * cw + 5, 10), name, fill=(220, 220, 220, 255))
    grid.save('scratch/compare_walk_options.png')
    print("Saved scratch/compare_walk_options.png")

def compare_crouch():
    base = Image.open('assets/haliya/common_01_crouch_to_idle01.png').convert('RGBA')
    wom_k = Image.open('Haliya with clothes/Haliya/Crouch/without mask/kampilan/common_01_crouch_to_idle01.png')
    wm_k = Image.open('Haliya with clothes/Haliya/Crouch/with mask/kampilan/common_01_crouch_to_idle01.png')
    wom_f = Image.open('Haliya with clothes/Haliya/Crouch/without mask/fist/common_01_crouch_to_idle01.png')
    wm_f = Image.open('Haliya with clothes/Haliya/Crouch/with mask/fist/common_01_crouch_to_idle01.png')
    
    crop_box = (55, 135, 165, 250)
    crops = [
        ('1. Base Original', base.crop(crop_box)),
        ('2. w-o Mask + Kampilan', wom_k.crop(crop_box)),
        ('3. w- Mask + Kampilan', wm_k.crop(crop_box)),
        ('4. w-o Mask + Fist', wom_f.crop(crop_box)),
        ('5. w- Mask + Fist', wm_f.crop(crop_box)),
    ]
    cw, ch = crops[0][1].size
    grid = Image.new('RGBA', (cw * len(crops), ch + 40), (25, 25, 35, 255))
    draw = ImageDraw.Draw(grid)
    for i, (name, crp) in enumerate(crops):
        grid.paste(crp, (i * cw, 35), crp)
        draw.text((i * cw + 5, 10), name, fill=(220, 220, 220, 255))
    grid.save('scratch/compare_crouch_options.png')
    print("Saved scratch/compare_crouch_options.png")

compare_walk()
compare_crouch()
