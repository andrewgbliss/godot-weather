class_name PlayerBar extends Control

@export var character: CharacterController
@export var health_rect: TextureRect
@export var armor_rect: TextureRect
@export var mana_rect: TextureRect
@export var stamina_rect: TextureRect

func _ready() -> void:
	if character == null:
		character = get_parent() as CharacterController

	if character.character:
		if character.character.character_sheet:
			character.character.character_sheet.health_changed.connect(_on_health_changed)
			character.character.character_sheet.armor_changed.connect(_on_armor_changed)
			character.character.character_sheet.mana_changed.connect(_on_mana_changed)
			character.character.character_sheet.stamina_changed.connect(_on_stamina_changed)

			update_health_bar(character.character.character_sheet.health, character.character.character_sheet.max_health)
			update_armor_bar(character.character.character_sheet.armor, character.character.character_sheet.max_armor)
			update_mana_bar(character.character.character_sheet.mana, character.character.character_sheet.max_mana)
			update_stamina_bar(character.character.character_sheet.stamina, character.character.character_sheet.max_stamina)

func _on_health_changed(hp: int, hp_max: int):
	update_health_bar(hp, hp_max)

func _on_armor_changed(armor: int, armor_max: int):
	update_armor_bar(armor, armor_max)

func _on_mana_changed(mana: int, mana_max: int):
	update_mana_bar(mana, mana_max)

func _on_stamina_changed(stamina: int, stamina_max: int):
	update_stamina_bar(stamina, stamina_max)

func update_health_bar(health: int, health_max: int):
	var health_percentage = float(health) / float(health_max)
	if health_percentage >= 1:
		health_percentage = 1
	health_rect.material.set_shader_parameter("fill_amount", health_percentage)

func update_armor_bar(armor: int, armor_max: int):
	var armor_percentage = float(armor) / float(armor_max)
	if armor_percentage >= 1:
		armor_percentage = 1
	armor_rect.material.set_shader_parameter("fill_amount", armor_percentage)

func update_mana_bar(mana: int, mana_max: int):
	var mana_percentage = float(mana) / float(mana_max)
	if mana_percentage >= 1:
		mana_percentage = 1
	mana_rect.material.set_shader_parameter("fill_amount", mana_percentage)

func update_stamina_bar(stamina: int, stamina_max: int):
	var stamina_percentage = float(stamina) / float(stamina_max)
	if stamina_percentage >= 1:
		stamina_percentage = 1
	stamina_rect.material.set_shader_parameter("fill_amount", stamina_percentage)
