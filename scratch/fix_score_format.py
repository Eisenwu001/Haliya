with open('scripts/game_over_ui.gd', 'r', encoding='utf-8') as f:
    c = f.read()

target = 'score_label.text = "FINAL SCORE: %s PTS" % String.num(int(round(float(final_score))))'
repl = 'score_label.text = "FINAL SCORE: %d PTS" % int(round(float(final_score)))'
assert target in c, "target not found in game_over_ui.gd"
c = c.replace(target, repl)

with open('scripts/game_over_ui.gd', 'w', encoding='utf-8') as f:
    f.write(c)

print("SUCCESS: Updated score formatting to pure integer %d PTS")
