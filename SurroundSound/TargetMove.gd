extends Spatial

const SPEED = 16.0
var time = 0.0
const FREQUENCY = 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	var dir = 1.0
	if int(time / FREQUENCY) % 2 == 0:
		dir = -1.0
	self.global_translate(Vector3(0, 0, SPEED * dir * delta)) 
