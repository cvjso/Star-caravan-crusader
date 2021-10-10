extends Camera

var SPEED = 8
var MIN_DIST = 10
onready var tween = $Tween
var past_rot = 0
var current_rot = 0

func _process(delta):
	var player = get_parent().get_node("Main car")
	var player_pos = player.get_node("camera follower").global_transform.origin
	var diff = player_pos.z - self.translation.z
	current_rot = player.rotation_degrees.y

	self.global_transform.origin = self.global_transform.origin.linear_interpolate(player_pos, delta * SPEED)


	var wanted_angle = player.rotation_degrees.y
	if player.rotation_degrees.y > rotation_degrees.y+180:
		wanted_angle -= 360
	elif player.rotation_degrees.y < rotation_degrees.y-180:
		wanted_angle += 360
	
	tween.interpolate_property(self, "rotation_degrees:y", self.rotation_degrees.y, wanted_angle, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT )
	tween.start()

