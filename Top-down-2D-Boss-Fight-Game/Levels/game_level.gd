extends Node2D

var started = false

func _on_player_player_health_change(health):
	$Camera2D/HUD.update_player_health(health)

func _on_player_player_mana_change(mana):
	$Camera2D/HUD.update_player_mana(mana)

func _on_enemy_enemy_health_change(health):
	$Camera2D/HUD.update_enemy_health(health)

func _process(_delta):
	if(Input.is_action_just_pressed("start")):
		if(not started):
			_on_start_button_pressed()
	if(Input.is_action_just_pressed("quit")):
		get_tree().quit()

func _on_start_button_pressed():
	if(not started):
		$StartTimer.start()
		$Camera2D/PauseOverlay.visible = false
		$Camera2D/PauseOverlay/StartButton.visible = false
		$StartAudioStreamPlayer.stop()
		$GameAudioStreamPlayer.play()
		started = true

func _on_start_timer_timeout():
	$Player.process_mode = Node.PROCESS_MODE_INHERIT
	$Enemy.process_mode = Node.PROCESS_MODE_INHERIT

func disable_game():
	$Player.process_mode = Node.PROCESS_MODE_DISABLED
	$Enemy.process_mode = Node.PROCESS_MODE_DISABLED
	$Camera2D/PauseOverlay.visible = true
	$StartAudioStreamPlayer.play()
	$GameAudioStreamPlayer.stop()
	$Camera2D/PauseOverlay/CloseButton.visible = true

func _on_enemy_enemy_dead():
	disable_game()
	$Camera2D/PauseOverlay/Victory.visible = true


func _on_player_player_dead():
	disable_game()
	$Camera2D/PauseOverlay/GameOver.visible = true

func _on_close_button_pressed():
	get_tree().quit()
