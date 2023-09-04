##StateManagerModule
const StateFunctionsLoad = preload("res://Helpers/StateFunctions.gd")
const PhysicsLoopsLoad = preload("res://Helpers/PhysicsLoops.gd")
const AnimationManagerLoad = preload("res://Helpers/AnimationManager.gd")
const HitBoxManagerLoad = preload("res://Helpers/HitBoxManager.gd")
const TimerManagerLoad = preload("res://Helpers/TimerManager.gd")
const ControlsManagerLoad = preload("res://Helpers/ControlsManager.gd")
const EnemyFunctionsLoad = preload("res://Helpers/EnemyFunctions.gd")
var StateFunctions = StateFunctionsLoad.new()
var PhysicsLoops = PhysicsLoopsLoad.new()
var AnimationManager = AnimationManagerLoad.new()
var HitBoxManager = HitBoxManagerLoad.new()
var TimerManager = TimerManagerLoad.new()
var ControlsManager = ControlsManagerLoad.new()
var EnemyFunctions = EnemyFunctionsLoad.new()

enum states {
	IDLE,
	SEEK,
	ATTACK,
	DEFEND,
	STAGGER,
	KNOCKDOWN,
	RECOVER,
	GRAB,
	LAND,
	CLINCHED,
	DEAD
}

func state_machine(node, s):
	if(node.state != s):
		node.state = s

func anim_switch(node, new_anim):
	if(node and node.anim.current_animation != new_anim):
		node.anim.play(new_anim)

func damage_loop(node, damage = null):
	if(damage):
		node.health -= damage
	else:
		node.health -= node.attack_index

func accelerate(node):
	node.speed = min(node.speed + 2, node.max_speed)

func decelerate(node, min_speed = 0):
	if(node.speed <= 0):
		node.movedir.x = 0
	node.speed = max(node.speed - 8, min_speed)

func get_knockdir(node, c):
	var pos = node.get_global_position()
	return c.global_position.direction_to(pos)
			
func is_even(num):
	if(num % 2 == 0):
		return true
	return false

func set_slipdir(node):
	if(is_even(node.attack_index)):
		node.even = true
		node.odd = false
	elif(not is_even(node.attack_index)):
		node.even = false
		node.odd = true

func get_is_dead(health):
	return health <= 0

func init_speed(speed):
	if(speed <= 0):
		speed = 1

func set_last_direction(node):
	if(node.movedir.x != 0):
		if(node.last_direction_x == -1 * node.movedir.x):
			node.speed = 0
		node.last_direction_x = node.movedir.x

func reset_attack_indices(node):
	var green_offset = 0
	if(node.is_in_group('green')):
		green_offset = 1
	else:
		node.lite_index = 1 + green_offset
		node.heavy_index = 1 + green_offset
		node.attack_index = 1 + green_offset

func get_parent_node(child):
	return child.get_parent().get_parent()

func release_opponent(node):
	if(node.clinched_opponent):
		node.clinched_opponent.anim.play('released')
		anim_switch(node, 'release')
		node.clinched_opponent = null

func increment_enemy_attack_index(node,attack_type):
	if(node.lite_index == 4 or node.heavy_index == 3):
		node.cooling_down = true
		state_machine(node, states.SEEK)
	elif(attack_type == 'lite'):
		node.lite_index = min(node.lite_index + 1, 4)
		node.attack_index = node.lite_index
	elif(attack_type == 'heavy'):
		node.heavy_index = min(node.lite_index + 1, 3)
		node.attack_index = node.heavy_index
		
func numbered_animation_iterator(node, anim_name):
	for i in range(1, 5):
		if(anim_name == str('death', i)):
			node.queue_free()
		elif(anim_name == str('liteattack', i) or anim_name == str('heavyattack', i)):
			node.cooling_down = false
			if(node.is_in_group('player')):
				node.StateManager.state_machine(node, node.states.IDLE)
				break
			else:
				node.StateManager.increment_enemy_attack_index(node, 'lite')
				break
		elif(anim_name == str('stagger', i)):
			node.StateManager.state_machine(node, node.states.IDLE)
			break

func special_non_interuptable(node):
	if(node.recovering or node.throwing or node.dashing):
		return true
	return false
				
func init_node(node):
	node.state = node.states.IDLE
	node.slip_timer.wait_time = 0.25
	node.slip_timer.one_shot = true
	node.clinch_timer.wait_time = 2.4
	node.clinch_timer.one_shot = true
	node.knockdown_timer.wait_time = 1
	node.knockdown_timer.one_shot = true
