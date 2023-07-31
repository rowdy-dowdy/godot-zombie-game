extends CharacterBody3D

@onready var animation_tree = $visuals/zombie1/AnimationTree
@export var player_path : NodePath = "/root/world/player"

@onready var navigation_agent_3d = $NavigationAgent3D

const SPEED = 2.5
const ATTACK_RANGE = 0.8

var player = null
var state_machine

func _ready():
	print(player_path)
	player = get_node(player_path)
	state_machine = animation_tree.get("parameters/playback")
	
func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			navigation_agent_3d.set_target_position(player.global_transform.origin)
			var next_nav_point = navigation_agent_3d.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			
			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			
	# Conditions
	animation_tree.set("parameters/conditions/attack", _target_in_range())
	animation_tree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.1:
		var dir = global_position.direction_to(player.global_position)
		player.take_damage(dir)

func take_damage():
	print('hit')
