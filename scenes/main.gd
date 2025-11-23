extends Node2D

func _ready() -> void:
	GameManager.game_config.state_changed.connect(_on_game_state_changed)
	GameManager.game_config.set_state(GameConfig.GAME_STATE.INIT_LOAD)

func _unhandled_input(_event: InputEvent) -> void:
	if GameManager.game_config.game_state == GameConfig.GAME_STATE.SPLASH_SCREENS:
		if Input.is_anything_pressed() and SceneManager.current_transition.is_blinking:
			var next = await SceneManager.transition_next()
			if not next:
				GameManager.game_config.set_state(GameConfig.GAME_STATE.GAME_MENU)

func _on_game_state_changed(state: GameConfig.GAME_STATE):
	match state:
		GameConfig.GAME_STATE.INIT_LOAD:
			GameManager.game_config.set_state(GameConfig.GAME_STATE.SPLASH_SCREENS)
		GameConfig.GAME_STATE.SPLASH_SCREENS:
			SceneManager.transition_play("InitSplashScreen")
		GameConfig.GAME_STATE.GAME_MENU:
			GameUi.game_menus.menu_stack.push("MainMenu")
		GameConfig.GAME_STATE.GAME_PLAY:
			print("Game play")
			pass
