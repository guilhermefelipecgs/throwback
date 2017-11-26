extends Node2D

export var wait_time = 1.5
export var can_fall  = true
export var last_tree  = false

onready var timer = get_node("Timer")
onready var squirrel = get_parent().get_parent().get_node("squirrel")

var started = false

func _ready():
	if can_fall:
		timer.set_wait_time(wait_time)
		timer.connect("timeout", self, "_on_Timer_timeout")
	
	if last_tree:
		get_node("tree/trunk").set_texture(load("res://textures/tree_end.png"))
		get_node("tree/tree_top_layer").set_texture(load("res://textures/tree_end_top_layer.png"))

func _on_Timer_timeout():
	get_node("collisors/trunk").queue_free()
	get_node("collisors").queue_free()
	get_node("AnimationPlayer").play("fall")
	get_node("area_z").queue_free()

func _on_area_fall_body_enter( body ):
	if body.get_name() == "squirrel":
		if not started and can_fall:
			get_node("AnimationPlayer").play("before_falling")
			timer.start()
			started = true

func _on_area_z_body_enter( body ):
	if body.get_name() == "squirrel":
		squirrel.set_z(get_z() + 1)
