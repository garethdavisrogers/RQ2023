func animation_finished(node, anim_name):
	if(anim_name != 'idle' and anim_name != 'walk'):
		node.StateManager.numbered_animation_iterator(node, anim_name)
	elif(anim_name == 'land'):
		node.dashing = false
		node.StateManager.state_machine(node, node.states.IDLE)
	elif(anim_name == 'clinchstagger' and node.state == node.states.CLINCHED):
		node.StateManager.anim_switch(node, 'clinched')
	elif(anim_name == 'odddodge' or anim_name == 'evendodge'):
		node.StateManager.state_machine(node, node.states.IDLE)
	elif(anim_name == 'oddcounter' or anim_name == 'evencounter'):
		node.StateManager.state_machine(node, node.states.IDLE)
	elif(anim_name == 'thrown'):
		node.StateManager.damage_loop(node, 5)
		node.StateManager.state_machine(node, node.states.RECOVER)
	elif(anim_name == 'stomp'):
		node.cooling_down = false
	elif(anim_name == 'headbutt'):
		node.cooling_down = false
	elif(anim_name == 'release' or anim_name == 'alucarddodge'):
		node.StateManager.state_machine(node, node.states.IDLE)
	elif(anim_name == 'released'):
		if(node.is_in_group('player')):
			node.StateManager.state_machine(node, node.states.IDLE)
		else:
			node.StateManager.state_machine(node, node.states.SEEK)
