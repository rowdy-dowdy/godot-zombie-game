extends Node3D

var vel = Vector3()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vel = get_parent().velocity
	var vert_collide = $player/vertical_ray.is_colliding()
	var speed = get_parent().speed
	
	var on_floor = get_parent().is_on_floor() or vert_collide
	
	var vel2d = Vector2(vel.x, vel.z)
	
	$player/vertical_ray.target_position = Vector3(0, vel.y * 0.1 - 0.05, 0)
	
	var my_speed = vel2d.length() / speed
	$player/AnimationTree.set("parameters/base_move/blend_position", my_speed)
	
	if !on_floor:
		$player/AnimationTree.set("parameters/state/transition_request", "jump")
	else:
		$player/AnimationTree.set("parameters/state/transition_request", "ground")
