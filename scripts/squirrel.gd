extends KinematicBody2D

var GRAVITY=980
const SPEED=500
const JUMP_SPEED=350
const FRICTION=500
const MAX_SPEED_X=200
const MAX_SPEED_Y=1000

var lv = Vector2()
onready var aplayer = get_node("AnimationPlayer")
var jump = false
var jumping = false
var on_wall = false

var input = load("res://scripts/input.gd")
var up

func _ready():
	up = input.new("ui_up")
	set_process(true)
	set_fixed_process(true)

func _process(delta):
	get_node("crt").set_global_pos(get_node("Camera2D").get_camera_screen_center())

func _fixed_process(delta):
	var dir = Vector2()
	
	if not on_wall:
		if Input.is_action_pressed("ui_right"):
			dir.x = 1
		elif Input.is_action_pressed("ui_left"):
			dir.x = -1
		
		if up.key_down():
			jump = true
		
		# Appply direction with speed
		lv += dir * SPEED * delta
		
		# Apply friction
		if dir.x == 0 and abs(lv.x) > 0.2:
			lv.x -= sign(lv.x) * FRICTION * delta
		
		# Apply jump
		if jump and not jumping:
			jumping = true
			jump = false
			lv.y -= JUMP_SPEED
		
		# Apply gravity
		lv.y += GRAVITY * delta
		
		# Limit to max speed
		if abs(lv.x) > MAX_SPEED_X:
			lv.x = MAX_SPEED_X * sign(lv.x)
		if abs(lv.y) > MAX_SPEED_Y:
			lv.y = MAX_SPEED_Y * sign(lv.y)
	else: # on wall
		lv = Vector2()
		
		if Input.is_action_pressed("ui_down"):
			on_wall = false
		
		if up.key_down():
			jump = true
		
		if jump and not jumping:
			var si = 1;
			if get_node("Sprite").is_flipped_h():
				si = -1
			lv.y -= JUMP_SPEED
			lv.x -= JUMP_SPEED * si
			on_wall = false
			jumping = true
	
	# Move and slide
	lv = move_and_slide(lv, Vector2(0, -1));
	
	# Stop jumping
	if is_move_and_slide_on_floor():
		jumping = false
		jump=false

	_apply_animation(dir)

func _apply_animation(dir):
	if dir.x != 0 and abs(lv.x) > 1 and aplayer.get_current_animation() != "run":
		aplayer.play("run")
	elif dir.x == 0 and abs(lv.x) < 150 and aplayer.get_current_animation() != "idle":
		aplayer.play("idle")
	
	# Flip direction
	if dir.x < 0:
		get_node("Sprite").set_flip_h(true)
		get_node("TriggerWall").set_rotd(180)
	elif dir.x > 0:
		get_node("Sprite").set_flip_h(false)
		get_node("TriggerWall").set_rotd(0)

func _on_TriggerWall_body_enter( body ):
	if body.get_name() != "squirrel" and body.get_name() == "trunk":
		on_wall = true
		jumping = false
		jump=false
		