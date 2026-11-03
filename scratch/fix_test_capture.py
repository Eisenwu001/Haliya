with open('scripts/test_progression_system.gd', 'r', encoding='utf-8') as f:
    t = f.read()

target1 = """	var chosen_signal_id = ""
	ui.upgrade_selected.connect(func(id: String): chosen_signal_id = id)
	ui.select_upgrade(0)
	
	assert(chosen_signal_id == draft[0]["id"], "Upgrade selection signal should emit chosen upgrade ID")"""

repl1 = """	var chosen_box = [""]
	ui.upgrade_selected.connect(func(id: String): chosen_box[0] = id)
	ui.select_upgrade(0)
	
	assert(chosen_box[0] == draft[0]["id"], "Upgrade selection signal should emit chosen upgrade ID")"""

assert target1 in t, "target1 not found"
t = t.replace(target1, repl1, 1)

target2 = """	var restart_requested = false
	go_ui.restart_run_requested.connect(func(): restart_requested = true)
	go_ui.on_restart_pressed()
	assert(restart_requested == true, "GameOverUI should trigger restart_run_requested")"""

repl2 = """	var restart_box = [false]
	go_ui.restart_run_requested.connect(func(): restart_box[0] = true)
	go_ui.on_restart_pressed()
	assert(restart_box[0] == true, "GameOverUI should trigger restart_run_requested")"""

assert target2 in t, "target2 not found"
t = t.replace(target2, repl2, 1)

with open('scripts/test_progression_system.gd', 'w', encoding='utf-8') as f:
    f.write(t)
print("test_progression_system.gd updated!")
