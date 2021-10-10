extends Spatial

onready var cam = $Camera
onready var car = $"Main car"
onready var label = $Control/Label

var entered = false
var on_car = false
var player
func _ready():
	pass

func _input(event):
	if event.is_action_pressed("interact"):
		label.visible = false
		if entered:
			cam.current = true
			car.can_run = true
			player.queue_free()
			entered = false
			on_car = true
			self.remove_child(car)
			self.remove_child(cam)
			get_parent().add_child(car)
			get_parent().add_child(cam)
		elif on_car:
			cam.current = false
			car.can_run = false
			on_car = false
			var player_inst = preload("res://scenes/Player Person.tscn")
			player_inst = player_inst.instance()
			get_parent().add_child(player_inst)
			player_inst.set_camera_current(true)
			player_inst.global_transform = car.global_transform
			player_inst.global_transform.origin.x += 5
			player_inst.look_at(car.global_transform.origin, player_inst.transform.basis.y)
			
func _on_Area_body_entered(body):
	if body.is_in_group("FPS player"):
		entered = true
		player = body
		label.visible = true


func _on_Area_body_exited(body):
	if body.is_in_group("FPS player"):
		entered = false
		player = null
		label.visible = false
