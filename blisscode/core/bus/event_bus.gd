extends Node

signal player_spawned(player: CharacterController)
signal audio_volume_changed(bus_idx: int, volume: float)
signal zoom_level_changed(zoom_level: float)
signal world_changed(to_room_id: String, from_room_id: String, scene_path: String, scene_transition_name: String)

signal inventory_item_dropped(i: Item, item_slot_type_from: ItemSlot.ItemSlotType, item_slot_type_to: ItemSlot.ItemSlotType, from_index: int, to_index: int)
signal equipment_item_dropped(i: Item, item_slot_type_from: ItemSlot.ItemSlotType, item_slot_type_to: ItemSlot.ItemSlotType, from_equipment_slot: Equipment.EquipmentSlotType, to_equipment_slot: Equipment.EquipmentSlotType)
signal weapon_belt_item_dropped(i: Item, item_slot_type_from: ItemSlot.ItemSlotType, item_slot_type_to: ItemSlot.ItemSlotType, from_equipment_slot: Equipment.EquipmentSlotType, to_equipment_slot: Equipment.EquipmentSlotType)
