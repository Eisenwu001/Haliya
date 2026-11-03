from PIL import Image

im = Image.open('assets/bahay_kubo/tile_deck_platform.png')
# Crop out the stray left column and top stray dot
cleaned = im.crop((14, 1, 204, 79))
cleaned.save('assets/bahay_kubo/tile_deck_platform.png')
print('Cleaned tile_deck_platform.png size:', cleaned.size)
