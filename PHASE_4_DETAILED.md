# Phase 4: Recipe & Menu System - Detailed Implementation Plan

## Overview
Phase 4 implements the comprehensive recipe and menu system for "Alien Hot Dog Food Truck", including recipe creation, ingredient management, menu selection, and customer preference systems. This phase builds upon the research system to unlock recipe capabilities.

## Current Progress Summary ⏳ **PLANNED**

**Planned Systems (6/6)**:
1. ⏳ **Recipe Creation System** - Custom hot dog recipes with ingredients
2. ⏳ **Ingredient Management** - Bun, weenie, greenTopping, whiteTopping, redTopping
3. ⏳ **Menu Management** - Select which recipes to offer customers
4. ⏳ **Customer Preference System** - Different customer types prefer different recipes
5. ⏳ **Recipe Hot Dog Inventory** - Separate inventory for recipe-based hot dogs
6. ⏳ **Recipe Effects System** - Special effects and bonuses from recipes

## Phase 4A: Recipe Creation System 🍔

### 1.1 Recipe Definition System
- [ ] Create `RecipeDefinition.gd` resource class
- [ ] Implement recipe data structure
- [ ] Add ingredient slot system (up to 3 toppings)
- [ ] Create recipe validation system
- [ ] Add recipe naming and description system

**Implementation Details**:
- **Recipe Properties**:
  - Name and description
  - Ingredient slots (bun, weenie, topping1, topping2, topping3)
  - Base value and effects
  - Unlock requirements
  - Popularity tracking
- **Ingredient Slots**: 
  - Bun slot (required)
  - Weenie slot (required)
  - Topping slots (1-3, unlockable)
- **Validation**: Ensure required ingredients are present
- **Naming**: Custom recipe names with alien cypher support

### 1.2 Recipe Creation Interface
- [ ] Create `RecipeCreationMenu.tscn` scene
- [ ] Implement ingredient selection interface
- [ ] Add recipe preview system
- [ ] Create recipe save/load functionality
- [ ] Add recipe editing capabilities

**Implementation Details**:
- **Ingredient Selection**: Dropdown or grid-based ingredient picker
- **Recipe Preview**: Visual representation of the hot dog
- **Save System**: Save recipes to player's recipe collection
- **Edit System**: Modify existing recipes
- **Validation Feedback**: Show errors for invalid recipes

### 1.3 Recipe Management
- [ ] Create recipe collection system
- [ ] Implement recipe sorting (name, created, popularity)
- [ ] Add recipe deletion functionality
- [ ] Create recipe sharing system
- [ ] Add recipe import/export

**Implementation Details**:
- **Collection**: Player's saved recipes
- **Sorting Options**:
  - By name (alphabetical)
  - By creation date (newest first)
  - By popularity (most ordered)
- **Deletion**: Remove unwanted recipes
- **Sharing**: Export/import recipe configurations
- **Clipboard**: Copy/paste recipe data

## Phase 4B: Ingredient System 🥬

### 2.1 Ingredient Types
- [ ] Implement bun ingredient system
- [ ] Create weenie ingredient system
- [ ] Add topping ingredient types
- [ ] Create ingredient unlock system
- [ ] Add ingredient quality levels

**Implementation Details**:
- **Bun Types**: Basic bun, premium bun, specialty buns
- **Weenie Types**: Basic weenie, premium weenie, specialty weenies
- **Topping Types**:
  - Green toppings: lettuce, spinach, herbs
  - White toppings: onions, garlic, mushrooms
  - Red toppings: tomatoes, peppers, hot sauce
- **Unlock System**: Research-based ingredient unlocks
- **Quality Levels**: Basic, premium, gourmet

### 2.2 Ingredient Production
- [ ] Create ingredient farm system
- [ ] Implement ingredient production rates
- [ ] Add ingredient storage system
- [ ] Create ingredient consumption tracking
- [ ] Add ingredient upgrade system

**Implementation Details**:
- **Farm System**: Research-based ingredient farms
- **Production Rates**: Configurable production speeds
- **Storage**: Separate inventory for each ingredient type
- **Consumption**: Track ingredient usage in recipes
- **Upgrades**: Improve farm efficiency and capacity

