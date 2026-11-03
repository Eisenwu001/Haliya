import urllib.request, urllib.parse, shutil, os

# 1. Use complete binalig for exploration
if os.path.exists("assets/audio/music/kulintang_binalig.mp3"):
    shutil.copyfile("assets/audio/music/kulintang_binalig.mp3", "assets/audio/music/kulintang_exploration.mp3")
    print("Copied complete binalig to kulintang_exploration.mp3")

# 2. Download Tidtu for battle
url = "https://dn710007.ca.archive.org/0/items/world-kulintang-institute-kulintang-ancient-gong-drum-music-from-the-southern-philippines/Kulintang_%20Ancient%20Gong-Drum%20Music%20Of%20Th/03%20Tidtu%20I.mp3"
dest = "assets/audio/music/kulintang_battle.mp3"
print("Downloading battle track (Tidtu)...")
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req, timeout=40) as resp, open(dest, "wb") as f:
    shutil.copyfileobj(resp, f, length=128*1024)
print("Battle track downloaded:", os.path.getsize(dest))
