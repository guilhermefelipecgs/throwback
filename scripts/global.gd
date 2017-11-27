extends Node

var level = load("res://scenes/level.tscn")
var current_level
var home = true
var can_start = true
var running = false
var game_over = false

onready var viewport = get_tree().get_root().get_node("CRT/Viewport")

func run():
	running = true

func _ready():
	set_process_input(true)

func _input(event):
	if can_start:
		if home and Input.is_action_pressed("ui_accept"):
			start()
			viewport.get_node("home").queue_free()
			home = false
		elif Input.is_action_pressed("ui_accept"):
			restart()

func game_over():
	OS.set_time_scale(0)
	game_over = true
	viewport.get_node("level/squirrel/HUD/credits/value").set_text("0")

func the_end():
	running = false
	viewport.get_node("level/cinematic/AnimationPlayer").play("cinematic_end")

func restart():
	running = false
	viewport.remove_child(current_level)
	start()
	OS.set_time_scale(1)

func start():
	current_level = level.instance()
	viewport.add_child(current_level)
	_rearrenge_z_index()
	game_over = false

func _rearrenge_z_index():
	var trees = viewport.get_node("level/trees")
	
	for i in range(trees.get_child_count()):
		trees.get_child(i).set_z(i*2)