extends Area2D

var velocity_magnitude : float = 250
var velocity_vector : Vector2

func _ready():
	$AnimatedSprite2D.play("moving_fireball")

func _process(delta):
	position += (velocity_vector * delta)

func _on_area_entered(area):
	hit_something()

func _on_body_entered(body):
	hit_something()

func hit_something():
	velocity_vector = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.scale /= 16
	$AnimatedSprite2D.position = Vector2(10, 0)
	$AnimatedSprite2D.play("fireball_collision")

func _on_animated_sprite_2d_animation_finished():
	queue_free()
