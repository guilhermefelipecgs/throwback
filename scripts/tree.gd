extends Node2D

export var wait_time = 1.5

onready var timer = get_node("Timer")

var started = false

func _ready():
	timer.set_wait_time(wait_time)
	timer.connect("timeout", self, "_on_Timer_timeout")

func _on_Timer_timeout():
	get_node("collisors/trunk").queue_free()
	#get_node("floor").queue_free()
	get_node("AnimationPlayer").play("fall")

func _on_Area2D_body_enter( body ):
	if body.get_name() == "squirrel":
		if not started:
			get_node("AnimationPlayer").play("before_falling")
			timer.start()
			started = true