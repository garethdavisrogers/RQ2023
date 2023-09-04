extends "res://Fighter.gd"

onready var detect_radius = $Sprite/DetectRadius
onready var stomp_bubble = $Sprite/StompBubble
onready var headbutt_bubble = $Sprite/HeadbuttBubble

var player_location = null

func _ready():
	self.add_to_group('enemy')
	
func _physics_process(_delta):
	
	if(StateManager.get_is_dead(health)):
		StateManager.state_machine(SELF, states.DEAD)
		
	if(state != states.DEAD):
		##Enemy is alive
		if(StateManager.special_non_interuptable(SELF)):
			StateManager.PhysicsLoops.specialty_movement_loop(SELF)
		else:
			StateManager.set_last_direction(SELF)
			StateManager.PhysicsLoops.check_run_physics_loop(SELF)
			if(state != states.STAGGER and state != states.KNOCKDOWN):
				knockdir = null
				pummeled = false
				if(state != states.GRAB):
					StateManager.release_opponent(SELF)
					StateManager.EnemyFunctions.get_players_in_detect_range(SELF)
					if(player_location):
						var attacking = StateManager.EnemyFunctions.get_attack_ranges(SELF)
						if(not attacking):
							StateManager.reset_attack_indices(SELF)
							StateManager.state_machine(SELF, states.SEEK)
					else:
						StateManager.state_machine(SELF, states.IDLE)
		
	match state:
		states.DEAD:
			StateManager.StateFunctions.state_dead(SELF)
		states.SEEK:
			StateManager.EnemyFunctions.state_seek(SELF)
		states.ATTACK:
			StateManager.StateFunctions.state_attack(SELF)
		states.RECOVER:
			StateManager.StateFunctions.state_recover(SELF)
		states.IDLE:
			StateManager.StateFunctions.state_idle(SELF)


