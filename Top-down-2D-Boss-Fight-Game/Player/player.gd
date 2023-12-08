extends CharacterBody2D

@export var starting_direction : Vector2 = Vector2(1, 0)
@export var fireball_scene : PackedScene

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")

var acceleration : float = 2000
var max_velocity : float = 100
var last_direction: Vector2 = starting_direction
enum {RUNNING, ROLL, SWORD_ATTACK, FIREBALL_ATTACK, DAMAGED, DEAD}
var state = RUNNING

var health: int = 10
var damage_direction: Vector2
var knockback_strength: float = 40

var roll_speed: float = 200

var fireball_knockback_strength: float = -5
var fireball_on_cooldown: bool = false
var mana: int = 3

var death_fadeout_var: float = 1

signal player_health_change
signal player_mana_change
signal player_dead

func _ready():
	state_machine.travel("idle")
	update_animation_parameters(starting_direction)

func _physics_process(delta):
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up"),
	)
	if(input_vector.length() > 1):
		input_vector = input_vector.normalized()
	
	if(input_vector.length() < 0.1):
		input_vector = Vector2.ZERO
	
	if(state == RUNNING):
		if(input_vector != Vector2.ZERO):
			last_direction = input_vector.normalized()
		
		update_animation_parameters(last_direction)
		
		if(Input.is_action_just_pressed("attack")):
			$Sword.swing_sword(last_direction)
			state = SWORD_ATTACK
			
		elif(Input.is_action_just_pressed("roll")):
			$Hitbox/CollisionShape2D.disabled = true
			state_machine.travel("roll")
			$AnimationPlayer.speed_scale = 2
			state = ROLL
		
		elif(Input.is_action_just_pressed("fireball") and 
				not fireball_on_cooldown and mana > 0):
			state = FIREBALL_ATTACK
			state_machine.travel("idle")
			make_fireball(last_direction)
			$Fireball_Knockback_Timer.start()
			$Fireball_Cooldown_Timer.start()
			fireball_on_cooldown = true
			mana -= 1
			player_mana_change.emit(mana)
		
	if(state == DAMAGED):
		velocity = damage_direction * knockback_strength
	elif(state == FIREBALL_ATTACK):
		velocity = last_direction * fireball_knockback_strength
	elif(state == ROLL):
		velocity = last_direction * roll_speed
	elif(state == SWORD_ATTACK):
		pick_state()
		velocity = max_velocity * input_vector
	elif(state == RUNNING):
		pick_state()
		velocity = max_velocity * input_vector
	
	move_and_slide()
	

func update_animation_parameters(move_input : Vector2):
	animation_tree.set("parameters/idle/blend_position", move_input)
	animation_tree.set("parameters/run/blend_position", move_input)
	animation_tree.set("parameters/roll/blend_position", move_input)
	animation_tree.set("parameters/death/blend_position", move_input)

func pick_state():
	if(velocity != Vector2.ZERO):
		state_machine.travel("run")
	else:
		state_machine.travel("idle")


func _on_animated_sprite_2d_animation_finished_sword():
	if(state != DEAD):
		state = RUNNING


func _on_hitbox_area_entered(area):
	if((not $Hitbox/CollisionShape2D.disabled) and state != DEAD):
		$Hitbox/CollisionShape2D.disabled = true
		damage_direction = (self.get_global_position() - area.get_global_position()).normalized()
		state = DAMAGED
		state_machine.travel("idle")
		$Hitbox/knockback_timer.start()
		$Hitbox/Invincibility_Timer.start()
		$Hitbox/Blinking_Timer.start()
		health -= 1
		player_health_change.emit(health)
		$Sprite2D.set_self_modulate(Color(1, 1, 1, 0.5))
		if(health <= 0):
			handle_death()

func handle_death():
	state = DEAD
	state_machine.travel("death")
	velocity = Vector2.ZERO
	$Hitbox/Invincibility_Timer.stop()
	$Hitbox/Blinking_Timer.stop()
	$Hitbox/CollisionShape2D.disabled = true
	$Sword.visible = false
	$Sword/CollisionPolygon2D.disabled = true
	$DeathIntervalTimer.start()
	$DeathTimer.start()

func _on_knockback_timer_timeout():
	if(state != DEAD):
		state = RUNNING

func _on_blinking_timer_timeout():
	$Sprite2D.set_self_modulate(Color(1, 1, 1, 
		0.5 if $Sprite2D.self_modulate[3] == 1 else 1))

func _on_invincibility_timer_timeout():
	$Sprite2D.visible = true
	$Hitbox/CollisionShape2D.disabled = false
	$Sprite2D.set_self_modulate(Color.WHITE)
	$Hitbox/Blinking_Timer.stop()

func _on_animation_tree_animation_finished(anim_name):
	$AnimationPlayer.speed_scale = 1
	if(anim_name.substr(0, 4) == "roll" and (state != DEAD)):
		state = RUNNING
		pick_state()
		$Hitbox/CollisionShape2D.disabled = false

func make_fireball(last_direction):
	var fireball = fireball_scene.instantiate()
	fireball.position = self.get_global_position()
	fireball.rotation = last_direction.angle()
	fireball.velocity_vector = fireball.velocity_magnitude * last_direction
	get_parent().add_child(fireball)


func _on_fireball_knockback_timer_timeout():
	if(state != DEAD):
		state = RUNNING


func _on_fireball_cooldown_timer_timeout():
	fireball_on_cooldown = false


func _on_sword_area_entered(area):
	mana = min(mana+1, 3)
	player_mana_change.emit(mana)


func _on_death_interval_timer_timeout():
	var color_num = 1 + death_fadeout_var / 2
	$Sprite2D.set_self_modulate(Color(color_num, color_num, color_num, death_fadeout_var))
	death_fadeout_var -= 0.1


func _on_death_timer_timeout():
	player_dead.emit()
	queue_free()
