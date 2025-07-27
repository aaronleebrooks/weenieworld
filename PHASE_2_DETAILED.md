# Phase 2: Game Mechanics - Implementation Plan

## Overview
Phase 2 implements the core idle game mechanics including currency system, click mechanics, upgrade system, basic animations, and event logging. This phase focuses on creating a solid foundation for the game loop with intentional naming conventions and flexible upgrade configurations.

## Current Progress Summary ✅ **MAJOR PROGRESS**

**Completed Systems (4/8)**:
1. ✅ **Currency System Foundation** - Global currency management with persistence
2. ✅ **Click Mechanics Implementation** - Instant clicks + hold actions with progress bars
3. ✅ **Progress Bar System** - Orange progress bar for hold actions only
4. ✅ **Floating Text System** - "+1" notifications with object pooling

**Remaining Systems (4/8)**:
5. 🔄 **Upgrade System Architecture** - Next priority
6. ⏳ **Animation System** - Wireframe animations
7. ⏳ **Event Logging System** - Game event tracking
8. ⏳ **Save System Integration** - Upgrade persistence

**Key Achievements**:
- **Instant click mechanics** with floating text feedback
- **Hold action system** with orange progress bars
- **Click cooldown system** to prevent accidental clicks
- **Object-pooled floating text** for performance
- **Responsive UI** that scales with viewport size
- **Signal-driven architecture** for clean system communication

## Core Design Philosophy

### Naming Conventions (Critical for Future Refactoring)
- **Currency**: `currency_amount` or `currency_balance` (not just "currency")
- **Click Actions**: `click_action` or `currency_gain_action` (not "obtain")
- **Rates**: `click_rate_seconds` and `idle_rate_seconds` (explicit units)
- **Values**: `currency_per_click` or `click_value` (not just "value")
- **Timers**: `click_progress_timer` and `idle_progress_timer` (descriptive)
- **Upgrades**: `upgrade_purchases` or `upgrade_levels` (not just "upgrades")

### Native Godot Event System Usage
- Use `_input()` for click detection
- Use `Timer` nodes for progress tracking
- Use `AnimationPlayer` for wireframe animations
- Use `Signal` system for event communication
- Use `Resource` system for upgrade configurations

## Tasks

### 1. Currency System Foundation ✅ COMPLETED
- [x] Create `CurrencyManager` autoload for global currency handling
- [x] Implement `currency_balance` with proper getter/setter methods
- [x] Add currency formatting (e.g., "1,234" or "1.2K")
- [x] Create currency display UI with responsive sizing
- [x] Implement currency persistence in save system

**Implementation Details**:
- **Proper naming conventions**: `currency_balance`, `currency_per_click`, `click_rate_seconds`, `idle_rate_seconds`
- **Native Godot integration**: Autoload system with signal-driven communication
- **Save system integration**: Automatic currency persistence with JSON storage
- **Responsive UI**: CurrencyDisplay with percentage-based font sizing (2% vw)
- **Currency formatting**: Smart formatting with K/M/B suffixes
- **Debug logging**: Comprehensive logging for all currency operations

### 2. Click Mechanics Implementation ✅ **COMPLETED**
- [x] Create `ClickManager` for handling click interactions
- [x] Implement instant single-click currency gain (no progress bar)
- [x] Add hold-to-click functionality with progress bar
- [x] Create visual feedback for button states (idle/clicked/held)
- [x] Implement `idle_rate_seconds` timer for hold actions
- [x] Add floating text system for currency gain notifications
- [x] Implement click cooldown system to prevent accidental clicks

**Implementation Details**:
- **Instant clicks**: No progress bar, immediate currency gain with "+1" floating text
- **Hold actions**: 0.3s progress bar (orange) with continuous currency gain
- **Button states**: "Gain Currency" → "Clicked!" → "Gain Currency" (200ms delay)
- **Hold states**: "Gain Currency" → "Holding..." (orange progress bar)
- **Click cooldown**: 200ms cooldown after holding to prevent accidental clicks
- **Floating text**: Object-pooled "+1" notifications that fade out and move up
- **Progress bar**: Only shows for hold actions, hidden for clicks

### 3. Progress Bar System ✅ **COMPLETED**
- [x] Create `ProgressBar` UI component with responsive sizing
- [x] Implement smooth progress animation (0% to 100%)
- [x] Add visual feedback for hold actions only (orange progress bar)
- [x] Remove progress bar for instant clicks (cleaner UX)
- [x] Create progress bar manager for hold actions

**Implementation Details**:
- **Responsive sizing**: Percentage-based sizing (40% viewport width, 3% height)
- **Smooth animation**: 60 FPS progress updates with tween animations
- **Hold-only display**: Progress bar only shows for hold actions (orange)
- **Click-free design**: No progress bar for instant clicks (better UX)
- **Signal integration**: Connected to ClickManager for state changes
- **Visual feedback**: Orange color for holds, gray for idle state

