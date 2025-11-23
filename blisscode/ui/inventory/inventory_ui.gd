extends GridContainer

var inventory: Inventory

func _ready() -> void:
	EventBus.player_spawned.connect(_on_player_spawned)

func _on_player_spawned(player: CharacterController):
	inventory = player.character.inventory
	_update_ui()

func _update_ui():
	var children = get_children()
	for i in range(children.size()):
		var child = children[i]
		if child is ItemSlot:
			child.set_index(i)
			var item = inventory.get_slot(child.get_index())
			if item:
				child.set_item(item)
