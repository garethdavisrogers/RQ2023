func handle_melee_attack_input(node, type):
	if(type == 'lite'):
		node.attack_index = node.lite_index
		node.lite_index = min(node.lite_index + 1, 4)
	elif(type == 'heavy'):
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

func controls_loop(node):
	var clinched = node.state == node.states.CLINCHED
	var clinching = node.state == node.states.GRAB and node.clinched_opponent
	
	if(clinched):
		if(Input.is_action_just_pressed('grab')):
			pass
	elif(clinching):
		clinching_controls_loop(node)
	else:
		if(Input.is_action_pressed('block')):
			node.StateManager.anim_switch(node, 'block')
			node.StateManager.state_machine(node, node.states.DEFEND)
		elif(Input.is_action_just_released('block')):
			node.StateManager.state_machine(node, node.states.IDLE)
		elif(node.state == node.states.DEFEND):
			defense_controls_loops(node)
		else:
			attack_and_movement_controls_loop(node)

func clinching_controls_loop(node):
	if(Input.is_action_just_pressed('ui_left') and node.last_direction_x == 1):
		node.StateManager.anim_switch(node, 'throw')
		node.throwing = true
		node.throw_timer.start()
		node.clinched_opponent.global_position.x -= 120
		node.clinched_opponent.anim.play('thrown')
		node.clinched_opponent.scale.x = node.clinched_opponent.scale.y * 1
		node.clinched_opponent = null
	elif(Input.is_action_just_pressed('ui_right') and node.last_direction_x == -1):
		node.StateManager.anim_switch(node, 'throw')
		node.throwing = true
		node.throw_timer.start()
		node.clinched_opponent.global_position.x += 120
		node.clinched_opponent.anim.play('thrown')
		node.clinched_opponent.scale.x = node.clinched_opponent.scale.y * -1
		node.clinched_opponent = null
	elif(Input.is_action_just_pressed("liteattack") and node.can_follow_up):
		node.StateManager.anim_switch(node, 'pummel')
		node.can_follow_up = false
		node.combo_timer.start()
	elif(Input.is_action_just_pressed("grab")):
		node.StateManager.release_opponent(node)

func defense_controls_loops(node):
	var enemy_attack_index = 1
	var LEFT = Input.is_action_pressed('ui_left')
	var RIGHT = Input.is_action_pressed('ui_right')
	var UP = Input.is_action_pressed('ui_up')
	var DOWN = Input.is_action_pressed('ui_down')
	
	var hit_colliders = node.counter_bubble.get_overlapping_areas()
	for area in hit_colliders:
		var parent = node.StateManager.get_parent_node(area)
		if(parent.is_in_group('enemy')):
			enemy_attack_index = parent.attack_index
			node.can_counter = true
			break
	if(UP):
		node.StateManager.anim_switch(node, 'odddodge')
		node.odd = true
		node.is_dodging = true
		node.slip_timer.start()
		if(node.can_counter and enemy_attack_index % 2):
			if(Input.is_action_just_pressed("liteattack")):
				node.is_dodging = false
				node.countering = true
				node.StateManager.anim_switch(node, 'oddcounter')
	elif(DOWN):
		node.even = true
		node.StateManager.anim_switch(node, 'evendodge')
		node.is_dodging = true
		node.slip_timer.start()
		if(node.can_counter and enemy_attack_index % 2 == 0):
			if(Input.is_action_just_pressed("liteattack")):
				node.is_dodging = false
				node.countering = true
				node.StateManager.anim_switch(node, 'oddcounter')
				
	elif(LEFT and node.last_direction_x == 1):
		node.StateManager.anim_switch(node, 'alucarddodge')
		node.is_dodging = true
	elif(RIGHT and node.last_direction_x == -1):
		node.StateManager.anim_switch(node, 'alucarddodge')
		node.is_dodging = true
	if(node.blocking and Input.is_action_just_released('block')):
		node.StateManager.state_machine(node, node.states.IDLE)

func attack_and_movement_controls_loop(node):
	var LEFT = Input.is_action_pressed('ui_left')
	var RIGHT = Input.is_action_pressed('ui_right')
	var UP = Input.is_action_pressed('ui_up')
	var DOWN = Input.is_action_pressed('ui_down')
	
	node.movedir.x = -int(LEFT) + int(RIGHT)
	node.movedir.y = -int(UP) + int(DOWN)
		
	if(Input.is_action_just_pressed("liteattack")):
		if(node.speed > 200 and not node.dashing):
			node.StateManager.anim_switch(node, 'dashattack')
			node.dashing = true
			node.StateManager.state_machine(node, node.states.ATTACK)
		elif(node.state == node.states.IDLE or node.can_follow_up):
			node.StateManager.anim_switch(node, str('liteattack',node.lite_index))
			node.StateManager.set_slipdir(node)
			node.slip_timer.start()
			node.StateManager.ControlsManager.handle_melee_attack_input(node, 'lite')
			node.StateManager.state_machine(node, node.states.ATTACK)
		
	elif(Input.is_action_just_pressed("grab")):
		node.StateManager.anim_switch(node, 'grab')
		node.StateManager.state_machine(node, node.states.GRAB)
