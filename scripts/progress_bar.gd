extends ColorFrame

onready var end = get_tree().get_root().get_node("CRT/Viewport/level/trees/tree_end/end")
onready var squirrel = get_tree().get_root().get_node("CRT/Viewport/level/squirrel")
var old_progress = 0
onready var total_distance = end.get_global_pos().x - squirrel.get_global_pos().x

func _ready():
	set_scale(Vector2(0, 1))
	set_process(true)

func _process(delta):
	var progress = (((end.get_global_pos().x - squirrel.get_pos().x) / total_distance) - 1) * -1

	if progress > old_progress:
		old_progress = progress
		set_scale(Vector2(min(progress, 1), 1))
	
	if progress >= 1 and global.running:
		global.the_end()
	