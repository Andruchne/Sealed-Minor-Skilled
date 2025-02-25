extends Node2D

@export var brush_texture: Texture2D

var points : Array = []
var is_drawing : bool = false

# All line segments to check against for intersections
var line_segments : Array = [] # Stores line segment pairs (Vector2, Vector2)
# Current line to check with
var current_line_start : Vector2

var last_direction : Vector2 = Vector2(-1, -1)


func move_draw(pos : Vector2, dir : Vector2) -> void:
	if (is_drawing):
		# Keep info about all line segments
		if last_direction == Vector2(-1, -1):
			last_direction = dir
			current_line_start = pos
		elif last_direction != dir:
			line_segments.append([current_line_start, pos])
			last_direction = dir
			current_line_start = pos
		
		points.append(pos)
		
		print(check_intersection(pos))
		
		queue_redraw()


func set_draw(state : bool, pos : Vector2 = Vector2.ZERO) -> void:
	is_drawing = state
	if state:
		points.append(pos)
	else:
		last_direction = Vector2(-1, -1)
		line_segments.append([current_line_start, pos])
	queue_redraw()


func _draw() -> void:
	if brush_texture:
		for point in points:
			draw_texture(brush_texture, point - brush_texture.get_size() / 2)


func check_intersection(c_point : Vector2) -> bool:
	if (current_line_start == c_point):
		c_point += Vector2(0.1, 0)
	
	var count : int = 0
	for segment in line_segments:
		count += 1
		if (count == line_segments.size()):
			return false
		
		var intersecting = line_segments_intersect(current_line_start, c_point, segment[0], segment[1])
		
		if intersecting:
			return true
	
	return false


# To check whether the line segments intersect
func line_segments_intersect(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var denominator: float = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)
	if denominator == 0:
		# Lines are parallel or coincident.
		return false
	
	var ua: float = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denominator
	var ub: float = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denominator
	
	if ua >= 0 and ua <= 1 and ub >= 0 and ub <= 1:
		# Intersection occurs within the line segments.
		return true
	else:
		# Intersection occurs outside the line segments.
		return false
