import os
from PIL import Image

props = [
    'assets/bahay_kubo/prop_wooden_fence.png',
    'assets/bahay_kubo/prop_firewood.png',
    'assets/bahay_kubo/prop_mossy_rocks.png',
    'assets/bahay_kubo/prop_banana_tree.png',
    'assets/bahay_kubo/prop_rooster.png',
    'assets/bahay_kubo/prop_sleeping_cat.png',
    'assets/bahay_kubo/weapon_rack.png',
    'assets/bahay_kubo/tile_deck_platform.png',
]

for p in props:
    if os.path.exists(p):
        im = Image.open(p)
        print(p, 'exists:', im.size, im.mode)
    else:
        print(p, 'DOES NOT EXIST')
