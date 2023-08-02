extends Node3D

@onready var animation_tree = $"../visuals/player/AnimationTree"


var speed = 5
var key_vel = Vector2()
var attack_number = 1
var attack_timeline
var recover_start
var push_forward_start

# animation
var animation_time
var animation_length
var animation_finished = false

var state
var timeout_timer = 0
var await_time = 0

func set_attack(number, my_recover_start, my_push_forward_start, my_speed):
	attack_number = number
	attack_timeline = 0
	recover_start = my_recover_start
	push_forward_start = my_push_forward_start
	speed = my_speed

func input_attack(delta):
	if await_time <= 1:
		await_time += delta
		return
	
	timeout_timer += delta
	if Input.is_action_pressed("kick"):
		state = "ATTACKING"
		if timeout_timer > 3:
			attack_number = 1
			timeout_timer = 0

func _process(delta):
	input_attack(delta)
	
	if state == "ATTACKING":
		animation_tree.set("parameters/attack/transition_request", "true")
	if state == "NORMAL":
		animation_tree.set("parameters/attack/transition_request", "false")
		
	if attack_number == 1:
		animation_tree.set("parameters/attacks/transition_request", "attack1")
	if attack_number == 2:
		animation_tree.set("parameters/attacks/transition_request", "attack2")
	if attack_number == 3:
		animation_tree.set("parameters/attacks/transition_request", "attack3")
	if attack_number == 4:
		animation_tree.set("parameters/attacks/transition_request", "attack4")
		
func count_attack_number():
	timeout_timer = 0
	if attack_number < 4:
		attack_number += 1
	else:
		attack_number = 1
	
func stop_attack():
	state = "NORMAL"
	count_attack_number()
	
#	if timeout_timer != null:
#		timeout_timer.clear()
#
#	timeout_timer = get_tree().create_timer(2.0)
#	await timeout_timer.timeout
#	count_attack_number()