### 4. Floating Text System ✅ **COMPLETED**
- [x] Create `FloatingText` component for currency gain notifications
- [x] Implement object pooling for efficient performance
- [x] Add smooth fade out and move up animations
- [x] Create responsive positioning system
- [x] Integrate with currency gain events

**Implementation Details**:
- **Object pooling**: Efficient reuse of floating text instances (max 10)
- **Smooth animations**: 1-second fade out with 50px upward movement
- **Responsive positioning**: Positioned near currency gain button
- **Event integration**: Connected to both click and hold completion events
- **Visual feedback**: "+1" text that appears and fades out for all currency gains
- **Performance optimized**: Reuses existing instances instead of creating new ones

### 5. Upgrade System Architecture
- [ ] Design flexible upgrade configuration system
- [ ] Create `UpgradeManager` autoload for upgrade handling
- [ ] Implement upgrade data structures with costs, effects, and limits
- [ ] Add upgrade purchase validation and currency deduction
- [ ] Create upgrade display UI with responsive sizing

### 6. Animation System
- [ ] Create wireframe animation system for currency gain
- [ ] Implement `AnimationManager` for coordinating animations
- [ ] Add simple left-right movement animations
- [ ] Create animation configuration for future sprite replacement
- [ ] Implement animation timing synchronization with progress bars

### 7. Event Logging System
- [ ] Create `EventLogger` autoload for tracking game events
- [ ] Implement configurable log entries for different actions
- [ ] Add log display UI with scrollable history
- [ ] Create log persistence and filtering options
- [ ] Add timestamp and event categorization

### 8. Save System Integration
- [ ] Extend save system to include currency and upgrades
- [ ] Implement upgrade level persistence
- [ ] Add currency balance saving
- [ ] Create save data validation and migration
- [ ] Add save/load testing and error handling

## Technical Implementation Details

### Currency System Architecture
```gdscript
# CurrencyManager.gd
var currency_balance: int = 0
var currency_per_click: int = 1
var click_rate_seconds: float = 0.1
var idle_rate_seconds: float = 0.3
```

### Click Mechanics Architecture
```gdscript
# ClickManager.gd
var is_clicking: bool = false
var is_holding: bool = false
var click_progress_timer: Timer
var idle_progress_timer: Timer
```

### Upgrade System Architecture
```gdscript
# UpgradeManager.gd
var upgrade_levels: Dictionary = {}
var upgrade_definitions: Array[UpgradeDefinition]
var total_upgrades_purchased: int = 0
```

### Animation System Architecture
```gdscript
# AnimationManager.gd
var animation_instances: Array[AnimationInstance]
var wireframe_animations: Dictionary = {}
var animation_timing: float = 0.1
```

## Upgrade Configuration System

### Flexible Upgrade Definition Structure
```gdscript
class_name UpgradeDefinition
extends Resource

@export var upgrade_id: String
@export var display_name: String
@export var description: String
@export var icon_path: String
@export var base_cost: int
@export var cost_scaling_type: CostScalingType
@export var effect_type: EffectType
@export var effect_value: float
@export var max_level: int = -1
```

### Cost Scaling Options
1. **Linear**: `cost = base_cost + (level * cost_increase)`
2. **Exponential**: `cost = base_cost * (cost_multiplier ^ level)`
3. **Curved**: `cost = base_cost * (1 + level * cost_curve_factor)`
4. **Custom**: User-defined scaling function

### Effect Types
1. **Currency Per Click**: Increases `currency_per_click`
2. **Click Rate**: Decreases `click_rate_seconds`
3. **Idle Rate**: Decreases `idle_rate_seconds`
4. **Currency Multiplier**: Multiplies all currency gains

## Initial 10 Upgrades Design

### Click Rate Upgrades (3)
1. **Faster Fingers** - Reduces click rate by 0.02s
2. **Lightning Clicks** - Reduces click rate by 0.05s
3. **Speed Demon** - Reduces click rate by 0.1s

### Idle Rate Upgrades (3)
1. **Patience Training** - Reduces idle rate by 0.05s
2. **Steady Hands** - Reduces idle rate by 0.1s
3. **Zen Master** - Reduces idle rate by 0.2s

### Currency Per Click Upgrades (2)
1. **Better Technique** - +1 currency per click
2. **Master Clicker** - +2 currency per click

### Currency Multiplier Upgrades (2)
1. **Lucky Streak** - 1.5x currency multiplier
2. **Golden Touch** - 2x currency multiplier

## Animation System Design

### Wireframe Animation Types
1. **Currency Gain Animation**: Two squares moving left-right
2. **Upgrade Purchase Animation**: Square expanding and contracting
3. **Idle Animation**: Subtle breathing motion
4. **Click Animation**: Quick flash effect

