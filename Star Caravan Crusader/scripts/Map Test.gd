extends Spatial

onready var minimap = $minimap
onready var player = $"Player Person"
onready var enemy = $Enemy
onready var nav_mesh = $Navigation/NavigationMeshInstance
export var many_tiles = 7
export(String, "Enemy", "Player", "Debug") var GAME_VIEW
var size_tile = 16
var minimap_margin = 20
var directions = ["up", "down", "left", "right"]
var cannot_go_dic = {
	"up": "down",
	"down": "up",
	"left": "right",
	"right": "left",
	"": ""
}
var last_move = ""
var new_pos = ""
var positions = []
var not_allowed_coords = []
var last_position = Vector2()
var current_tile_pos = Vector2(0,0)
var Graph = Global.Graph.new()
var astar = Global.Astar.new()

func _ready():
	match(GAME_VIEW):
		"Enemy":
			$Enemy/Camera.current = true
			$"Player Person/Head/Camera".current = false
			$Camera.current = false
		"Player":
			$Enemy/Camera.current = false
			$"Player Person/Head/Camera".current = true
			$Camera.current = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		"Debug":
			$Enemy/Camera.current = false
			$"Player Person/Head/Camera".current = false
			$Camera.current = true
	#var my_seed = "aaaaa"
	#seed(my_seed.hash())
	randomize()
	random_map()
	place_walls()

	astar.not_allowed = not_allowed_coords
	enemy.transform.origin.x = positions[many_tiles-1].x
	enemy.transform.origin.z = positions[many_tiles-1].y
	var origen = Vector2(enemy.global_transform.origin.x, enemy.global_transform.origin.z)
	var enem_ast = Global.AstarNode.new(null, origen, origen, Vector2(0,0))
	astar.set_origin(enem_ast)
	astar.set_target(Vector2(0,0))
	astar.add_node(Vector2(enemy.global_transform.origin.x, enemy.global_transform.origin.z))
	var best_path = astar.start()
	enemy.vector2_to_vector3(best_path)
	

func _process(delta):
	var player_pos_x = player.transform.origin.x
	var player_pos_z = player.transform.origin.z
	var min_x = current_tile_pos.x - (size_tile/2)
	var max_x = current_tile_pos.x + (size_tile/2)
	var min_y = current_tile_pos.y - (size_tile/2)
	var max_y = current_tile_pos.y + (size_tile/2)
	if player_pos_x >= max_x or player_pos_x <= min_x or player_pos_z >= max_y or player_pos_z <= min_y:
		update_player_minimap()

func place_walls():
	for tile in positions:
		var neighbours = get_neighbours(tile)
		for key in neighbours.keys():
			var door = preload("res://scenes/Door Tile.tscn").instance()
			var wall = preload("res://scenes/Wall Tile.tscn").instance()
			var chosen_one
			if neighbours[key]:
				nav_mesh.add_child(door)
				chosen_one = door
			else:
				nav_mesh.add_child(wall)
				chosen_one = wall
			var should_rotate = false
			match(key):
				"left":
					door.transform.origin.x = tile.x - size_tile/2
					door.transform.origin.z = tile.y
					door.rotation_degrees.y = 90
					wall.transform.origin.x = tile.x - size_tile/2
					wall.transform.origin.z = tile.y
					wall.rotation_degrees.y = 90
					should_rotate = true
				"right":
					door.transform.origin.x = tile.x + size_tile/2
					door.transform.origin.z = tile.y
					door.rotation_degrees.y = 90
					wall.transform.origin.x = tile.x + size_tile/2
					wall.transform.origin.z = tile.y
					wall.rotation_degrees.y = 90
					should_rotate = true
				"up":
					door.transform.origin.x = tile.x 
					door.transform.origin.z = tile.y + size_tile/2
					wall.transform.origin.x = tile.x
					wall.transform.origin.z = tile.y + size_tile/2
				"down":
					door.transform.origin.x = tile.x 
					door.transform.origin.z = tile.y - size_tile/2
					wall.transform.origin.x = tile.x
					wall.transform.origin.z = tile.y - size_tile/2
			
			for child in chosen_one.get_children():
				# TODO: Resolver essa merda ai
				# boa sorte viu, vai precisar
					var size_x = child.mesh.get_aabb().size.x
					var size_y = child.mesh.get_aabb().size.z
					if should_rotate:
						var temp = size_x
						size_x = size_y
						size_y = temp
					var min_x = -size_x/2 + child.global_transform.origin.x
					var min_y = -size_y/2 + child.global_transform.origin.z
					var max_x = size_x/2 + child.global_transform.origin.x
					var max_y = size_y/2 + child.global_transform.origin.z
					print(child.global_transform.origin.z)
					for i in range(min_x, max_x+1):
						var banned_cord = Vector2(i,min_y)
						if !not_allowed_coords.has(banned_cord):
							not_allowed_coords.append(banned_cord)
							print(banned_cord)
						banned_cord = Vector2(i,max_y)
						if !not_allowed_coords.has(banned_cord):
							not_allowed_coords.append(banned_cord)
							print(banned_cord)
					for i in range(min_y, max_y+1):
						var banned_cord = Vector2(min_x,i)
						if !not_allowed_coords.has(banned_cord):
							not_allowed_coords.append(banned_cord)
							print(banned_cord)
						banned_cord = Vector2(max_x,i)
						if !not_allowed_coords.has(banned_cord):
							not_allowed_coords.append(banned_cord)
							print(banned_cord)

