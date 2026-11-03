from PIL import Image
import numpy as np

for name in ['assets/ui/hud_sta_frame.png', 'assets/ui/hud_sta_bg.png', 'assets/ui/hud_sta_fill.png']:
    im = Image.open(name)
    arr = np.array(im)
    alpha = arr[:, :, 3]
    ys, xs = np.where(alpha > 20)
    print(name, 'size:', im.size, 'Y in', ys.min(), ys.max(), 'X in', xs.min(), xs.max())
