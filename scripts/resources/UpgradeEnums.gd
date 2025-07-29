# Upgrade system enums
# Uses intentional naming conventions for future maintainability

enum CostScalingType { LINEAR, EXPONENTIAL, CURVED, CUSTOM }  # cost = base_cost + (level * cost_increase)  # cost = base_cost * (cost_multiplier ^ level)  # cost = base_cost * (1 + level * cost_curve_factor)  # User-defined scaling function

enum EffectType {HOT_DOGS_PER_CLICK, PRODUCTION_RATE, IDLE_RATE, CUSTOMER_PURCHASE_RATE, SALE_VALUE}  # Increases hot dogs per click  # Decreases production rate (faster)  # Decreases idle rate (faster holds)  # Increases customer purchase frequency  # Increases currency per hot dog sold

enum UpgradeCategory { KITCHEN, WORKER }  # Kitchen upgrades (available from start)  # Worker upgrades (available after office purchase)