### 2.3 Ingredient Effects
- [ ] Implement ingredient value modifiers
- [ ] Create ingredient special effects
- [ ] Add ingredient combination bonuses
- [ ] Create ingredient rarity system
- [ ] Add ingredient unlock requirements

**Implementation Details**:
- **Value Modifiers**: Each ingredient adds to recipe value
- **Special Effects**: Unique effects from specific ingredients
- **Combination Bonuses**: Bonuses for ingredient combinations
- **Rarity System**: Common, uncommon, rare, legendary ingredients
- **Unlock Requirements**: Research or achievement-based unlocks

## Phase 4C: Menu Management System 📋

### 3.1 Menu Interface
- [ ] Create `MenuManagementMenu.tscn` scene
- [ ] Implement recipe selection interface
- [ ] Add menu capacity system
- [ ] Create menu preview system
- [ ] Add menu optimization tools

**Implementation Details**:
- **Recipe Selection**: Choose which recipes to offer
- **Menu Capacity**: Starting with 1 recipe, expandable through upgrades
- **Menu Preview**: Show current menu to customers
- **Optimization**: Tools to maximize profit and customer satisfaction
- **Menu Layout**: Visual representation of available recipes

### 3.2 Menu Capacity System
- [ ] Implement menu slot system
- [ ] Create menu expansion upgrades
- [ ] Add menu slot management
- [ ] Create menu efficiency tracking
- [ ] Add menu optimization suggestions

**Implementation Details**:
- **Menu Slots**: Limited number of recipes can be offered
- **Expansion Upgrades**: Research-based menu slot increases
- **Slot Management**: Add/remove recipes from menu
- **Efficiency Tracking**: Monitor menu performance
- **Optimization**: AI suggestions for menu improvements

### 3.3 Menu Performance
- [ ] Create menu analytics system
- [ ] Implement recipe popularity tracking
- [ ] Add customer satisfaction metrics
- [ ] Create menu rotation system
- [ ] Add seasonal menu features

**Implementation Details**:
- **Analytics**: Track which recipes sell best
- **Popularity**: Monitor recipe order frequency
- **Satisfaction**: Customer feedback on recipes
- **Rotation**: Seasonal or time-based menu changes
- **Seasonal Features**: Special recipes for different times

## Phase 4D: Customer Preference System 👥

### 4.1 Customer Types
- [ ] Create customer type definitions
- [ ] Implement customer preference system
- [ ] Add customer behavior patterns
- [ ] Create customer satisfaction tracking
- [ ] Add customer loyalty system

**Implementation Details**:
- **Customer Types**:
  - Budget customers: Prefer cheaper recipes
  - Gourmet customers: Prefer premium ingredients
  - Spicy customers: Prefer hot/red toppings
  - Health-conscious: Prefer green toppings
- **Preferences**: Each customer type has ingredient preferences
- **Behavior**: Different ordering patterns and frequencies
- **Satisfaction**: Track customer happiness with recipes
- **Loyalty**: Repeat customers with preferences

### 4.2 Recipe Preference System
- [ ] Implement recipe preference calculations
- [ ] Create customer choice algorithms
- [ ] Add preference modifiers
- [ ] Create customer feedback system
- [ ] Add preference learning system

**Implementation Details**:
- **Preference Calculations**: Algorithm for customer recipe choice
- **Choice Algorithm**: Weighted random selection based on preferences
- **Modifiers**: Events, upgrades, and special effects
- **Feedback**: Customer reactions to recipes
- **Learning**: System adapts to customer preferences over time

### 4.3 Customer Satisfaction
- [ ] Create satisfaction tracking system
- [ ] Implement customer feedback collection
- [ ] Add satisfaction-based bonuses
- [ ] Create customer retention system
- [ ] Add satisfaction-based events

**Implementation Details**:
- **Satisfaction Tracking**: Monitor customer happiness
- **Feedback Collection**: Customer reactions to recipes
- **Bonuses**: Rewards for high satisfaction
- **Retention**: Happy customers return more often
- **Events**: Special events based on satisfaction levels

## Phase 4E: Recipe Hot Dog Inventory System 📦

