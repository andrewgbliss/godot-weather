class_name GameMenus extends Node2D

@export var menu_stack: MenuStack
@export var audio_click: AudioStreamPlayer
@export var show_menu_on_start: String = ""
@export var zoom_slider: HSlider

func _ready() -> void:
	call_deferred("_after_ready")

func _after_ready():
	if show_menu_on_start != "":
		menu_stack.push(show_menu_on_start)

	if zoom_slider:
		zoom_slider.value = GameManager.user_config.zoom_level
		zoom_slider.value_changed.connect(_on_zoom_slider_value_changed)

func _on_zoom_slider_value_changed(value: float):
	GameManager.set_zoom_level(value)

func _input(event: InputEvent) -> void:
	if GameManager.game_config.game_state == GameConfig.GAME_STATE.GAME_PLAY:
		if event.is_action_pressed("pause"):
			if not get_tree().paused:
				if GameUi.game_menus.menu_stack.size() > 0:
					# They hit pause and a menu is already showing
					return
				else:
					# They hit pause and nothing is showing, so show the pause menu
					GameManager.pause()
					GameUi.game_menus.menu_stack.push("PauseMenu")
			else:
				# They hit the pause button, but its already paused
				# And there is a menu showing
				if GameUi.game_menus.menu_stack.size() > 0:
					GameUi.game_menus.menu_stack.pop()
					
				if GameUi.game_menus.menu_stack.size() == 0:
					GameManager.unpause()
