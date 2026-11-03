with open("scenes/tileset.tres", "r", encoding="utf-8") as f:
    text = f.read()

lines = text.splitlines()
for line in lines[-30:]:
    print(line)
