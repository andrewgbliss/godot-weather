extends GridContainer

var weapon_belt: WeaponBelt

func _ready() -> void:
	EventBus.player_spawned.connect(_on_player_spawned)

func _on_player_spawned(player: CharacterController):
	weapon_belt = player.character.weapon_belt
	weapon_belt.belt_slot_changed.connect(_on_belt_slot_changed)
	_update_ui()

func _on_belt_slot_changed(_slot: int, _weapon: Weapon):
	_update_ui()

func _update_ui():
	var children = get_children()
	for i in range(children.size()):
		var child = children[i]
		if child is ItemSlot:
			child.set_index(i)
			var item = weapon_belt.get_slot(child.get_index())
			if item:
				child.set_item(item)
