func get_players_in_detect_range(node):
	var bodies = node.detect_radius.get_overlapping_bodies()
	if(bodies.size() > 0):
		node.player_location = bodies[0].global_position
	else:
		node.player_location = null

func get_in_melee_range(node):
	var bodies = node.counter_bubble.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			return true
	return false

func get_in_stomp_range(node):
	var bodies = node.stomp_bubble.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			return true
	return false

func get_in_headbutt_range(node):
	var bodies = node.headbutt_bubble.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			return true
	return false

func state_seek(node):
	node.cooling_down = false
	node.StateManager.init_speed(node.speed)
	node.StateManager.accelerate(node)
	node.movedir = node.global_position.direction_to(node.player_location)
	node.StateManager.anim_switch(node, 'walk')

func get_attack_ranges(node):
	var in_stomp_range = node.StateManager.EnemyFunctions.get_in_stomp_range(node)
	var in_headbutt_range = node.StateManager.EnemyFunctions.get_in_headbutt_range(node)
	var in_melee_range = node.StateManager.EnemyFunctions.get_in_melee_range(node)
			
	if(in_melee_range and node.state != node.states.DEFEND):
		if(not node.cooling_down):
			node.StateManager.state_machine(node, node.states.ATTACK)
			node.cooling_down = true
			node.StateManager.set_slipdir(node)
			node.slip_timer.start()
			node.StateManager.anim_switch(node, str('liteattack',node.lite_index))
		return true
	elif(in_stomp_range and node.state != node.states.DEFEND):
		if(not node.cooling_down):
			node.StateManager.state_machine(node, node.states.ATTACK)
			node.cooling_down = true
			node.StateManager.anim_switch(node, 'stomp')
		return true
	elif(in_headbutt_range and node.state != node.states.DEFEND):
		if(not node.cooling_down):
			node.StateManager.state_machine(node, node.states.ATTACK)
			node.cooling_down = true
			node.StateManager.anim_switch(node, 'headbutt')
		return true
	return false
		
func convert_green_indices(node):
	if(node.is_in_group('green')):
		if(node.lite_index == 2):
			node.lite_index = 1
		elif(node.lite_index == 1):
			node.lite_index = 4
		elif(node.lite_index == 4):
			node.lite_index == 3