### 5.1 Dual Inventory System
- [ ] Implement base hot dog inventory
- [ ] Create recipe hot dog inventory
- [ ] Add inventory conversion system
- [ ] Create inventory tracking
- [ ] Add inventory optimization

**Implementation Details**:
- **Base Hot Dogs**: Raw hot dogs for production and scientist quotas
- **Recipe Hot Dogs**: Prepared hot dogs for customer sales
- **Conversion**: Transform base hot dogs into recipe hot dogs
- **Tracking**: Separate counters for each inventory type
- **Optimization**: Balance between production and sales

### 5.2 Recipe Production System
- [ ] Create recipe production interface
- [ ] Implement batch production system
- [ ] Add production efficiency tracking
- [ ] Create production automation
- [ ] Add production optimization

**Implementation Details**:
- **Production Interface**: Convert base hot dogs to recipe hot dogs
- **Batch Production**: Produce multiple recipe hot dogs at once
- **Efficiency**: Track production speed and costs
- **Automation**: Auto-production based on demand
- **Optimization**: Maximize profit through efficient production

### 5.3 Inventory Management
- [ ] Create inventory display system
- [ ] Implement inventory alerts
- [ ] Add inventory forecasting
- [ ] Create inventory optimization tools
- [ ] Add inventory-based events

**Implementation Details**:
- **Display**: Show both inventory types clearly
- **Alerts**: Notifications for low inventory
- **Forecasting**: Predict inventory needs
- **Optimization**: Tools to balance inventories
- **Events**: Special events based on inventory levels

## Phase 4F: Recipe Effects System ✨

### 6.1 Recipe Effects
- [ ] Implement tip chance effects
- [ ] Create multiple purchase effects
- [ ] Add bonus hot dog effects
- [ ] Create customer attraction effects
- [ ] Add special event triggers

**Implementation Details**:
- **Tip Chance**: +5% chance customer tips (bonus currency)
- [ ] Multiple Purchase: +10% chance customer buys 2+ hot dogs
- [ ] Bonus Hot Dogs: +15% chance triggers 5-10 extra hot dogs
- [ ] Customer Attraction: Recipes that attract specific customer types
- [ ] Event Triggers: Recipes that trigger special events

### 6.2 Effect Balancing
- [ ] Create effect scaling system
- [ ] Implement effect combination rules
- [ ] Add effect duration tracking
- [ ] Create effect optimization
- [ ] Add effect-based achievements

**Implementation Details**:
- **Scaling**: Effects scale with recipe value/quality
- **Combination Rules**: How multiple effects interact
- **Duration**: Temporary vs permanent effects
- **Optimization**: Maximize effect benefits
- **Achievements**: Rewards for using specific effects

### 6.3 Special Recipe Effects
- [ ] Implement rare ingredient effects
- [ ] Create combination bonuses
- [ ] Add seasonal effects
- [ ] Create event-specific effects
- [ ] Add prestige effects

**Implementation Details**:
- **Rare Ingredients**: Special effects from premium ingredients
- **Combination Bonuses**: Bonuses for ingredient combinations
- **Seasonal Effects**: Time-based recipe bonuses
- **Event Effects**: Special effects during events
- **Prestige Effects**: Effects that unlock with progression

## Technical Implementation Details

### Data Models

#### Recipe System
```gdscript
# RecipeDefinition.gd
class_name RecipeDefinition
extends Resource

@export var recipe_id: String
@export var name: String
@export var description: String
@export var ingredients: Array[IngredientSlot]
@export var base_value: int
@export var effects: Array[RecipeEffect]
@export var unlock_requirements: Array[String]
@export var popularity: float
@export var created_date: String

# IngredientSlot.gd
class_name IngredientSlot
extends Resource

@export var slot_type: IngredientType
@export var ingredient_id: String
@export var quantity: int = 1

enum IngredientType {
    BUN,
    WEENIE,
    GREEN_TOPPING,
    WHITE_TOPPING,
    RED_TOPPING
}

# RecipeEffect.gd
class_name RecipeEffect
extends Resource

@export var effect_type: EffectType
@export var effect_value: float
@export var effect_chance: float
@export var effect_duration: float

enum EffectType {
    TIP_CHANCE,
    MULTIPLE_PURCHASE,
    BONUS_HOT_DOGS,
    CUSTOMER_ATTRACTION,
    SPECIAL_EVENT
}
```

