extends KinematicBody2D

const StateManagerLoad = preload("res://Helpers/StateManager.gd")
var StateManager = StateManagerLoad.new()

var states = StateManager.states
var state = states.IDLE
var movedir = Vector2()
var knockdir = null

var speed = 1
var max_speed = 300
var health = 100
var death_version = 1
var last_direction_x = -1

var throwing = false
var dashing = false
var recovering = false

var is_dodging = false
var cooling_down = false
var can_counter = false
var blocking = false

var odd = false
var even = false
var countering = false

##clinch vars
var clinched_opponent = null
var clinching_opponent = null
var pummeled = true

onready var SELF = self
onready var sprite = $Sprite
onready var blast_spawn = $Sprite/BlastSpawn
onready var anim = $anim
onready var slip_timer = $SlipTimer
onready var hitbox = $Sprite/HitBox
onready var hitbox_collision = $Sprite/HitBox/CollisionShape2D
onready var hit_collider = $Sprite/HitCollider/CollisionShape2D
onready var counter_bubble = $Sprite/CounterBubble
onready var body_collider = $BodyCollider
onready var clinch_timer = $ClinchTimer
onready var throw_timer = $ThrowTimer
onready var knockdown_timer = $KnockdownTimer
onready var clinch_point = $Sprite/ClinchPoint
onready var damage_numbers = $DamageNumbers

var lite_index = 1
var heavy_index = 1
var attack_index = 1

func _ready():
	StateManager.init_node(SELF)

func _on_HitBox_area_entered(area):
	StateManager.HitBoxManager.hitbox_loop(SELF, area)

func _on_SlipTimer_timeout():
	StateManager.TimerManager.slip(SELF)

func _on_ClinchTimer_timeout():
	StateManager.release_opponent(SELF)
	
func _on_ThrowTimer_timeout():
	StateManager.TimerManager.throw(SELF)
	
func _on_KnockdownTimer_timeout():
	StateManager.TimerManager.recover(SELF)
	
func _on_anim_animation_finished(anim_name):
	StateManager.AnimationManager.animation_finished(SELF, anim_name)
