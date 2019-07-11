extends CollisionShape

export var type = "wood"

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
