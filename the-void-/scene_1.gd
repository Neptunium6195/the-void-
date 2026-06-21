extends Node2D

@onready var video:= $VideoStreamPlayer
@onready var video2:= $VideoStreamPlayer2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogic_timeline_ended)
	video.finished.connect(_on_video_stream_player_finished)
	video2.finished.connect(_on_video_stream_player_2_finished)
	
	video.stream = load("res://Assets/Untitled_Artwork-4.ogv")
	video2.stream = load("res://Assets/Untitled_Artwork-2.ogv")
	
	video2.visible = false
	video.visible = true
	
	video.play()
	print("hi")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_video_stream_player_finished() -> void:
	await get_tree().create_timer(1).timeout
	Dialogic.start("res://scene1.dtl")
	video.visible = false
	#video2.visible = true
	#video2.play()
	#Dialogic.start_timeline("res://scene1.dtl")

func _on_dialogic_timeline_ended() -> void:
	print("Timeline finished! Starting video 2 now.")
	video2.visible = true
	video2.play()


func _on_video_stream_player_2_finished() -> void:
	await get_tree().create_timer(1).timeout
	video2.visible = false
	Dialogic.start("res://scene1b.dtl")
	pass # Replace with function body.
