extends "res://Fighter.gd"

var can_follow_up = false

onready var combo_timer = $ComboTimer
onready var overlay = $Sprite/Overlay

func _ready():
	combo_timer.wait_time = 0.35
	combo_timer.one_shot = true
	self.add_to_group('player')
	health = 500

func _physics_process(_delta):
	
	if(StateManager.get_is_dead(health)):
		StateManager.state_machine(SELF, states.DEAD)
	##Check player is not dead
	
	if(state != states.DEAD):
		##Player is alive
		if(StateManager.special_non_interuptable(SELF)):
			StateManager.PhysicsLoops.specialty_movement_loop(SELF)
		else:
			StateManager.set_last_direction(SELF)
			StateManager.PhysicsLoops.check_run_physics_loop(SELF)
			if(state != states.STAGGER and state != states.KNOCKDOWN):
				knockdir = null
				var areas = hitbox.get_overlapping_areas()
				if(areas.size() > 0):
					StateManager.HitBoxManager.hitbox_loop(SELF, areas[0])
				StateManager.ControlsManager.controls_loop(SELF)
				if(state != states.CLINCHED):
					pummeled = false
				if(state != states.GRAB):
					StateManager.release_opponent(SELF)
			
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

	
func _on_HitCollider_area_entered(area):
	if(anim.current_animation == 'grab'):
		var node_parent = StateManager.get_parent_node(area)
		if(node_parent.is_in_group('enemy')):
			StateManager.anim_switch(SELF, 'clinch')
			clinched_opponent = node_parent
			clinch_timer.start()
	
func _on_ComboTimer_timeout():
	StateManager.TimerManager.combo(SELF)
