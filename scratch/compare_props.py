from PIL import Image

for old_name, new_name in [
    ('assets/bahay_kubo/prop_wooden_fence.png', 'scratch/perfect_prop_fence.png'),
    ('assets/bahay_kubo/prop_firewood.png', 'scratch/perfect_prop_firewood.png'),
    ('assets/bahay_kubo/prop_mossy_rocks.png', 'scratch/perfect_prop_rock.png'),
    ('assets/bahay_kubo/prop_banana_tree.png', 'scratch/perfect_prop_banana.png'),
]:
    old_im = Image.open(old_name)
    new_im = Image.open(new_name)
    print(f'{old_name}: old={old_im.size}, new={new_im.size}')
