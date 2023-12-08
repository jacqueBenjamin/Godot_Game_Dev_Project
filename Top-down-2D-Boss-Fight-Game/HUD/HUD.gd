extends CanvasLayer

func _process(_delta):
	var width = DisplayServer.window_get_size()[0]/2
	$EnemyHealth.position.x = width - 50
	$Sprite2D.get("texture").width = width
	$Sprite2D.position.x = width/2

func update_player_health(health):
	$PlayerHealth.text = str(health)

func update_player_mana(mana):
	$PlayerMana.text = str(mana)

func update_enemy_health(health):
	$EnemyHealth.text = str(health)
