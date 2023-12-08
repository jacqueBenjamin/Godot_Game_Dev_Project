extends CharacterBody2D

@export var lightning_strike_scene : PackedScene

@onready var player = get_tree().get_nodes_in_group("player")[0]

enum {IDLE, LASER, LIGHTNING_STRIKE, DEATH}
var state = IDLE

var rng = RandomNumberGenerator.new()

var health = 30

signal enemy_health_change
signal enemy_dead

func _ready():
	rng.randomize()
	$ActionTimer.start()
	$AnimatedSprite2D.play("idle")

func _physics_process(_delta):
	if(len(get_tree().get_nodes_in_group("player")) > 0):
		var player_relative_position = player.get_global_position() - self.get_global_position()
		var player_direction = player_relative_position.normalized()
		if(state == IDLE):
			update_facing_direction(player_direction)
			if(player_relative_position.length() <= 20):
				velocity = Vector2.ZERO
			else:
				velocity = player_direction * 25
			move_and_slide()
		if($Laser.can_aim and state != DEATH):
			update_facing_direction(player_direction)


func update_facing_direction(player_direction):
	if(player_direction.x < 0 and $AnimatedSprite2D.scale.x == 1):
		$AnimatedSprite2D.set_scale(Vector2(-1, 1))
	elif(player_direction.x > 0 and $AnimatedSprite2D.scale.x == -1):
		$AnimatedSprite2D.set_scale(Vector2(1, 1))


func _on_hitbox_area_entered(area):
	if(not $Hitbox/CollisionShape2D.disabled):
		if(area.is_in_group("fireball")):
			health -= 2
			health = max(health, 0)
		else:
			health -= 1
		enemy_health_change.emit(health)
		$HitTimer.start()
		$AnimatedSprite2D.set_self_modulate(Color(1, 0.4, 0.4, 1))
		if(health <= 0):
			$AnimatedSprite2D.play("death")
			state = DEATH
			$LightningIntervalTimer.stop()
			$Hitbox/CollisionShape2D.set_deferred("disabled", true)
			$Laser.set_visible(false)
			$Laser/LaserArea/CollisionShape2D.set_deferred("disabled", true)

func _on_hit_timer_timeout():
	$AnimatedSprite2D.set_self_modulate(Color.WHITE)

func _on_laser_animated_sprite_2d_animation_finished():
	var animation_name = $Laser/LaserArea/LaserAnimatedSprite2D.animation
	if(animation_name == "shoot_laser" and state != DEATH):
		state = IDLE
		$ActionTimer.start()

func _on_action_timer_timeout():
	if(state == IDLE):
		var rand_num = rng.randf()
		if(rand_num > 0.5):
			state = LASER
			$Laser.shoot_laser()
			$AnimatedSprite2D.play("body_laser")
		else:
			state = LIGHTNING_STRIKE
			$AnimatedSprite2D.play("body_lightning_windup")


func _on_animated_sprite_2d_animation_finished():
	var animation_name = $AnimatedSprite2D.animation
	if(animation_name == "body_laser"):
		$AnimatedSprite2D.play("idle")
	elif(animation_name == "body_lightning_windup"):
		$LightningAttackTimer.start()
		$LightningIntervalTimer.start()
		_on_lightning_interval_timer_timeout()
	elif(animation_name == "body_lightning_cooldown"):
		if(state != DEATH):
			state = IDLE
			$AnimatedSprite2D.play("idle")
	elif(animation_name == "death"):
		enemy_dead.emit()


func make_lightning_strike():
	if(len(get_tree().get_nodes_in_group("player")) > 0):
		var lightning_strike = lightning_strike_scene.instantiate()
		lightning_strike.position = player.get_global_position()
		get_parent().add_child(lightning_strike)


func _on_lightning_interval_timer_timeout():
	make_lightning_strike()


func _on_lightning_attack_timer_timeout():
	$LightningIntervalTimer.stop()
	if(state != DEATH):
		$ActionTimer.start()
		$AnimatedSprite2D.play("body_lightning_cooldown")
