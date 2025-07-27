# Hot Dog Store Implementation Plan

## Overview
This document outlines the specific changes needed to transform the current currency-based idle game into a hot dog store theme with production and customer sales mechanics.

## Core System Changes

### 1. CurrencyManager → HotDogManager Transformation

**Current System**:
- `CurrencyManager` manages currency balance and click values
- Currency is earned directly from clicks
- Simple currency gain/spend mechanics

**New System**:
- `HotDogManager` manages hot dog inventory and production values
- Hot dogs are produced from clicks, currency earned from sales
- Two-tier system: Production → Sales → Currency

**Implementation Changes**:
```gdscript
# HotDogManager.gd (replaces CurrencyManager.gd)
extends Node

signal hot_dogs_changed(new_inventory: int, change_amount: int)
signal hot_dogs_produced(amount: int, source: String)
signal hot_dogs_sold(amount: int, value: int)

# Core hot dog values
var hot_dogs_inventory: int = 0
var hot_dogs_per_click: int = 1
var production_rate_seconds: float = 0.3
var idle_rate_seconds: float = 0.3

# Currency from sales
var currency_balance: int = 0
var sale_value: int = 1  # Currency per hot dog sold

func produce_hot_dogs(amount: int, source: String = "unknown") -> void:
    """Produce hot dogs and add to inventory"""
    if amount > 0:
        hot_dogs_inventory += amount
        emit_signal("hot_dogs_produced", amount, source)

func sell_hot_dogs(amount: int) -> bool:
    """Sell hot dogs from inventory and earn currency"""
    if amount <= 0 or hot_dogs_inventory < amount:
        return false
    
    hot_dogs_inventory -= amount
    var earned_currency = amount * sale_value
    currency_balance += earned_currency
    
    emit_signal("hot_dogs_sold", amount, earned_currency)
    return true
```

### 2. CustomerManager Implementation

**New System Component**:
- Manages customer purchase timing and behavior
- Automatically purchases hot dogs at regular intervals
- Upgradeable purchase rate and sale value

**Implementation**:
```gdscript
# CustomerManager.gd (new autoload)
extends Node

signal customer_purchase(amount: int, value: int)
signal customer_arrived()

var hot_dog_manager: Node
var purchase_timer: Timer
var purchase_rate_seconds: float = 2.0  # Time between purchases
var purchase_amount: int = 1  # Hot dogs per purchase

func _ready():
    hot_dog_manager = get_node("/root/HotDogManager")
    _setup_purchase_timer()

func _setup_purchase_timer():
    purchase_timer = Timer.new()
    purchase_timer.wait_time = purchase_rate_seconds
    purchase_timer.timeout.connect(_on_purchase_timer_timeout)
    add_child(purchase_timer)
    purchase_timer.start()

func _on_purchase_timer_timeout():
    """Handle customer purchase attempt"""
    if hot_dog_manager and hot_dog_manager.hot_dogs_inventory >= purchase_amount:
        if hot_dog_manager.sell_hot_dogs(purchase_amount):
            emit_signal("customer_purchase", purchase_amount, purchase_amount * hot_dog_manager.sale_value)
            emit_signal("customer_arrived")
```

### 3. Upgrade System Updates

**Current Upgrades** (to be updated):
1. Faster Fingers - Reduces click rate
2. Lightning Clicks - Reduces click rate  
3. Patience Training - Reduces idle rate
4. Steady Hands - Reduces idle rate
5. Better Technique - Increases currency per click

**New Upgrades**:
1. **Faster Production** - Reduces production rate (faster hot dog making)
2. **Efficient Cooking** - Reduces idle rate (faster continuous production)
3. **Better Recipe** - Increases hot dogs per click
4. **Customer Service** - Increases customer purchase rate
5. **Premium Pricing** - Increases sale value per hot dog

