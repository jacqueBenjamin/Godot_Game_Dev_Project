extends Area2D

func _ready():
	$AnimatedSprite2D.play("lightning_strike_windup")

func _on_animated_sprite_2d_animation_finished():
	var animation_name = $AnimatedSprite2D.animation
	if(animation_name == "lightning_strike_windup"):
		$AnimatedSprite2D.play("lightning_strike")
		$CollisionShape2D.disabled = false
	elif(animation_name == "lightning_strike"):
		$AnimatedSprite2D.play("lightning_strike_cooldown")
		$CollisionShape2D.disabled = true
	else:
		queue_free()
