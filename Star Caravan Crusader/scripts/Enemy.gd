extends KinematicBody

var paths = []
var num_path = 0
var speed = 6
onready var nav = get_parent().get_node("Navigation")

func _ready():
	pass

func vector2_to_vector3(vectors):
	for vec in vectors:
		paths.append(Vector3(vec.x, 0, vec.y))

func _physics_process(delta):
	if paths != []:
		var direction = (paths[num_path] - global_transform.origin)
		if direction.length() < 1:
			if num_path < paths.size() -1:
				num_path += 1
		else:
			$Camera.look_at(get_parent().get_node("Player Person").global_transform.origin, Vector3.UP)
			move_and_slide(direction.normalized() * speed, Vector3.UP)

func move_to(target_pos):
	paths = nav.get_simple_path(global_transform.origin, target_pos)
	num_path = 0