func get_neighbours(_current_tile:Vector2):
	# TODO: Fazer um dicionario completo com a rotação de cada lado com o preload de cada objeto ai e não no match
	var neighbours = {
		"left": 0,
		"right": 0,
		"up": 0,
		"down": 0
	}
	for i in positions:
		if _current_tile.x - size_tile == i.x and _current_tile.y == i.y:
			neighbours["left"] = 1
		elif _current_tile.x + size_tile == i.x and _current_tile.y == i.y:
			neighbours["right"] = 1
		elif _current_tile.y - size_tile == i.y and _current_tile.x == i.x:
			neighbours["down"] = 1
		elif _current_tile.y + size_tile == i.y and _current_tile.x == i.x:
			neighbours["up"] = 1
	return neighbours

func verify_player_on_tile():
	var p_pos_x = int(player.transform.origin.x)
	var p_pos_z = int(player.transform.origin.z)
	for tile in positions:
		var min_x = tile.x - (size_tile/2)
		var max_x = tile.x + (size_tile/2)
		var min_y = tile.y - (size_tile/2)
		var max_y = tile.y + (size_tile/2)
		if (p_pos_x >= min_x and p_pos_x <= max_x) and (p_pos_z >= min_y and p_pos_z <= max_y):
			return tile
	return null

func update_player_minimap():
	var new_tile_pos = 0
	var new_tile = verify_player_on_tile()
	if new_tile != null:
		new_tile_pos = positions.find(new_tile)
		current_tile_pos = new_tile
	var old_tile
	for child in minimap.get_children():
		if child.frame == 1:
			old_tile = child
		child.frame = 0
	var new_tile_child = minimap.get_child(new_tile_pos)
	var diff_x = old_tile.position.x - new_tile_child.position.x
	var diff_y = old_tile.position.y - new_tile_child.position.y
	new_tile_child.frame = 1
	minimap.rect_position.x += diff_x
	minimap.rect_position.y += diff_y

func random_map():
	var first_sample = preload("res://scenes/Ground Tile.tscn").instance()
	nav_mesh.add_child(first_sample)
	positions.append(Vector2(0,0))
	for i in range(many_tiles - 1):
		var random_move = directions[randi() % directions.size()]
		new_pos = last_position
		while random_move == cannot_go_dic[last_move] or verify_position(random_move):
			random_move = directions[randi() % directions.size()]
		last_move = random_move
		last_position = new_pos
		var sample = preload("res://scenes/Ground Tile.tscn").instance()
		nav_mesh.add_child(sample)
		positions.append(new_pos)
		sample.transform.origin.x = new_pos.x
		sample.transform.origin.z = new_pos.y
		update_map(random_move)

func update_map(new_direction):
	var dup_room = minimap.get_child(minimap.get_child_count() - 1).duplicate()
	dup_room.frame = 0
	minimap.add_child(dup_room)
	match(new_direction):
		"up":
			dup_room.position.y += minimap_margin
		"down":
			dup_room.position.y -= minimap_margin
		"left":
			dup_room.position.x -= minimap_margin
		"right":
			dup_room.position.x += minimap_margin

func verify_position(direction):
	match(direction):
		"up":
			new_pos.y += size_tile
		"down":
			new_pos.y -= size_tile
		"left":
			new_pos.x -= size_tile
		"right":
			new_pos.x += size_tile
	if new_pos in positions:
		new_pos = last_position
		return true
	else:
		return false
