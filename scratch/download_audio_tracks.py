import urllib.request, urllib.parse, shutil, os

os.makedirs('assets/audio/music', exist_ok=True)
base = "https://dn710007.ca.archive.org/0/items/world-kulintang-institute-kulintang-ancient-gong-drum-music-from-the-southern-philippines/Kulintang_%20Ancient%20Gong-Drum%20Music%20Of%20Th/"

tracks = [
    ("01%20Binalig%20I.mp3", "assets/audio/music/kulintang_exploration.mp3"),
    ("03%20Tidtu%20I.mp3", "assets/audio/music/kulintang_battle.mp3"),
    ("02%20Sinulog%20A%20Kangungudan.mp3", "assets/audio/music/kulintang_homestead.mp3")
]

for src_name, dest_path in tracks:
    url = base + src_name
    print(f"Downloading {src_name} -> {dest_path}...")
    req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp, open(dest_path, 'wb') as f:
            shutil.copyfileobj(resp, f, length=64*1024)
        print(f"Done! Size: {os.path.getsize(dest_path)} bytes")
    except Exception as e:
        print(f"Failed {src_name}: {e}")
