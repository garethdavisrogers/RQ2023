func state_dead(node):
	node.StateManager.anim_switch(node, str('death', node.death_version))

func state_attack(node):
	node.StateManager.decelerate(node, 20)

func state_recover(node):
	node.StateManager.anim_switch(node, 'recover')
	
func state_defend(node):
	node.StateManager.decelerate(node)
	node.StateManager.PhysicsLoops.specialty_movement_loop(node)

func state_idle(node):
	node.StateManager.reset_attack_indices(node)
	node.is_dodging = false
	node.can_counter = false
	if(node.speed > 200):
		node.StateManager.anim_switch(node, 'run')
	elif(node.movedir.x != 0):
		node.StateManager.anim_switch(node, 'walk')
	if(node.movedir.x != 0):
		node.StateManager.init_speed(node.speed)
		node.StateManager.accelerate(node)
	else:
		if(node.speed >= 0):
			node.StateManager.decelerate(node)
		if(node.movedir.y != 0):
			node.StateManager.anim_switch(node, 'walk')
		else:
			node.StateManager.anim_switch(node, 'idle')
