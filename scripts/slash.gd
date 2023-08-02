extends Node3D

@export var play = false

func _physics_process(delta):
	if play:
		$AnimationPlayer.play("RESET")
