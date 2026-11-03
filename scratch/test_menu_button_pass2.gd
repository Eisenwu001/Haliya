extends SceneTree

func _init() -> void:
	var item_scene = load("res://ui/components/haliya_menu_button.tscn")
	var item = item_scene.instantiate()
	item.setup("CONTINUE", 0, "Act 1 · Whispering Canopy")
	root.add_child(item)

	await process_frame
	await process_frame

	print("Item size: ", item.size)
	print("ItemHolder size: ", item.item_holder.size)
	print("GroupContainer size: ", item.group_container.size, " pos: ", item.group_container.position)
	print("Button size: ", item.button.size, " pos: ", item.button.position)
	print("CaptionLabel size: ", item.caption_label.size, " pos: ", item.caption_label.position)
	print("Crescent pos: ", item.crescent_rect.position)

	# Focus item
	item.grab_item_focus()
	await process_frame
	await process_frame

	print("--- AFTER SELECT ---")
	print("GroupContainer pos: ", item.group_container.position)
	print("Button global pos: ", item.button.global_position)
	print("CaptionLabel global pos: ", item.caption_label.global_position)
	print("Crescent pos: ", item.crescent_rect.position)

	quit(0)
