extends Node3D

@onready var color_rect = $UI/ColorRect
@onready var spawns = $map/Spawns
@onready var navigation_region = $map/NavigationRegion3D

var zombie = load("res://scenes/enemy.tscn")
var instance

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_player_hit():
	color_rect.visible = true
	await get_tree().create_timer(0.2).timeout
	color_rect.visible = false

func _get_ramdom_child(parent_node):
	var random_id = randi() % parent_node.get_child_count()
	print(random_id)
	return parent_node.get_child(random_id)

func _on_zombie_spawn_timer_timeout():
#	var spawn_point = _get_ramdom_child(spawns).global_position
#	instance = zombie.instantiate()
#	instance.position = spawn_point
#	navigation_region.add_child(instance)
