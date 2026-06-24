extends Node2D

var snake_body = [Vector2i(5,10), Vector2i(4,10), Vector2i(3,10), Vector2i(2,10)]
var snake_direction = Vector2i(1,0)
#var snake_body = [Vector2i(67,29), Vector2i(66,29), Vector2i(65,29), Vector2i(64,29)]

const SOURCE_ID = 0
var visual_head_pos: Vector2

# Add these variables at the top
var found_letters = ["_", "_", "_", "_", "_", "_"]  # s,c,h,i,z,o

# Atlas ranges for each letter (min corner, max corner)
const LETTER_ATLAS = {
	"s": {"min": Vector2i(0,1), "max": Vector2i(2,3)},
	"c": {"min": Vector2i(0,1), "max": Vector2i(2,2)},
	"h": {"min": Vector2i(1,0), "max": Vector2i(2,2)},
	"i": {"min": Vector2i(1,0), "max": Vector2i(2,2)},
	"z": {"min": Vector2i(1,1), "max": Vector2i(2,3)},
	"o": {"min": Vector2i(1,0), "max": Vector2i(3,2)},
}

const WORD = ["s", "c", "h", "i", "z", "o"]

func get_letter_at(tile: Vector2i) -> String:
	var atlas = $layers.get_cell_atlas_coords(tile)
	if atlas == Vector2i(-1, -1):
		return ""  # empty cell
	for letter in LETTER_ATLAS:
		var min_a = LETTER_ATLAS[letter]["min"]
		var max_a = LETTER_ATLAS[letter]["max"]
		if atlas.x >= min_a.x and atlas.x <= max_a.x and \
			atlas.y >= min_a.y and atlas.y <= max_a.y:
			return letter
	return ""

func check_letter_collected():
	var head = snake_body[0]
	var letter_layers = {
		"s": $s,
		"c": $c,
		"h": $h,
		"i": $i,
		"z": $z,
		"o": $o,
	}
	for letter in letter_layers:
		var layer = letter_layers[letter]
		if layer.get_cell_source_id(head) != -1:
			
			print("detected letter: '", letter, "'")
			print(WORD.size())
			for i in range(WORD.size()):
				print("comparing WORD[", i, "]='", WORD[i], "' with letter='", letter, "' match:", WORD[i] == letter)
				if WORD[i] == letter and found_letters[i] == "_":
					found_letters[i] = letter
					for cell in layer.get_used_cells():
						layer.erase_cell(cell)
					update_word_display()
					break

func erase_letter(hit_tile: Vector2i, letter: String):
	for cell in $layers.get_used_cells():
		var atlas = $layers.get_cell_atlas_coords(cell)
		var min_a = LETTER_ATLAS[letter]["min"]
		var max_a = LETTER_ATLAS[letter]["max"]
		if atlas.x >= min_a.x and atlas.x <= max_a.x and atlas.y >= min_a.y and atlas.y <= max_a.y:
			$layers.erase_cell(cell)

func update_word_display():
	print("updating display: ", found_letters)
	$CanvasLayer/Label.text = " ".join(found_letters)

func _ready():
	print("letter_s global pos: ", $s.global_position)
	update_word_display()
	
	$Camera2D.zoom = Vector2(1.5, 1.5)
	draw_snake()
	visual_head_pos = $snake.map_to_local(snake_body[0])
	$Camera2D.global_position = visual_head_pos
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
	var new_head = snake_body[0] + snake_direction
	var new_head_pixel = $snake.map_to_local(new_head)
	"""print("checking: ", new_head, " h:", $walls.get_cell_source_id(new_head), " v:", $walls2.get_cell_source_id(new_head))
	if $walls.get_cell_source_id(new_head) != -1 || $walls2.get_cell_source_id(new_head) != -1:
		print("wall")
		return"""
	var hit_wall = false
	for cell in $walls.get_used_cells():
		var wall_pixel = $walls.map_to_local(cell)
		if new_head_pixel.distance_to(wall_pixel) < $snake.tile_set.tile_size.x:
			hit_wall = true
			break
	if not hit_wall:
		for cell in $walls2.get_used_cells():
			var wall_pixel = $walls2.map_to_local(cell)
			if new_head_pixel.distance_to(wall_pixel) < $snake.tile_set.tile_size.x:
				hit_wall = true
				break
	if hit_wall:
		print("wall hit!")
		return  
		
	delete_tiles()
	snake_body.insert(0, new_head)
	snake_body.pop_back()
	#print("moving, direction: ", snake_direction)

func delete_tiles():
	var cells = $snake.get_used_cells()
	for cell in cells:
		$snake.erase_cell(cell)

func update_camera():
	var target = $snake.map_to_local(snake_body[0])
	visual_head_pos = target
	
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
	var target = $snake.map_to_local(snake_body[0])
	$Camera2D.global_position = $Camera2D.global_position.lerp(target, delta * 8.0)
	pass
	
func _on_timer_timeout() -> void:
	move_snake()
	check_letter_collected()
	draw_snake()
	update_camera()
	pass # Replace with function body.
