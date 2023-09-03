func hitbox_loop(node, area):
	var opponent = node.StateManager.get_parent_node(area)
	var grabbed = opponent.state == node.states.GRAB
	var attacked = opponent.state == node.states.ATTACK
	
	if(grabbed):
		if(node.state != node.states.CLINCHED):
			node.StateManager.state_machine(node, node.states.CLINCHED)
			node.global_position = opponent.clinch_point.global_position
			node.StateManager.anim_switch(node, 'clinched')
		elif(not node.pummeled):
			node.pummeled = true
			node.slip_timer.start()
			node.StateManager.anim_switch(node, 'clinchstagger')
		else:
			node.StateManager.anim_switch(node, 'clinched')
			
	elif(attacked):
		var enemy_attack_index = opponent.attack_index
		if(opponent.dashing):
			node.knockdir = node.StateManager.get_knockdir(node, area)
			node.StateManager.state_machine(node, node.states.KNOCKDOWN)
			node.StateManager.anim_switch(node, 'knockdown')
			node.knockdown_timer.start()
		elif(node.odd and not node.StateManager.is_even(enemy_attack_index)):
			return
		elif(node.even and node.StateManager.is_even(enemy_attack_index)):
			return
		else:
			node.knockdir = node.StateManager.get_knockdir(node, area)
			node.death_version = enemy_attack_index
			if(node.state == node.states.DEFEND):
				node.StateManager.damage_loop(node, 1)
			else:
				if(node.state == node.states.GRAB):
					node.StateManager.release_opponent(node)
				node.StateManager.state_machine(node, node.states.STAGGER)
				node.StateManager.anim_switch(node, str('stagger', enemy_attack_index))
				node.StateManager.damage_loop(node)
