# Upgrade system enums
# Uses intentional naming conventions for future maintainability

enum CostScalingType {
	LINEAR,      # cost = base_cost + (level * cost_increase)
	EXPONENTIAL, # cost = base_cost * (cost_multiplier ^ level)
	CURVED,      # cost = base_cost * (1 + level * cost_curve_factor)
	CUSTOM       # User-defined scaling function
}

enum EffectType {
	CURRENCY_PER_CLICK,  # Increases currency per click
	CLICK_RATE,          # Decreases click rate (faster clicks)
	IDLE_RATE,           # Decreases idle rate (faster holds)
	CURRENCY_MULTIPLIER  # Multiplies all currency gains
} 