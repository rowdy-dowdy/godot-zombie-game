extends Node3D

@onready var color_rect = $UI/ColorRect
@onready var navigation_region = $map/NavigationRegion3D

var zombie = load("res://scenes/enemy.tscn")

var enemies_count = 0 
var enemies_point = 0

var game_pause = true
var reload = false

func _ready():
	get_tree().paused = true
	game_pause = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_player_player_hit():
	color_rect.visible = true
	$OughAduio.play()
	await get_tree().create_timer(0.2).timeout
	color_rect.visible = false

func _on_zombie_spawn_timer_timeout():
	if enemies_count >= 50:
			return

	for i in range(1, 5):
		var random_x = randf_range(-48, 48)
		var random_z = randf_range(-48, 48)
		var spawn_point = Vector3(random_x,0,random_z)
		var instance: CharacterBody3D = zombie.instantiate()
		instance.position = spawn_point
		instance.scale = Vector3(1.2, 1.2, 1.2)
		instance.connect("enemy_die", _on_destroy_enemy)
		navigation_region.add_child(instance)
		enemies_count += 1

func _on_destroy_enemy():
	enemies_point += 1
	$UI/Point.text = "Point: " + str(enemies_point)


func _on_button_pressed():
	if game_pause:
		if reload:
			$player.restart()
			enemies_point = 0
		else:
			get_tree().paused = false
		
		$UI/PanelPlay.visible = false		
		reload = false
		game_pause = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _on_player_losed():
	$UI/PanelPlay.visible = true
	$UI/PanelPlay/Coin.visible = true
	$UI/PanelPlay/Coin.text = "The end\nPoint: " + str(enemies_point)
	$UI/PanelPlay/Button.text = "Restart"
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	reload = true
	game_pause = true
