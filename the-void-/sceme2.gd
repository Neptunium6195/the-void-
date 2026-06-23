extends Node2D

var snake_body = [Vector2i(5,10), Vector2i(4,10), Vector2i(3,10), Vector2i(2,10)]
var snake_direction = Vector2i(1,0)

const SOURCE_ID = 0

func _ready():
	print("TileSet: ", $snake.tile_set)
	print("Source count: ", $snake.tile_set.get_source_count())
	print("Source ID 0 exists: ", $snake.tile_set.has_source(0))
	$Camera2D.zoom = Vector2(2, 2)
	draw_snake()
	update_camera()

func draw_snake():
	"""print("body size:", snake_body.size(), " body:", snake_body)
	print("HEAD CELL before draw: ", $snake.get_cell_source_id(snake_body[0]))
	print("HEAD atlas: ", $snake.get_cell_atlas_coords(snake_body[0]))
	print("=== DRAW ===")
	print("head pos: ", snake_body[0], " | head_dir: ", relation2(snake_body[0], snake_body[1]))
	print("tail pos: ", snake_body[-1], " | tail_dir: ", relation2(snake_body[-1], snake_body[-2]))
	print("body[1] pos: ", snake_body[1], " | prev: ", snake_body[2] - snake_body[1], " next: ", snake_body[0] - snake_body[1])
	print("other statement--head: ", snake_body[0], " tail: ", snake_body[-1])"""
	for block_index in range(snake_body.size()-1,-1,-1):
		var block = snake_body[block_index]
		
		if block_index == 0:
			if snake_direction == Vector2i(1,0):
				$snake.set_cell(block, SOURCE_ID, Vector2i(2,0))
				#print("right")
			elif snake_direction == Vector2i(-1,0):
				$snake.set_cell(block, SOURCE_ID, Vector2i(3,1))
				#print("down,1")
			elif snake_direction == Vector2i(0,-1):
				$snake.set_cell(block, SOURCE_ID, Vector2i(2,1))
				#print("left,2")
			elif snake_direction == Vector2i(0,1):
				$snake.set_cell(block, SOURCE_ID, Vector2i(3,0))
				#print("up,3")
				
		elif block_index == snake_body.size() - 1:
			
			var tail_dir = snake_body[-1] - snake_body[-2]
			#print("block:", block, " snake_body[-1]:", snake_body[-1], " match:", block == snake_body[-1])
			#print("tail pos: ", snake_body[-1], " prev pos: ", snake_body[-2], " tail_dir: ", tail_dir)
			if tail_dir == Vector2i(1,0):
				$snake.set_cell(block, SOURCE_ID, Vector2i(1,0))
				#print(" Left 1")
			elif tail_dir == Vector2i(-1,0):
				$snake.set_cell(block, SOURCE_ID, Vector2i(0,0))
				#print("Right 2")
			elif tail_dir == Vector2i(0,1):
				$snake.set_cell(block, SOURCE_ID, Vector2i(1,1))
				#print(" Up 3")
			elif tail_dir == Vector2i(0, -1):
				#print("Down")
				$snake.set_cell(block, SOURCE_ID, Vector2i(0,1))
		else:
			var prev = snake_body[block_index + 1] - block
			var next = snake_body[block_index - 1] - block

			if prev.y == 0 and next.y == 0:
				$snake.set_cell(block, SOURCE_ID, Vector2i(4,0))  # horizontal
			elif prev.x == 0 and next.x == 0:
				$snake.set_cell(block, SOURCE_ID, Vector2i(4,1))  # vertical
			elif (prev == Vector2i(0,1) and next == Vector2i(-1,0)) or (prev == Vector2i(-1,0) and next == Vector2i(0,1)):#1or (prev == Vector2i(1,0) and next == Vector2i(0,-1)):
				print("1")
				$snake.set_cell(block, SOURCE_ID, Vector2i(6,0))  # was 5,0 now 6,0
			elif (prev == Vector2i(0,1) and next == Vector2i(1,0)) or (prev == Vector2i(1,0) and next == Vector2i(0,1)): #or (prev == Vector2i(-1,0) and next == Vector2i(0,-1)):
				print("2")
				$snake.set_cell(block, SOURCE_ID, Vector2i(5,0))  # was 6,0 now 5,0
			elif (prev == Vector2i(0,-1) and next == Vector2i(-1,0)) or (prev == Vector2i(-1,0) and next == Vector2i(0,-1)):
				print("3")
				$snake.set_cell(block, SOURCE_ID, Vector2i(6,1))  # was 5,1 now 6,1
			elif (prev == Vector2i(0,-1) and next == Vector2i(1,0)) or (prev == Vector2i(1,0) and next == Vector2i(0,-1)):#or (prev == Vector2i(-1,0) and next == Vector2i(0,1)):
				print("4")
				$snake.set_cell(block, SOURCE_ID, Vector2i(5,1))  # was 6,1 now 5,1
			else:
				print("AHH prev:", prev, " next:", next)

func relation2(first_block: Vector2i, second_block: Vector2i):
	var block_relation = second_block - first_block
	if block_relation == Vector2i(-1, 0): return 'left'
	if block_relation == Vector2i(1, 0): return 'right'
	if block_relation == Vector2i(0, 1): return 'down'
	if block_relation == Vector2i(0, -1): return 'up'

func move_snake():
	snake_direction = buffer_dir
	delete_tiles()
	var new_head = snake_body[0] + snake_direction
	snake_body.insert(0, new_head)
	snake_body.pop_back()
	#print("moving, direction: ", snake_direction)

func delete_tiles():
	var cells = $snake.get_used_cells()
	for cell in cells:
		$snake.erase_cell(cell)

func update_camera():
	var tile_size = $snake.tile_set.tile_size
	# Convert tile coords to world position accounting for TileMapLayer's own position
	var head_world_pos = $snake.map_to_local(snake_body[0])
	$Camera2D.global_position = head_world_pos
	
var buffer_dir = Vector2i(1,0)
	
func _input(event):
	if Input.is_action_just_pressed("ui_up"):
		if snake_direction != Vector2i(0, 1):
			buffer_dir = Vector2i(0, -1)
			#print("up press")
	if Input.is_action_just_pressed("ui_right"):
		if snake_direction != Vector2i(-1, 0):
			buffer_dir = Vector2i(1, 0)
			#print("right press")
	if Input.is_action_just_pressed("ui_left"):
		if snake_direction != Vector2i(1, 0):
			buffer_dir = Vector2i(-1, 0)
			#print("left press")
	if Input.is_action_just_pressed("ui_down"):
		if snake_direction != Vector2i(0, -1):
			buffer_dir = Vector2i(0, 1)
			#print("down press")

"""func check_game_over():
	var head = snake_body[0]
	for block in snake_body.slice(1, snake_body.size()-1):
		if block == head:
			reset()"""

func reset():
	snake_body = [Vector2i(5,10), Vector2i(4,10), Vector2i(3,10), Vector2i(2,10)]
	snake_direction = Vector2i(1, 0)
	
func _process(delta):
	#check_game_over()
	pass
	
func _on_timer_timeout() -> void:
	move_snake()
	draw_snake()
	update_camera()
	pass # Replace with function body.
