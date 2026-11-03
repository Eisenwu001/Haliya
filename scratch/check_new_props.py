from PIL import Image
import numpy as np

props_img = Image.open('assets/cave_platformer/cave_props.png')
regions = {
    'manunggul_jar': (0, 0, 64, 64),
    'anito_totem': (64, 0, 64, 96),
    'cave_ferns': (128, 0, 64, 64),
    'stalactites': (192, 0, 96, 64),
    'sulo_torch': (0, 64, 32, 64),
    'stalagmites_spikes': (64, 64, 96, 32),
    'moon_pearl_pogo': (160, 64, 64, 64),
    'palayok_pot': (224, 64, 48, 48),
}

for name, (rx, ry, rw, rh) in regions.items():
    crop = props_img.crop((rx, ry, rx + rw, ry + rh))
    arr = np.array(crop)
    alpha = arr[:, :, 3]
    ys, xs = np.where(alpha > 10)
    if len(ys) == 0:
        print(f"{name}: EMPTY!")
    else:
        print(f"{name}: region=({rw}x{rh}), opaque bounds: y=[{ys.min()}..{ys.max()}], x=[{xs.min()}..{xs.max()}]")
