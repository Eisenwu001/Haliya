from PIL import Image
import numpy as np

for name in ['prop_sleeping_cat.png', 'prop_rooster.png']:
    im = Image.open('assets/bahay_kubo/' + name)
    arr = np.array(im)
    alpha = arr[:, :, 3]
    ys, xs = np.where(alpha > 20)
    print(name, 'size:', im.size, 'Y bounds:', ys.min(), ys.max(), 'X bounds:', xs.min(), xs.max())
