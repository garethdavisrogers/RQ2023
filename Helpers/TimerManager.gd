func recover(node):
	if(not node.recovering):
		node.recovering = true
		node.StateManager.state_machine(node, node.states.RECOVER)
		node.knockdown_timer.start()
	else:
		node.recovering = false
		if(node.is_in_group('player')):
			node.StateManager.state_machine(node, node.states.IDLE)
		else:
			node.StateManager.state_machine(node, node.states.SEEK)

func throw(node):
	node.throwing = false
	node.movedir.x = node.last_direction_x * -1
	node.StateManager.state_machine(node, node.states.IDLE)

func slip(node):
	node.pummeled = false
	node.even = false
	node.odd = false

func combo(node):
	node.can_follow_up = true
	if(node.dashing):
		node.dashing = false
		node.combo_timer.start()
		node.StateManager.state_machine(node, node.states.LAND)
	elif(node.state == node.states.LAND):
		node.StateManager.anim_switch(node, 'land')
		node.StateManager.state_machine(node, node.states.IDLE)
	elif(node.state == node.states.GRAB and node.clinched_opponent):
		node.StateManager.anim_switch(node, 'clinch')
