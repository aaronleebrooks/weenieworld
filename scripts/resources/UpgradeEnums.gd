# Upgrade system enums
# Uses intentional naming conventions for future maintainability

enum CostScalingType {
	LINEAR,      # cost = base_cost + (level * cost_increase)
	EXPONENTIAL, # cost = base_cost * (cost_multiplier ^ level)
	CURVED,      # cost = base_cost * (1 + level * cost_curve_factor)
	CUSTOM       # User-defined scaling function
}

enum EffectType {
	HOT_DOGS_PER_CLICK,    # Increases hot dogs per click
	PRODUCTION_RATE,        # Decreases production rate (faster)
	IDLE_RATE,             # Decreases idle rate (faster holds)
	CUSTOMER_PURCHASE_RATE, # Increases customer purchase frequency
	SALE_VALUE             # Increases currency per hot dog sold
} 