#### Inventory System
```gdscript
# GameData.gd additions
var base_hot_dogs: int = 0
var recipe_hot_dogs: Dictionary = {}  # recipe_id -> quantity
var ingredients: Dictionary = {}  # ingredient_id -> quantity

# InventoryManager.gd
class_name InventoryManager
extends Node

signal inventory_changed(inventory_type: String, new_amount: int)
signal recipe_produced(recipe_id: String, amount: int)

func produce_recipe_hot_dogs(recipe_id: String, amount: int) -> bool:
    # Convert base hot dogs to recipe hot dogs
    # Check ingredient availability
    # Update inventories
```

#### Customer Preference System
```gdscript
# CustomerType.gd
class_name CustomerType
extends Resource

@export var customer_id: String
@export var name: String
@export var preferences: Dictionary  # ingredient_type -> preference_value
@export var behavior_pattern: BehaviorPattern
@export var satisfaction_threshold: float

enum BehaviorPattern {
    BUDGET,
    GOURMET,
    SPICY,
    HEALTH_CONSCIOUS,
    ADVENTUROUS
}
```

### UI Components

#### Recipe Creation Interface
- **Ingredient Selection**: Grid or dropdown for ingredient selection
- **Recipe Preview**: Visual representation of the hot dog
- **Validation Feedback**: Error messages and suggestions
- **Save/Load Buttons**: Recipe management controls
- **Effect Display**: Show recipe effects and bonuses

#### Menu Management Interface
- **Recipe Selection**: Choose which recipes to offer
- **Menu Preview**: Show current menu layout
- **Performance Metrics**: Sales, popularity, satisfaction
- **Optimization Tools**: Suggestions for menu improvements
- **Capacity Display**: Show available menu slots

#### Inventory Display
- **Dual Inventory**: Show both base and recipe hot dogs
- **Ingredient Inventory**: Display ingredient quantities
- **Production Interface**: Convert base to recipe hot dogs
- **Inventory Alerts**: Notifications for low inventory
- **Forecasting**: Predict inventory needs

## Testing Strategy

### Unit Tests
- Recipe validation and creation
- Ingredient combination effects
- Customer preference calculations
- Inventory conversion logic
- Recipe effect application

### Integration Tests
- Recipe creation and menu integration
- Customer ordering with preferences
- Inventory management across systems
- Recipe effects on gameplay
- Menu performance tracking

### User Experience Tests
- Recipe creation flow
- Menu management interface
- Customer preference system
- Inventory management
- Recipe effect feedback

## Success Criteria

### Phase 4A Success Criteria
- [ ] Recipe creation system functional
- [ ] Ingredient slot system working
- [ ] Recipe validation working
- [ ] Recipe save/load system functional

### Phase 4B Success Criteria
- [ ] Ingredient types implemented
- [ ] Ingredient production system working
- [ ] Ingredient effects functional
- [ ] Ingredient unlock system working

### Phase 4C Success Criteria
- [ ] Menu management interface functional
- [ ] Menu capacity system working
- [ ] Menu performance tracking active
- [ ] Menu optimization tools working

### Phase 4D Success Criteria
- [ ] Customer types implemented
- [ ] Preference system working
- [ ] Customer satisfaction tracking active
- [ ] Customer behavior patterns functional

### Phase 4E Success Criteria
- [ ] Dual inventory system working
- [ ] Recipe production system functional
- [ ] Inventory management tools working
- [ ] Inventory optimization active

### Phase 4F Success Criteria
- [ ] Recipe effects system functional
- [ ] Effect balancing working
- [ ] Special effects implemented
- [ ] Effect-based achievements working

## Timeline

**Estimated Duration**: 4-5 weeks
**Dependencies**: Phase 3 completion (research system)
**Risk Assessment**: Medium - Complex system interactions
**Priority**: High - Core gameplay expansion

This implementation plan provides a comprehensive roadmap for Phase 4, establishing the recipe and menu systems that will form the foundation for the strategic marketing and exploration features in later phases. 