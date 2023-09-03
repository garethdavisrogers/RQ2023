extends "res://Fighter.gd"

var can_follow_up = false

onready var combo_timer = $ComboTimer
onready var overlay = $Sprite/Overlay

func _ready():
	combo_timer.wait_time = 0.4
	combo_timer.one_shot = true
	self.add_to_group('player')
	health = 500

func _physics_process(delta):
	if(StateManager.get_is_dead(health)):
		StateManager.state_machine(SELF, states.DEAD)
	if(state != states.DEAD):
		if(StateManager.non_interuptable(SELF)):
			StateManager.PhysicsLoops.specialty_movement_loop(SELF)
		else:
			StateManager.set_last_direction(SELF)
			if(state != states.STAGGER):
				controls_loop()
			if(state != states.CLINCHED):
				pummeled = false
				if(state != states.GRAB and not throwing):
					StateManager.release_opponent(SELF)
					StateManager.nullify_knockdir(SELF)
					if(state != states.DEFEND):
						StateManager.PhysicsLoops.movement_loop(SELF)
						StateManager.PhysicsLoops.spritedir_loop(SELF)
			
	match state:
			states.DEAD:
				StateManager.StateFunctions.state_dead(SELF)
			states.RECOVER:
				StateManager.StateFunctions.state_recover(SELF)
			states.ATTACK:
				StateManager.StateFunctions.state_attack(SELF)
			states.IDLE:
				StateManager.StateFunctions.state_idle(SELF)
			states.DEFEND:
				StateManager.StateFunctions.state_defend(SELF)
						
func controls_loop():
	var clinched = state == states.CLINCHED
	var clinching = state == states.GRAB and clinched_opponent
	
	if(clinched):
		if(Input.is_action_just_pressed('grab')):
			pass
	elif(clinching):
		if(Input.is_action_just_pressed('ui_left') and last_direction_x == 1):
			StateManager.anim_switch(SELF, 'throw')
			throwing = true
			throw_timer.start()
			clinched_opponent.global_position.x -= 120
			clinched_opponent.anim.play('thrown')
			clinched_opponent.scale.x = clinched_opponent.scale.y * 1
			clinched_opponent = null
			
		elif(Input.is_action_just_pressed('ui_right') and last_direction_x == -1):
			StateManager.anim_switch(SELF, 'throw')
			throwing = true
			throw_timer.start()
			clinched_opponent.global_position.x += 120
			clinched_opponent.anim.play('thrown')
			clinched_opponent.scale.x = clinched_opponent.scale.y * -1
			clinched_opponent = null
			
		elif(Input.is_action_just_pressed("liteattack") and can_follow_up):
			StateManager.anim_switch(SELF, 'pummel')
			can_follow_up = false
			combo_timer.start()
		elif(Input.is_action_just_pressed("grab")):
			StateManager.release_opponent(SELF)
			
	else:
		if((not is_dodging or can_counter) and not countering):
			var enemy_attack_index = 0
			
			var LEFT = Input.is_action_pressed('ui_left')
			var RIGHT = Input.is_action_pressed('ui_right')
			var UP = Input.is_action_pressed('ui_up')
			var DOWN = Input.is_action_pressed('ui_down')
			
			if(Input.is_action_just_released('block')):
				StateManager.state_machine(SELF, states.IDLE)
			if(state == states.DEFEND and not countering):
				var hit_colliders = counter_bubble.get_overlapping_areas()
				for area in hit_colliders:
					var parent = StateManager.get_parent_node(area)
					if(parent.is_in_group('enemy')):
						enemy_attack_index = parent.attack_index
						can_counter = true
						break
				if(UP):
					StateManager.anim_switch(SELF, 'odddodge')
					odd = true
					is_dodging = true
					slip_timer.start()
					if(can_counter and enemy_attack_index % 2):
						if(Input.is_action_just_pressed("liteattack")):
							is_dodging = false
							countering = true
							StateManager.anim_switch(SELF, 'oddcounter')
				elif(DOWN):
					even = true
					StateManager.anim_switch(SELF, 'evendodge')
					is_dodging = true
					slip_timer.start()
					if(can_counter and enemy_attack_index % 2 == 0):
						if(Input.is_action_just_pressed("liteattack")):
							is_dodging = false
							countering = true
							StateManager.anim_switch(SELF, 'oddcounter')
							
				elif(LEFT and last_direction_x == 1):
					StateManager.anim_switch(SELF, 'alucarddodge')
					is_dodging = true
				elif(RIGHT and last_direction_x == -1):
					StateManager.anim_switch(SELF, 'alucarddodge')
					is_dodging = true
			else:
				movedir.x = -int(LEFT) + int(RIGHT)
				movedir.y = -int(UP) + int(DOWN)
					
				if(Input.is_action_just_pressed("liteattack")):
					if(speed > 200):
						StateManager.anim_switch(SELF, 'dashattack')
						dashing = true
						combo_timer.start()
					elif(state == states.IDLE or can_follow_up):
						StateManager.anim_switch(SELF, str('liteattack',lite_index))
						StateManager.set_slipdir(SELF)
						slip_timer.start()
						StateManager.ControlsManager.handle_melee_attack_input(SELF, 'lite')
					StateManager.state_machine(SELF, states.ATTACK)
					
				elif(Input.is_action_just_pressed("grab")):
					StateManager.anim_switch(SELF, 'grab')
					StateManager.state_machine(SELF, states.GRAB)
					
				elif(Input.is_action_pressed('block')):
					StateManager.anim_switch(SELF, 'block')
					StateManager.state_machine(SELF, states.DEFEND)
	
func _on_HitCollider_area_entered(area):
	if(anim.current_animation == 'grab'):
		var node_parent = StateManager.get_parent_node(area)
		if(node_parent.state == states.CLINCHED and node_parent.is_in_group('enemy')):
			clinched_opponent = node_parent
			clinch_timer.start()
			StateManager.anim_switch(SELF, 'clinch')
	
func _on_ComboTimer_timeout():
	StateManager.TimerManager.combo(SELF)
