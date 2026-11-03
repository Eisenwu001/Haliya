from PIL import Image
import numpy as np

# In Godot, the viewport is 640x360.
# The background layers have height 720, scaled down by 360/720 = 0.5!
# So each layer is 2128 x 360 in screen space.
# In screen space:
# Layer 1 has content at y=384..719 in 720p => in 360p viewport, that is y = 192..360!
# The ground tilemap surface is at y = 288.0!
# That means Layer 1's vegetation and dikes extend from y = 192 down to 360!
# That is 96 pixels ABOVE the ground surface!
# Let's inspect what is between y=192 and y=288 in Layer 1, Layer 2, Layer 3, Layer 4:
for i in range(1, 5):
    l = Image.open(f'assets/bicol_bg/Rice_Field_Layer{i}.png')
    l_360 = l.resize((2128, 360), Image.Resampling.LANCZOS)
    arr = np.array(l_360)
    # Check alpha in the band above ground: y = 150..288
    band_alpha = arr[150:288, :, 3]
    print(f"Layer {i} (scaled 360p): y=150..288 nonz alpha fraction = {(band_alpha > 20).sum() / band_alpha.size * 100:.1f}%")
