extends VideoStreamPlayer

var video_playlist: Array[String] = [
	"res://Assets/Untitled_Artwork-4.ogv",
	"res://Assets/Untitled_Artwork-2.ogv"
]
var current_video_index: int = 0

func _ready() -> void:
	self.finished.connect(_on_video_finished)
	play_video(current_video_index)

func play_video(index: int) -> void:
	if index < video_playlist.size():
		print("Loading and playing video index: ", index)
		self.stream = load(video_playlist[index])
		self.play()
	else:
		print("Reached the end of the playlist!")

func _on_video_finished() -> void:
	current_video_index += 1
	play_video(current_video_index)
