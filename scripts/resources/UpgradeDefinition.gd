class_name UpgradeDefinition
extends Resource

# Upgrade definition resource for configurable upgrades
# Uses intentional naming conventions for future maintainability

const UpgradeEnums = preload("res://scripts/resources/UpgradeEnums.gd")

@export var upgrade_id: String
@export var display_name: String
@export var description: String
@export var icon_path: String = ""

# Cost configuration
@export var base_cost: int = 10
@export var cost_scaling_type: int = 0  # CostScalingType.LINEAR
@export var cost_increase: int = 5  # For linear scaling
@export var cost_multiplier: float = 2.0  # For exponential scaling
@export var cost_curve_factor: float = 0.5  # For curved scaling

# Effect configuration
@export var effect_type: int = 0  # EffectType.CURRENCY_PER_CLICK
@export var effect_value: float = 1.0

# Level configuration
@export var max_level: int = -1  # -1 means unlimited
