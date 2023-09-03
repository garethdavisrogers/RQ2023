func handle_melee_attack_input(node, type):
	if(type == 'lite'):
		node.attack_index = node.lite_index
		node.lite_index = min(node.lite_index + 1, 4)
	if(type == 'heavy'):
		node.attack_index = node.heavy_index
		node.heavy_index = min(node.lite_index + 1, 3)

	if(node.attack_index == 1):
		node.can_follow_up = true
	else:
		if(node.attack_index == 2):
			node.odd = false
			node.even = true
		node.can_follow_up = false
		node.combo_timer.start()
	node.StateManager.set_slipdir(node)
