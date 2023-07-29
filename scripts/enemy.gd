extends CharacterBody3D

@onready var animation_tree = $visuals/zombie1/AnimationTree

var SPEED = 1
const JUMP_VELOCITY = 4.5

var walking_speed = 1
var running_speed = 3

var running = false

var is_locked = false

@export var sens_horizontal = 0.5
@export var sens_vertical = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	pass

func _physics_process(delta):
	move_and_slide()

func take_damage():
	print('hit')
