class_name CharacterSheetMenu extends Menu

@onready var character_name_label: Label = $Control/Panel/MarginContainer/VBoxContainer/CharacterInfo/NameLabel
@onready var level_label: Label = $Control/Panel/MarginContainer/VBoxContainer/CharacterInfo/LevelLabel
@onready var race_class_label: Label = $Control/Panel/MarginContainer/VBoxContainer/CharacterInfo/RaceClassLabel
@onready var alignment_label: Label = $Control/Panel/MarginContainer/VBoxContainer/CharacterInfo/AlignmentLabel

@onready var health_label: Label = $Control/Panel/MarginContainer/VBoxContainer/StatsContainer/HealthLabel
@onready var armor_label: Label = $Control/Panel/MarginContainer/VBoxContainer/StatsContainer/ArmorLabel
@onready var mana_label: Label = $Control/Panel/MarginContainer/VBoxContainer/StatsContainer/ManaLabel
@onready var stamina_label: Label = $Control/Panel/MarginContainer/VBoxContainer/StatsContainer/StaminaLabel
@onready var xp_label: Label = $Control/Panel/MarginContainer/VBoxContainer/StatsContainer/XPLabel

@onready var strength_label: Label = $Control/Panel/MarginContainer/VBoxContainer/AttributesContainer/StrengthLabel
@onready var dexterity_label: Label = $Control/Panel/MarginContainer/VBoxContainer/AttributesContainer/DexterityLabel
@onready var constitution_label: Label = $Control/Panel/MarginContainer/VBoxContainer/AttributesContainer/ConstitutionLabel
@onready var intelligence_label: Label = $Control/Panel/MarginContainer/VBoxContainer/AttributesContainer/IntelligenceLabel
@onready var wisdom_label: Label = $Control/Panel/MarginContainer/VBoxContainer/AttributesContainer/WisdomLabel
@onready var charisma_label: Label = $Control/Panel/MarginContainer/VBoxContainer/AttributesContainer/CharismaLabel
@onready var attack_label: Label = $Control/Panel/MarginContainer/VBoxContainer/AttributesContainer/AttackLabel

var player_character: CharacterController

func _ready():
	super._ready()
	# Find the player character in the scene
	player_character = get_tree().get_first_node_in_group("player")
	if player_character and player_character.character_sheet:
		update_character_display()
		# Connect to character sheet signals for real-time updates
		player_character.character_sheet.health_changed.connect(_on_health_changed)
		player_character.character_sheet.armor_changed.connect(_on_armor_changed)
		player_character.character_sheet.mana_changed.connect(_on_mana_changed)
		player_character.character_sheet.stamina_changed.connect(_on_stamina_changed)
		player_character.character_sheet.alignment_changed.connect(_on_alignment_changed)

func update_character_display():
	if not player_character or not player_character.character_sheet:
		return
		
	var sheet = player_character.character_sheet
	
	# Basic character info
	if character_name_label:
		character_name_label.text = "Name: " + (sheet.character_name if sheet.character_name != "" else "Unnamed")
	if level_label:
		level_label.text = "Level: " + str(sheet.level)
	if race_class_label:
		race_class_label.text = "Race: " + CharacterSheet.CharacterRace.keys()[sheet.race] + " | Class: " + CharacterSheet.CharacterClassType.keys()[sheet.class_type]
	
	# Alignment display
	var alignment_text = "Alignment: "
	if sheet.is_good():
		alignment_text += "Good"
	elif sheet.is_evil():
		alignment_text += "Evil"
	else:
		alignment_text += "Neutral"
	alignment_text += " (" + str(sheet.alignment) + ")"
	if alignment_label:
		alignment_label.text = alignment_text
	
	# Stats
	if health_label:
		health_label.text = "Health: " + str(sheet.health) + "/" + str(sheet.max_health)
	if armor_label:
		armor_label.text = "Armor: " + str(sheet.armor) + "/" + str(sheet.max_armor)
	if mana_label:
		mana_label.text = "Mana: " + str(sheet.mana) + "/" + str(sheet.max_mana)
	if stamina_label:
		stamina_label.text = "Stamina: " + str(sheet.stamina) + "/" + str(sheet.max_stamina)
	if xp_label:
		xp_label.text = "XP: " + str(sheet.xp) + "/" + str(sheet.max_xp)
	
	# Attributes
	if strength_label:
		strength_label.text = "Strength: " + str(sheet.strength)
	if dexterity_label:
		dexterity_label.text = "Dexterity: " + str(sheet.dexterity)
	if constitution_label:
		constitution_label.text = "Constitution: " + str(sheet.constitution)
	if intelligence_label:
		intelligence_label.text = "Intelligence: " + str(sheet.intelligence)
	if wisdom_label:
		wisdom_label.text = "Wisdom: " + str(sheet.wisdom)
	if charisma_label:
		charisma_label.text = "Charisma: " + str(sheet.charisma)
	if attack_label:
		attack_label.text = "Attack: " + str(sheet.attack)

func _on_health_changed(health: int, max_health: int):
	health_label.text = "Health: " + str(health) + "/" + str(max_health)

func _on_armor_changed(armor: int, max_armor: int):
	armor_label.text = "Armor: " + str(armor) + "/" + str(max_armor)

func _on_mana_changed(mana: int, max_mana: int):
	mana_label.text = "Mana: " + str(mana) + "/" + str(max_mana)

func _on_stamina_changed(stamina: int, max_stamina: int):
	stamina_label.text = "Stamina: " + str(stamina) + "/" + str(max_stamina)

func _on_alignment_changed(alignment: float):
	var alignment_text = "Alignment: "
	if player_character.character_sheet.is_good():
		alignment_text += "Good"
	elif player_character.character_sheet.is_evil():
		alignment_text += "Evil"
	else:
		alignment_text += "Neutral"
	alignment_text += " (" + str(alignment) + ")"
	alignment_label.text = alignment_text
