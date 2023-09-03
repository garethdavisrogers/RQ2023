extends "res://Fighter.gd"

onready var detect_radius = $Sprite/DetectRadius
onready var stomp_bubble = $Sprite/StompBubble
onready var headbutt_bubble = $Sprite/HeadbuttBubble

var player_location = null
var in_melee_range = false
var in_stomp_range = false
var in_headbutt_range = false

func _ready():
	self.add_to_group('enemy')
	
func _physics_process(delta):
	if(StateManager.get_is_dead(health)):
		StateManager.state_machine(SELF, states.DEAD)
	if(state != states.DEAD):
		if(not StateManager.non_interuptable(SELF)):
			convert_green_indices()
			StateManager.set_last_direction(SELF)
			if(state != states.CLINCHED):
				pummeled = false
				if(state != states.GRAB):
					StateManager.release_opponent(SELF)
					get_players_in_detect_range()
					if(state != states.STAGGER and state != states.KNOCKDOWN):
						if(player_location):
							in_stomp_range = get_in_stomp_range()
							in_headbutt_range = get_in_headbutt_range()
							in_melee_range = get_in_melee_range()
							
							if(in_melee_range and state != states.DEFEND):
								speed = 0
								StateManager.state_machine(SELF, states.IDLE)
								
							elif(in_stomp_range and state != states.DEFEND):
								speed = 0
								StateManager.state_machine(SELF, states.IDLE)
							elif(in_headbutt_range and state != states.DEFEND):
								speed = 0
								StateManager.state_machine(SELF, states.IDLE)
							else:
								speed = 80
								StateManager.state_machine(SELF, states.SEEK)
						else:
							StateManager.state_machine(SELF, states.IDLE)
							
					else:
						knockdir = null
				if(state != states.DEFEND):
					StateManager.PhysicsLoops.spritedir_loop(SELF)
					StateManager.PhysicsLoops.movement_loop(SELF)
		
	match state:
		states.DEAD:
			StateManager.StateFunctions.state_dead(SELF)
		states.SEEK:
			state_seek()
		states.ATTACK:
			StateManager.StateFunctions.state_attack(SELF)
		states.RECOVER:
			StateManager.StateFunctions.state_recover(SELF)
		states.IDLE:
			StateManager.StateFunctions.state_idle(SELF)

func state_seek():
	StateManager.init_speed(speed)
	StateManager.accelerate(SELF)
	movedir = global_position.direction_to(player_location)
	StateManager.anim_switch(SELF, 'walk')

func get_players_in_detect_range():
	var bodies = detect_radius.get_overlapping_bodies()
	if(bodies.size() > 0):
		player_location = bodies[0].global_position
	else:
		player_location = null
		
func get_in_melee_range():
	var bodies = counter_bubble.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			return true
	return false
	
func get_in_stomp_range():
	var bodies = stomp_bubble.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			return true
	return false

func get_in_headbutt_range():
	var bodies = headbutt_bubble.get_overlapping_bodies()
	for body in bodies:
		if(body.is_in_group('player')):
			return true
	return false
	
func convert_green_indices():
	if(self.is_in_group('green')):
		if(lite_index == 2):
			lite_index = 1
		elif(lite_index == 1):
			lite_index = 4
		elif(lite_index == 4):
			lite_index == 3

