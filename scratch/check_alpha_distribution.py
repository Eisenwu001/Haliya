from PIL import Image

for fn in ["bottom_foliage.png", "hanging_leaves.png", "corner_fronds_left.png", "totem_shrine.png"]:
    img = Image.open(f"assets/art/incoming/{fn}")
    alpha = img.split()[-1]
    alphas = [0] * 256
    for a in alpha.getdata():
        alphas[a] += 1
    # print summary of alpha buckets: 0, 1..64, 65..127, 128..200, 201..254, 255
    b0 = alphas[0]
    b1 = sum(alphas[1:65])
    b2 = sum(alphas[65:128])
    b3 = sum(alphas[128:200])
    b4 = sum(alphas[200:255])
    b5 = alphas[255]
    print(f"{fn}: a=0: {b0}, a=1..64: {b1}, a=65..127: {b2}, a=128..199: {b3}, a=200..254: {b4}, a=255: {b5}")