**Implementation Changes**:
```gdscript
# Updated UpgradeEnums.gd
enum EffectType {
    HOT_DOGS_PER_CLICK,    # Increases hot dogs per click
    PRODUCTION_RATE,        # Decreases production rate (faster)
    IDLE_RATE,             # Decreases idle rate (faster holds)
    CUSTOMER_PURCHASE_RATE, # Increases customer purchase frequency
    SALE_VALUE             # Increases currency per hot dog sold
}

# Updated upgrade definitions in UpgradeManager.gd
func _create_default_upgrades():
    # Production Rate Upgrades (2)
    var faster_production = UpgradeDefinition.new()
    faster_production.upgrade_id = "faster_production"
    faster_production.display_name = "Faster Production"
    faster_production.description = "Reduces production time by 0.02s"
    faster_production.effect_type = UpgradeEnums.EffectType.PRODUCTION_RATE
    faster_production.effect_value = -0.02
    
    var efficient_cooking = UpgradeDefinition.new()
    efficient_cooking.upgrade_id = "efficient_cooking"
    efficient_cooking.display_name = "Efficient Cooking"
    efficient_cooking.description = "Reduces continuous production time by 0.05s"
    efficient_cooking.effect_type = UpgradeEnums.EffectType.IDLE_RATE
    efficient_cooking.effect_value = -0.05
    
    # Hot Dogs Per Click Upgrade (1)
    var better_recipe = UpgradeDefinition.new()
    better_recipe.upgrade_id = "better_recipe"
    better_recipe.display_name = "Better Recipe"
    better_recipe.description = "+1 hot dog per click"
    better_recipe.effect_type = UpgradeEnums.EffectType.HOT_DOGS_PER_CLICK
    better_recipe.effect_value = 1
    
    # Customer System Upgrades (2)
    var customer_service = UpgradeDefinition.new()
    customer_service.upgrade_id = "customer_service"
    customer_service.display_name = "Customer Service"
    customer_service.description = "Customers arrive 0.2s faster"
    customer_service.effect_type = UpgradeEnums.EffectType.CUSTOMER_PURCHASE_RATE
    customer_service.effect_value = -0.2
    
    var premium_pricing = UpgradeDefinition.new()
    premium_pricing.upgrade_id = "premium_pricing"
    premium_pricing.display_name = "Premium Pricing"
    premium_pricing.description = "+1 currency per hot dog sold"
    premium_pricing.effect_type = UpgradeEnums.EffectType.SALE_VALUE
    premium_pricing.effect_value = 1
```

### 4. UI Updates

**Button Text Changes**:
- "Gain Currency" → "Make Hot Dog"
- "Clicked!" → "Made!"
- "Holding..." → "Cooking..."

**Display Updates**:
- Currency display shows currency from sales
- New hot dog inventory display
- Customer purchase notifications

**Implementation**:
```gdscript
# Updated CurrencyGainButton.gd
func _update_visual_state():
    match current_state:
        ButtonState.IDLE:
            text = "Make Hot Dog"
        ButtonState.CLICKED:
            text = "Made!"
        ButtonState.HELD:
            text = "Cooking..."

# New HotDogDisplay.gd
extends Label

func _ready():
    var hot_dog_manager = get_node("/root/HotDogManager")
    if hot_dog_manager:
        hot_dog_manager.hot_dogs_changed.connect(_on_hot_dogs_changed)

func _on_hot_dogs_changed(new_inventory: int, change_amount: int):
    text = "Hot Dogs: %d" % new_inventory
```

### 5. Save System Updates

**Current Save Data**:
```gdscript
{
    "currency": 0,
    "click_value": 1,
    "auto_clicker_speed": 1.0,
    "total_earned": 0,
    "total_clicks": 0,
    "play_time": 0,
    "upgrades_purchased": [],
    "last_save_time": ""
}
```

