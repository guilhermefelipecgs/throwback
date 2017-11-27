extends KinematicBody2D

var GRAVITY=980
const SPEED=500
const JUMP_SPEED=350
const FRICTION=600
const MAX_SPEED_X=200
const MAX_SPEED_Y=1000

var lv = Vector2()
onready var aplayer = get_node("AnimationPlayer")
onready var splayer = get_node("SamplePlayer")
var jump = false
var jumping = false
var on_wall = false
var on_floor = false
var force_flip = false

var input = load("res://scripts/input.gd")
var up
var idle_sec = 0

var vfx_run = load("res://scenes/vfx_run.tscn")

func _ready():
	up = input.new("ui_up")
	set_process(true)
	set_fixed_process(true)

func _process(delta):
	get_node("HUD").set_global_pos(get_node("Camera2D").get_camera_screen_center() - Vector2(384, 288) / 2)

	if get_pos().y > 400:
		global.game_over()
	
	if global.game_over:
		var hud_game_over = get_node("HUD/game_over")
		var streamPlayer = hud_game_over.get_node("StreamPlayer")
		
		if not (hud_game_over.is_visible() and streamPlayer.is_playing()):
			streamPlayer.play()
		hud_game_over.show()
	
	# GO
	if global.running:
		if OS.get_ticks_msec() > idle_sec and not get_node("HUD/go/AnimationPlayer").is_playing():
			idle_sec += 2000
			get_node("HUD/go/AnimationPlayer").play("go")
		
		if lv != Vector2():
			idle_sec = OS.get_ticks_msec() + 2000


func _fixed_process(delta):
	if global.running:
		var dir = Vector2()
		
		if not on_wall:
			if Input.is_action_pressed("ui_right"):
				dir.x = 1
				_vfx_run(dir.x)
					
			elif Input.is_action_pressed("ui_left"):
				dir.x = -1
				_vfx_run(dir.x)
			
			if up.key_down() and on_floor:
				jump = true
				splayer.play("jump")
				_vfx_jump_fall()
			
			# Appply direction with speed
			lv += dir * SPEED * delta
			
			# Apply friction
			if dir.x == 0 and abs(lv.x) > 0.2 and on_floor:
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
				splayer.play("jump")
			
			if jump and not jumping:
				var si = 1;
				if get_node("Sprite").is_flipped_h():
					si = -1
				lv.y -= JUMP_SPEED
				lv.x -= JUMP_SPEED * si
				
				on_wall = false
				jumping = true
				force_flip = true
		
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
	
	if not on_floor:
		if lv.y < 0:
			aplayer.play("jump")
		elif lv.y > 200:
			aplayer.play("fall")
		else:
			aplayer.play("middle")
	
	if on_wall:
		aplayer.play("idle")
	
	# Flip direction
	if dir.x < 0 or force_flip and lv.x < 0:
		get_node("Sprite").set_flip_h(true)
		get_node("TriggerWall").set_rotd(180)
	elif dir.x > 0 or force_flip and lv.x > 0:
		get_node("Sprite").set_flip_h(false)
		get_node("TriggerWall").set_rotd(0)

func _vfx_run(dir):
	if lv.x == 0:
		var vfx_i = vfx_run.instance()
		vfx_i.set_global_pos(get_node("vfx_position").get_global_pos())
		vfx_i.set_z(get_z())
		
		if dir < 0:
			vfx_i.set_flip_h(true)
			vfx_i.set_pos(vfx_i.get_pos() + Vector2(12, -3))
		else:
			vfx_i.set_pos(vfx_i.get_pos() - Vector2(12, 3))
			
		get_tree().get_root().get_node("CRT/Viewport/level").add_child(vfx_i)

func _vfx_jump_fall():
	var vfx_l = vfx_run.instance()
	var vfx_r = vfx_run.instance()
	
	vfx_l.set_global_pos(get_node("vfx_position").get_global_pos())
	vfx_r.set_global_pos(get_node("vfx_position").get_global_pos())
	vfx_l.set_z(get_z())
	vfx_r.set_z(get_z())
	vfx_l.set_pos(vfx_l.get_pos() - Vector2(12, 3))
	vfx_r.set_pos(vfx_r.get_pos() + Vector2(12, -3))
	vfx_r.set_flip_h(true)
	
	get_tree().get_root().get_node("CRT/Viewport/level").add_child(vfx_l)
	get_tree().get_root().get_node("CRT/Viewport/level").add_child(vfx_r)

func _on_TriggerWall_body_enter( body ):
	if body.get_name() != "squirrel" and body.get_name() == "trunk":
		on_wall = true
		jumping = false
		jump=false

func _on_TriggerWall_body_exit( body ):
	if body.get_name() != "squirrel":
		on_wall = false

func _on_TriggerGround_body_enter( body ):
	if body.get_name() != "squirrel":
		on_floor = true
		splayer.play("fall")
		_vfx_jump_fall()

func _on_TriggerGround_body_exit( body ):
	if body.get_name() != "squirrel":
		on_floor = false


