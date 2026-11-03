from PIL import Image

# 1. Fence: target (115, 80)
im_fence = Image.open('scratch/perfect_prop_fence.png')
# Resize maintaining crisp details
fence_resized = im_fence.resize((115, 80), Image.Resampling.LANCZOS)
fence_resized.save('assets/bahay_kubo/prop_wooden_fence.png')
print('Saved prop_wooden_fence.png:', fence_resized.size)

# 2. Firewood: target (90, 60)
im_wood = Image.open('scratch/perfect_prop_firewood.png')
wood_resized = im_wood.resize((90, 60), Image.Resampling.LANCZOS)
wood_resized.save('assets/bahay_kubo/prop_firewood.png')
print('Saved prop_firewood.png:', wood_resized.size)

# 3. Rocks: target (100, 90)
im_rock = Image.open('scratch/perfect_prop_rock.png')
rock_resized = im_rock.resize((100, 90), Image.Resampling.LANCZOS)
rock_resized.save('assets/bahay_kubo/prop_mossy_rocks.png')
print('Saved prop_mossy_rocks.png:', rock_resized.size)

# 4. Banana tree: target (160, 192)
im_banana = Image.open('scratch/perfect_prop_banana.png')
banana_resized = im_banana.resize((160, 192), Image.Resampling.LANCZOS)
banana_resized.save('assets/bahay_kubo/prop_banana_tree.png')
print('Saved prop_banana_tree.png:', banana_resized.size)
