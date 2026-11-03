with open('scripts/main_menu.gd', 'r', encoding='utf-8') as f:
    text = f.read().replace('\r\n', '\n')

old_cb = """\ttw.tween_callback(func():
\t\tif is_instance_valid(step3_press_start_label):
\t\t\tstep3_press_start_label.visible = true
\t\t\tstep3_press_start_label.modulate.a = 0.0
\t\t\tvar tw_show = create_tween()
\t\ttw_show.tween_property(step3_press_start_label, "modulate:a", 1.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\ttw_show.tween_callback(func():
\t\t\tis_in_press_start = true
\t\t\t_start_press_start_breathing()
\t\t)
\t)"""

new_cb = """\ttw.tween_callback(func():
\t\tif is_instance_valid(step3_press_start_label):
\t\t\tstep3_press_start_label.visible = true
\t\t\tstep3_press_start_label.modulate.a = 0.0
\t\t\tvar tw_show = create_tween()
\t\t\ttw_show.tween_property(step3_press_start_label, "modulate:a", 1.0, 0.40).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
\t\t\ttw_show.tween_callback(func():
\t\t\t\tis_in_press_start = true
\t\t\t\t_start_press_start_breathing()
\t\t\t)
\t)"""

assert old_cb in text, "old_cb not found"
text = text.replace(old_cb, new_cb)

with open('scripts/main_menu.gd', 'w', encoding='utf-8') as f:
    f.write(text)

print("Fixed indentation in scripts/main_menu.gd")
