import re

with open('.freebuff/preview_new_outfit.html', 'r', encoding='utf-8') as f:
    txt = f.read()

for m in re.finditer(r'<div class="cap">([^<]+)</div>', txt):
    print(m.group(1))
