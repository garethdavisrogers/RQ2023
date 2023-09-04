func movement_loop(node):
	var motion = Vector2()
	if(node.knockdir):
		node.speed = 0
		if(node.state == node.states.KNOCKDOWN):
			motion.x = node.knockdir.x * 400
		else:
			motion.x = node.knockdir.x * 60
			motion.y = node.knockdir.y * 10
	else:
		motion.x = node.last_direction_x * node.speed
		motion.y = node.movedir.y * 30
	node.move_and_slide(motion, Vector2(0,0))
	
func spritedir_loop(node):
	if((node.knockdir and node.knockdir.x < 0) or node.last_direction_x > 0):
		node.scale.x = node.scale.y * 1
		node.damage_numbers.scale.x = node.scale.y * 1
	elif((node.knockdir and node.knockdir.x > 0) or node.last_direction_x < 0):
		node.scale.x = node.scale.y * -1
		node.damage_numbers.scale.x = node.scale.y * 1

func specialty_movement_loop(node):
	if(node.countering):
		node.global_position.x += node.last_direction_x * 5
	elif(node.dashing):
		node.global_position.x += node.last_direction_x * 5
	elif(node.is_dodging and node.odd):
		node.global_position.y -= 1.5
	elif(node.is_dodging and node.even):
		node.global_position.y += 1.5
	elif(node.anim.current_animation == 'alucarddodge'):
		node.global_position.x += node.last_direction_x * -6

func check_run_physics_loop(node):
	if(node.state != node.states.DEFEND and node.state != node.states.CLINCHED and node.state != node.states.GRAB):
		movement_loop(node)
		spritedir_loop(node)
