class_name BuildingDefinition
extends Resource

# Building definition resource for configurable buildings
# Uses intentional naming conventions for future maintainability

@export var building_id: String
@export var display_name: String
@export var description: String
@export var icon_path: String = ""

# Cost configuration
@export var base_cost: int = 100
@export var unlock_condition_type: UnlockConditionType = UnlockConditionType.CURRENCY_EARNED
@export var unlock_condition_value: int = 0

# Building effects
@export var effects: Array = []  # Text descriptions of what the building unlocks

enum UnlockConditionType { CURRENCY_EARNED, BUILDINGS_OWNED, UPGRADES_PURCHASED }  # Unlocks after earning X total currency  # Unlocks after owning X buildings  # Unlocks after purchasing X upgrades
