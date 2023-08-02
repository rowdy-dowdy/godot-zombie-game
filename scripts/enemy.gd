extends CharacterBody3D

@onready var animation_tree = $visuals/zombie1/AnimationTree
@export var player_path : NodePath = "/root/world/player"

#var floating_text = preload("res://scenes/floating_text.tscn")

@onready var navigation_agent_3d = $NavigationAgent3D

const SPEED = 1
const ATTACK_RANGE = 0.8
const HIT_STAGGER = 8

var hp = 100
var despawn_timer = 0

var player = null

# singal
signal enemy_die

func _ready():
	player = get_node(player_path)
	
func delete_enemy(delta):
	if despawn_timer > 0:
		despawn_timer -= delta
		if despawn_timer <= 0:
			queue_free()
	
func _process(delta):
	delete_enemy(delta)
	
	if hp <= 0:
		animation_tree.set("parameters/die/transition_request", "true")
		return
		
	velocity = Vector3.ZERO
	
	if player == null or player.hp <= 0:
		animation_tree.set("parameters/attack/transition_request", "false")
		animation_tree.set("parameters/moving/transition_request", "idle")
		return
	
	if animation_tree.get("parameters/reaction/current_state") == "false":
		if animation_tree.get("parameters/attack/current_state") == "false":
			navigation_agent_3d.set_target_position(player.global_transform.origin)
			var next_nav_point = navigation_agent_3d.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED

			look_at(Vector3(player.global_position.x + velocity.x, global_position.y, player.global_position.z + velocity.z), Vector3.UP)
		else:
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)

		# Conditions
		if _target_in_range():
			animation_tree.set("parameters/attack/transition_request", "true")
		else:
			animation_tree.set("parameters/attack/transition_request", "false")
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 0.1:
		var dir = global_position.direction_to(player.global_position)
		player.take_damage(dir)


func take_damage(damage_amount, dir):
	hp -= damage_amount
	
	if hp <= 0:
		despawn_timer = 2.0
		emit_signal("enemy_die")
	animation_tree.set("parameters/reaction/transition_request", "true")
	
func stop_react():
	animation_tree.set("parameters/reaction/transition_request", "false")
