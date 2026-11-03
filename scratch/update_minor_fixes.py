with open("scripts/baybayin_text.gd", "r", encoding="utf-8") as f:
    c = f.read()

target = '"bahay kubo homestead": "ᜆᜑᜈᜈ᜔ ᜊᜑᜌ᜔ ᜃᜓᜊᜓ",'
replacement = '"bahay kubo": "ᜊᜑᜌ᜔ ᜃᜓᜊᜓ",\n\t"bahay kubo homestead": "ᜆᜑᜈᜈ᜔ ᜊᜑᜌ᜔ ᜃᜓᜊᜓ",'
assert target in c, "target not found in baybayin_text.gd"
c = c.replace(target, replacement, 1)

with open("scripts/baybayin_text.gd", "w", encoding="utf-8") as f:
    f.write(c)

print("Updated baybayin_text.gd")

with open("scripts/santelmo.gd", "r", encoding="utf-8") as f:
    s = f.read()

old_death_tw = """\t# Death dissolve tween
\tvar tw = create_tween()
\ttw.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\ttw.parallel().tween_property(sprite, "modulate:a", 0.0, 0.25)
\tif light:
\t\ttw.parallel().tween_property(light, "energy", 0.0, 0.25)
\ttw.tween_callback(queue_free)"""

new_death_tw = """\t# Death dissolve tween
\tif is_instance_valid(sprite) and is_inside_tree():
\t\tvar tw = create_tween()
\t\tif tw:
\t\t\ttw.tween_property(sprite, "scale", Vector2(1.8, 1.8), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\t\ttw.parallel().tween_property(sprite, "modulate:a", 0.0, 0.25)
\t\t\tif light:
\t\t\t\ttw.parallel().tween_property(light, "energy", 0.0, 0.25)
\t\t\ttw.tween_callback(queue_free)
\t\telse:
\t\t\tqueue_free()
\telse:
\t\tqueue_free()"""

assert old_death_tw in s, "old_death_tw not found in santelmo.gd"
s = s.replace(old_death_tw, new_death_tw, 1)

with open("scripts/santelmo.gd", "w", encoding="utf-8") as f:
    f.write(s)

print("Updated santelmo.gd")
