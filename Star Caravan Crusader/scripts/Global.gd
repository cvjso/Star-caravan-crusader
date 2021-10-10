extends Node

class AstarNode:
	var parent
	var value := Vector2()
	var g_cost
	var h_cost
	var f_cost
	var neighbours = [] # Lista de Vectors2
	var weight_diag = 1.4
	
	func _init(_parent=null, _value=Vector2(), origin=null, target=null):
		parent = _parent
		value = _value
		if _parent == null:
			g_cost = 0
		else:
			g_cost = _parent.g_cost + personal_dist(_parent.value, value)
		h_cost = personal_dist(value, target)
		f_cost = h_cost + g_cost
		for i in range(-1, 2):
			for j in range(-1, 2):
				if Vector2(value.x + i, value.y + j) != value:
					neighbours.append(Vector2(value.x + i, value.y + j))
	
	func set_g_cost(value):
		g_cost = value
		f_cost = g_cost + h_cost
	
	func personal_dist(value, target):
		if has_diagonals(value, target):
			var diff_x = target.x - value.x
			var diff_y = target.y - value.y
			var lowest_dist = diff_x if diff_x > diff_y else diff_y
			var closest_point = Vector2(lowest_dist + value.x, lowest_dist + value.y)
			return ((weight_diag * lowest_dist) + dist_manhattan(closest_point, target))
		else:
			return dist_manhattan(value, target)
	
	func has_diagonals(value, target):
		if target.x == value.x or target.y == value.y:
			return false
		return true
	
	func distance(origin, target):
		return sqrt(pow(origin.x - target.x,2) + pow(target.y - origin.y,2))
	
	func dist_manhattan(origin, target):
		var dist_h = target.x - origin.x
		var dist_v = target.y - origin.y
		dist_h = dist_h * -1 if dist_h < 0 else dist_h
		dist_v = dist_v * -1 if dist_v < 0 else dist_v
		return (dist_h + dist_v)
	
	func set_parent(_parent):
		parent = _parent

class Astar:
	var not_allowed = []
	var nodes = []
	var open = []
	var closed = []
	var origin = null
	var target = null

	func get_lowest_f_cost():
		var lowest_node = null
		for node in open:
			if lowest_node == null or node.f_cost < lowest_node.f_cost:
				lowest_node = node
		if lowest_node != null:
			open.erase(lowest_node)
			return lowest_node
	
	func add_node(new_node:Vector2, parent=null):
		var new_obj = Global.AstarNode.new(parent, new_node, origin.value, target)
		nodes.append(new_obj)
		return new_obj
		
	func set_origin(_origin:AstarNode):
		origin = _origin
	
	func set_target(_target):
		target = _target
	
	func get_node_by_value(value):
		for node in nodes:
			if node.value == value:
				return node
	
	func node_exists(possible_node):
		for node in nodes:
			if possible_node == node.value:
				return true
		return false
	
	func start():
		open = [origin]
		closed = []
		var current = Global.AstarNode.new(null, Vector2(target.x+1,target.y+1), origin.value, target)
		while(current.value != target):
			current = get_lowest_f_cost()
			closed.append(current)
			if current.value == target:
				break
			
			for neighbour in current.neighbours:
				if !not_allowed.has(neighbour):
					var n_neighbour
					if node_exists(neighbour):
						n_neighbour = get_node_by_value(neighbour)
					else:
						n_neighbour = add_node(neighbour, current)
						open.append(n_neighbour)
					if !closed.has(n_neighbour):
						var possible_new_dist = current.personal_dist(current.value, n_neighbour.value)
						var shorter = possible_new_dist + current.g_cost < n_neighbour.g_cost
						var inside =  open.has(n_neighbour)
						if shorter or !inside:
							n_neighbour.set_g_cost(possible_new_dist + current.g_cost) # Atualizo o F cost também
							n_neighbour.set_parent(current)
							if !inside:
								open.append(n_neighbour)

		var paths = []
		var passant = current
		while(passant != null):
			paths.append(passant.value)
			passant = passant.parent
		paths.invert()
		return paths












class Graph:
	var vertices = {}
	var default_weight = 1
	
	func add_vertice(vertice, nex_vert):
		if typeof(nex_vert) == TYPE_ARRAY:
			vertices[vertice] = {"value": 0, "adj_vert": nex_vert, "from": null}
		else:
			vertices[vertice] = {"value": 0, "adj_vert": [nex_vert], "from": null}
	
	func vertice_exists(vertice):
		if vertice in vertices.keys():
			return true
		else:
			return false
	
	func vertice_distance(start, end):
		var lista_ordem = [start]
		
		while(lista_ordem != []):
			var current_vert = lista_ordem[0]
			var connections = vertices[current_vert]["adj_vert"]
			for target_vert in connections:
				var val_vert = vertices[current_vert]["value"]
				var edge_val = default_weight
				var target_val = vertices[target_vert]["value"]
				lista_ordem.append(target_vert)
				if val_vert + edge_val < target_val:
					vertices[target_vert]["value"] = val_vert + edge_val
					vertices[target_vert]["from"] = current_vert
			lista_ordem.pop_front()
		
		print("from %s to %s has value of %s"%[start,end, vertices[end]["value"]])
		var percourse = [end]
		var loop_vert = vertices[end]
		while loop_vert["from"] != null:
			percourse.append(loop_vert["from"])
			loop_vert = vertices[loop_vert["from"]]
		percourse.invert()
		print(percourse)
