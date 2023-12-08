extends Node2D

@onready var player = get_tree().get_nodes_in_group("player")[0]

var can_aim = true

func _process(delta):
	if(can_aim):
		adjust_position()
	
func shoot_laser():
	adjust_position()
	can_aim = true
	$AimLaserTimer.start()
	self.visible = true
	$LaserArea/LaserAnimatedSprite2D.play("laser_ready")

func adjust_position():
	var enemey_sprite = get_node("../AnimatedSprite2D")
	if(enemey_sprite.scale.x < 0):
		self.position.x = -2
	else:
		self.position.x = 2
	if(len(get_tree().get_nodes_in_group("player")) > 0):
		var player_relative_position = player.get_global_position() - $LaserArea.get_global_position()
		var player_direction = player_relative_position.normalized()
		$LaserArea.rotation = player_direction.angle()

func _on_laser_animated_sprite_2d_animation_finished():
	var animation_name = $LaserArea/LaserAnimatedSprite2D.animation
	if(animation_name == "laser_ready"):
		$LaserArea/LaserAnimatedSprite2D.play("shoot_laser")
		$LaserArea/CollisionShape2D.disabled = false
	elif(animation_name == "shoot_laser"):
		self.visible = false
		$LaserArea/CollisionShape2D.disabled = true
		


func _on_aim_laser_timer_timeout():
	can_aim = false
