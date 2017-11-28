extends Node

var level = load("res://scenes/level.tscn")
var home_res = load("res://scenes/home.tscn")
var current_level
var home = true
var can_start = false
var running = false
var game_over = false

onready var viewport = get_tree().get_root().get_node("CRT/Viewport")

var input = load("res://scripts/input.gd")
var accept

func run():
	running = true

func _ready():
	set_process_input(true)
	set_pause_mode(PAUSE_MODE_PROCESS)
	accept = input.new("ui_accept")

func _input(event):
	if can_start:
		if home and Input.is_action_pressed("ui_accept"):
			start()
			viewport.get_node("home").queue_free()
			home = false
		elif accept.key_down():
			if game_over:
				restart()
			else:
				pause()

func game_over():
	get_tree().set_pause(true)
	game_over = true
	viewport.get_node("level/squirrel/HUD/credits/value").set_text("0")

func the_end():
	running = false
	viewport.get_node("level/cinematic/AnimationPlayer").play("cinematic_end")

func restart():
	running = false
	viewport.remove_child(current_level)
	start()
	get_tree().set_pause(false)

func start():
	current_level = level.instance()
	viewport.add_child(current_level)
	_rearrenge_z_index()
	game_over = false

func pause():
	if not viewport.get_node("level/cinematic/AnimationPlayer").is_playing():
		if get_tree().is_paused():
			get_tree().set_pause(false)
			viewport.get_parent().get_node("paused").hide()
		else:
			get_tree().set_pause(true)
			viewport.get_parent().get_node("paused").show()

func go_home():
	get_tree().set_pause(false)
	var h = home_res.instance()
	viewport.remove_child(current_level)
	viewport.add_child(h)
	home = true

func _rearrenge_z_index():
	var trees = viewport.get_node("level/trees")
	
	for i in range(trees.get_child_count()):
		trees.get_child(i).set_z(i*2)