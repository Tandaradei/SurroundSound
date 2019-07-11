extends Spatial

# All of the audio files.
# You will need to provide your own sound files.
var audio_footstep_wood = preload("res://step2.ogg")
var audio_footstep_concrete = preload("res://step1.ogg")

var audio_node = null

func _ready():
	audio_node = $Audio_Stream_Player
	audio_node.connect("finished", self, "destroy_self")
	audio_node.stop()


func play_sound(sound_name, position=null):

	if audio_footstep_wood == null or audio_footstep_concrete == null :
		print ("Audio not set!")
		queue_free()
		return

	if sound_name == "footstep_wood":
		audio_node.stream = audio_footstep_wood
	elif sound_name == "footstep_concrete":
		audio_node.stream = audio_footstep_concrete
	else:
		print ("UNKNOWN STREAM")
		queue_free()
		return

	if audio_node is AudioStreamPlayer3D:
		if position != null:
			audio_node.global_transform.origin = position

	audio_node.play()


func destroy_self():
	audio_node.stop()
	queue_free()