**New Save Data**:
```gdscript
{
    "currency": 0,
    "hot_dogs_inventory": 0,
    "hot_dogs_per_click": 1,
    "production_rate": 0.3,
    "customer_purchase_rate": 2.0,
    "sale_value": 1,
    "total_hot_dogs_produced": 0,
    "total_hot_dogs_sold": 0,
    "total_currency_earned": 0,
    "total_clicks": 0,
    "play_time": 0,
    "upgrades_purchased": [],
    "last_save_time": ""
}
```

## Implementation Steps

### Step 1: Create HotDogManager
1. Create `scripts/autoload/HotDogManager.gd`
2. Implement hot dog inventory management
3. Add production and sales mechanics
4. Update save/load integration

### Step 2: Create CustomerManager
1. Create `scripts/autoload/CustomerManager.gd`
2. Implement customer purchase timing
3. Add purchase rate upgrades
4. Integrate with HotDogManager

### Step 3: Update Upgrade System
1. Update `UpgradeEnums.gd` with new effect types
2. Modify `UpgradeManager.gd` with new upgrades
3. Update upgrade effect application
4. Test upgrade functionality

### Step 4: Update UI Components
1. Update button text and states
2. Create hot dog inventory display
3. Update currency display for sales
4. Add customer purchase notifications

### Step 5: Update Save System
1. Modify `SaveSystem.gd` for new data structure
2. Update `GameData.gd` default values
3. Test save/load functionality
4. Implement data migration for existing saves

### Step 6: Update Game Scene
1. Update `Game.gd` for new managers
2. Modify UI layout for hot dog display
3. Update tooltips and labels
4. Test responsive design

## Migration Strategy

### For Existing Saves
```gdscript
# In SaveSystem.gd
func migrate_old_save_data(old_data: Dictionary) -> Dictionary:
    var new_data = get_default_save_data()
    
    # Migrate currency
    if old_data.has("currency"):
        new_data["currency"] = old_data["currency"]
        new_data["total_currency_earned"] = old_data.get("total_earned", 0)
    
    # Migrate click mechanics
    if old_data.has("click_value"):
        new_data["hot_dogs_per_click"] = old_data["click_value"]
    
    # Migrate timing
    if old_data.has("auto_clicker_speed"):
        new_data["production_rate"] = 0.3 / old_data["auto_clicker_speed"]
    
    # Migrate upgrades (map old to new)
    if old_data.has("upgrades_purchased"):
        new_data["upgrades_purchased"] = _migrate_upgrades(old_data["upgrades_purchased"])
    
    return new_data
```

## Testing Checklist

### Core Functionality
- [ ] Hot dog production from clicks
- [ ] Hot dog production from holds
- [ ] Customer purchases at regular intervals
- [ ] Currency earned from sales
- [ ] Inventory management

### Upgrade System
- [ ] Production rate upgrades
- [ ] Hot dogs per click upgrades
- [ ] Customer purchase rate upgrades
- [ ] Sale value upgrades
- [ ] Upgrade cost scaling

### UI/UX
- [ ] Button text updates
- [ ] Hot dog inventory display
- [ ] Currency display (sales only)
- [ ] Customer purchase notifications
- [ ] Responsive design

### Save System
- [ ] New save data structure
- [ ] Migration from old saves
- [ ] Auto-save functionality
- [ ] Manual save/load

### Performance
- [ ] Memory usage
- [ ] Frame rate stability
- [ ] Customer timer performance
- [ ] Large inventory handling

## Success Criteria

- [ ] Hot dog production works correctly
- [ ] Customer purchases happen at expected intervals
- [ ] Currency is only earned from sales
- [ ] All upgrades function properly
- [ ] UI clearly shows hot dog inventory and currency
- [ ] Save system preserves all data
- [ ] Performance remains stable
- [ ] Responsive design works on all screen sizes

## Timeline

**Estimated Duration**: 1-2 weeks
**Dependencies**: Phase 2 completion (✅ DONE)
**Risk Assessment**: Medium - Significant system changes required
**Priority**: High - Core gameplay transformation

This implementation plan provides a comprehensive roadmap for transforming the current currency-based system into an engaging hot dog store idle game with production and customer sales mechanics. 