extends Node

var level = load("res://scenes/level.tscn")
var current_level
var start = true

onready var viewport = get_tree().get_root().get_node("CRT/Viewport")

func _ready():
	set_process_input(true)

func _input(event):
	if start and Input.is_action_pressed("ui_accept"):
		start()
		viewport.get_node("home").queue_free()
		start = false
	elif Input.is_action_pressed("ui_accept"):
		restart()

func game_over():
	OS.set_time_scale(0)

func restart():
	viewport.remove_child(current_level)
	start()
	OS.set_time_scale(1)

func start():
	current_level = level.instance()
	viewport.add_child(current_level)