### Animation Configuration
```gdscript
class_name AnimationConfig
extends Resource

@export var animation_name: String
@export var duration_seconds: float
@export var movement_pixels: int
@export var easing_type: EasingType
@export var loop_count: int = 1
```

## Event Logging System

### Log Entry Structure
```gdscript
class_name LogEntry
extends Resource

var timestamp: String
var event_type: LogEventType
var event_message: String
var event_data: Dictionary
var is_important: bool = false
```

### Log Event Types
1. **Currency Gain**: When currency is earned
2. **Upgrade Purchase**: When an upgrade is bought
3. **Manual Save**: When player saves manually
4. **Random Event**: For future random events
5. **Milestone**: When reaching certain thresholds

### Configurable Log Messages
- **Currency Gain**: "Earned {amount} currency in {time} seconds"
- **Upgrade Purchase**: "Purchased {upgrade_name} for {cost} currency"
- **Manual Save**: "Game saved manually"
- **Milestone**: "Reached {milestone} currency!"

## UI Components

### Currency Display
- Large, prominent currency counter
- Responsive font sizing
- Currency formatting (1K, 1M, etc.)
- Animated number changes

### Progress Bar
- Smooth fill animation
- Different colors for click vs hold
- Responsive sizing
- Visual feedback for timing

### Upgrade Panel
- Grid layout of upgrade buttons
- Cost display with currency formatting
- Level indicators
- Disabled state for unaffordable upgrades

### Event Log
- Scrollable log history
- Timestamp display
- Event type filtering
- Clear log option

## Testing Strategy

### Unit Tests
- Currency calculations
- Upgrade cost scaling
- Timer accuracy
- Save/load functionality

### Integration Tests
- Click mechanics with progress bars
- Upgrade purchases with currency deduction
- Animation timing synchronization
- Event logging accuracy

### User Experience Tests
- Responsive UI at different resolutions
- Touch interaction on mobile
- Visual feedback clarity
- Performance with many upgrades

## Known Challenges and Solutions

### Challenge 1: Animation Timing Synchronization
**Solution**: Use `AnimationPlayer` with synchronized timers and signals

### Challenge 2: Upgrade Cost Scaling Flexibility
**Solution**: Create configurable scaling functions with Resource system

### Challenge 3: Event Log Performance
**Solution**: Implement log rotation and limit total entries

### Challenge 4: Save Data Migration
**Solution**: Version save data and implement migration functions

## Files Created ✅ **COMPLETED**

### Core Systems ✅
- ✅ `scripts/autoload/CurrencyManager.gd` - Global currency management
- ✅ `scripts/autoload/ClickManager.gd` - Click and hold mechanics
- ⏳ `scripts/autoload/UpgradeManager.gd` - Upgrade system (pending)
- ⏳ `scripts/autoload/AnimationManager.gd` - Animation system (pending)
- ⏳ `scripts/autoload/EventLogger.gd` - Event logging (pending)

### Resources ⏳
- ⏳ `resources/upgrades/UpgradeDefinitions.tres` - Upgrade configurations (pending)
- ⏳ `resources/animations/AnimationConfigs.tres` - Animation configs (pending)
- ⏳ `resources/events/LogEventConfigs.tres` - Event configs (pending)

### UI Scenes ✅
- ✅ `scenes/game/CurrencyDisplay.tscn` - Currency display with responsive sizing
- ✅ `scenes/game/ProgressBar.tscn` - Progress bar for hold actions
- ✅ `scenes/ui/FloatingText.tscn` - Floating text notifications
- ⏳ `scenes/game/UpgradePanel.tscn` - Upgrade interface (pending)
- ⏳ `scenes/game/EventLog.tscn` - Event log display (pending)

### Game Scene Updates ✅
- ✅ `scenes/game/Game.tscn` - Updated with currency display, progress bar, floating text
- ✅ `scenes/game/Game.gd` - Updated with floating text system and event handling
- ✅ `scenes/game/CurrencyGainButton.tscn` - Click and hold button
- ✅ `scenes/game/CurrencyGainButton.gd` - Button state management with cooldown

### Components ✅
- ✅ `scripts/components/FloatingText.gd` - Floating text component with object pooling

## Success Criteria

- [x] Currency system works with proper persistence
- [x] Click mechanics feel responsive and satisfying
- [x] Progress bars animate smoothly and accurately (hold actions only)
- [x] Floating text system provides clear visual feedback
- [x] Button state management works with cooldown system
- [ ] Upgrade system is flexible and easily configurable
- [ ] Wireframe animations sync with progress timing
- [ ] Event log captures all important actions
- [x] Save system preserves all game state
- [x] UI remains responsive across all screen sizes
- [x] Performance remains smooth with floating text system
- [x] Code is well-documented and maintainable

## Next Phase Preparation

Phase 2 establishes the core game loop and mechanics. The upgrade system and animation framework provide the foundation for Phase 3's content expansion and polish. 