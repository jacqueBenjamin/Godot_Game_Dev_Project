extends Area2D

func swing_sword(direction):
	self.rotation = direction.angle() + PI
	self.position = 10 * direction
	$AnimatedSprite2D.visible = true
	$AnimatedSprite2D.play("sword_swing")
	$CollisionPolygon2D.disabled = false

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.visible = false
	$CollisionPolygon2D.disabled = true
