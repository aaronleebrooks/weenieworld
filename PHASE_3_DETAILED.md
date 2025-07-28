# Phase 3: Food Truck Identity & Office System - Detailed Implementation Plan

## Overview
Phase 3 implements the core identity system for "Alien Hot Dog Food Truck" including truck naming, alien cypher, office purchase, and the research laboratory system. This phase establishes the foundation for the advanced gameplay systems in later phases.

## Current Progress Summary ⏳ **IN PLANNING**

**Planned Systems (6/6)**:
1. ⏳ **Truck Naming System** - Player enters food truck name at game start
2. ⏳ **Alien Cypher System** - Text transformation for alien immersion
3. ⏳ **Office Purchase System** - Unlocks research capabilities
4. ⏳ **Laboratory System** - Research facility with scientists
5. ⏳ **Research Points System** - Scientists generate research points
6. ⏳ **Basic Research Trees** - Multiple upgrade paths for different strategies

## Implementation Priority Order 🎯

**Priority 1**: Truck Identity System ✨
- Truck naming interface and validation
- Alien cypher implementation
- Fresh start save system
- Name integration throughout UI

**Priority 2**: Office Purchase System 🏢
- Office purchase interface
- Menu system updates (Stations section)
- Unlock progression system

**Priority 3**: Laboratory System 🔬
- Laboratory purchase and interface
- Scientist hiring and management
- Research points generation system

**Priority 4**: Research Trees 🌳
- Research definition system
- Basic research trees implementation
- Research purchase and management

**Priority 5**: Worker Assignment System 👥
- Worker management interface
- Station worker assignment
- Worker quota monitoring

**Priority 6**: Event System Foundation 🎯
- Achievement events system
- Random events system
- Event UI and modals

## Phase 3A: Truck Identity System ✨ **PRIORITY 1**

### 1.1 Truck Naming Interface
- [ ] Create `TruckNaming.tscn` scene for name input
- [ ] Implement name validation (length, characters, uniqueness)
- [ ] Add name preview with alien cypher transformation
- [ ] Create save/load integration for truck name
- [ ] Add name display throughout the game UI
- [ ] Implement fresh start - delete all existing saves

**Implementation Details**:
- **Name Input**: LineEdit with character limits and validation
- **Preview System**: Real-time alien cypher preview
- **Validation Rules**: 3-20 characters, alphanumeric + spaces
- **Save Integration**: Store in GameData and SaveSystem
- **UI Integration**: Display in game header, menus, and references

### 1.2 Alien Cypher System
- [ ] Create `AlienCypher.gd` autoload for text transformation
- [ ] Implement character substitution mapping
- [ ] Add cypher intensity levels (subtle to extreme)
- [ ] Create cypher toggle for accessibility
- [ ] Add cypher to all game text systems

**Implementation Details**:
- **Character Mapping**: Simple substitution cipher (A→X, B→Y, etc.)
- **Intensity Levels**: 
  - Level 1: Vowels only (subtle)
  - Level 2: All letters (moderate)
  - Level 3: Letters + numbers (extreme)
- **Toggle System**: Settings option to disable cypher
- **Performance**: Efficient string processing for real-time updates

### 1.3 Name Integration
- [ ] Update all UI text to reference truck name
- [ ] Add name to save file headers
- [ ] Create name display in main game scene
- [ ] Add name to menu headers and tooltips
- [ ] Implement name in event and achievement text

## Phase 3B: Office Purchase System 🏢 **PRIORITY 2**

### 2.1 Office Purchase Interface
- [ ] Create `OfficeMenu.tscn` scene for office management
- [ ] Implement office purchase with currency cost
- [ ] Add office description and benefits display
- [ ] Create unlock notification system
- [ ] Add office status to main game UI

**Implementation Details**:
- **Purchase Cost**: 1000 currency (adjustable)
- **Description**: "A place to focus. Unlock the ability to add stations to [Truck Name]"
- **Unlock Effects**: 
  - New menu section: "Stations"
  - Laboratory station access
  - Research system activation
- **Status Display**: Office status indicator in main UI

### 2.2 Menu System Updates
- [ ] Add "Stations" section to main menu
- [ ] Create station submenu structure
- [ ] Implement station unlock progression
- [ ] Add station status indicators
- [ ] Create station navigation system

**Implementation Details**:
- **Menu Structure**: Main Menu → Stations → [Station Type]
- **Station Types**: Laboratory, Kitchen, Marketing Office, etc.
- **Progression**: Office → Laboratory → Other stations
- **Status Icons**: Locked/Unlocked/Active indicators

## Phase 3C: Laboratory System 🔬 **PRIORITY 3**

### 3.1 Laboratory Interface
- [ ] Create `LaboratoryMenu.tscn` scene
- [ ] Implement laboratory purchase system
- [ ] Add scientist hiring interface
- [ ] Create research points display
- [ ] Add laboratory status and upgrades

**Implementation Details**:
- **Laboratory Cost**: 500 currency (after office purchase)
- **Scientist Hiring**: Individual scientist purchase system
- **Research Points**: Real-time display of accumulated points
- **Laboratory Upgrades**: Capacity, efficiency, and automation upgrades

### 3.2 Scientist System
- [ ] Create `ScientistDefinition.gd` resource class
- [ ] Implement scientist hiring with hot dog quotas
- [ ] Add scientist research point generation
- [ ] Create scientist management interface
- [ ] Implement scientist quota monitoring

**Implementation Details**:
- **Scientist Properties**:
  - Name (alien-themed)
  - Research rate (points per second)
  - Hot dog quota (daily requirement)
  - Cost (currency to hire)
  - Specialization (research tree focus)
- **Quota System**: 
  - 1 hot dog per second per scientist
  - Quota curves using Godot Curve resource
  - Penalty for missed quotas (no research)
  - Quota display in worker assignment interface
- **Management Interface**:
  - Hire/fire scientists
  - Adjust quotas
  - Monitor performance
  - Assign specializations

### 3.3 Research Points System
- [ ] Create `ResearchManager.gd` autoload
- [ ] Implement research point accumulation
- [ ] Add research point spending system
- [ ] Create research point display and formatting
- [ ] Add research point bonuses and multipliers

**Implementation Details**:
- **Point Generation**: 1 research point every 10 minutes per scientist
- **Point Spending**: Purchase research upgrades
- **Point Display**: Formatted display (1.2K, 1.5M, etc.)
- **Bonuses**: Multipliers from laboratory upgrades
- **Persistence**: Save/load research point totals
- **Debug Features**: Manual research point addition for testing

## Phase 3D: Research Trees 🌳 **PRIORITY 4**

### 4.1 Research Definition System
- [ ] Create `ResearchDefinition.gd` resource class
- [ ] Implement research tree structure
- [ ] Add research prerequisites and dependencies
- [ ] Create research cost scaling system
- [ ] Add research effect definitions

**Implementation Details**:
- **Research Properties**:
  - ID and display name
  - Description and effects
  - Cost (research points)
  - Prerequisites (other research)
  - Research tree category
  - Effect type and value
- **Tree Structure**: 
  - Multiple research trees
  - Branching paths
  - Convergence points
  - End-game research

### 4.2 Basic Research Trees
- [ ] Implement Production Efficiency tree
- [ ] Create Customer Attraction tree
- [ ] Add Recipe Enhancement tree
- [ ] Create Facility Expansion tree
- [ ] Add Strategic Marketing tree (foundation)

**Implementation Details**:
- **Production Efficiency**:
  - Hot dog production upgrades
  - Click efficiency improvements
  - Automation research
- **Customer Attraction**:
  - Customer spawn rate
  - Customer satisfaction
  - Customer retention
- **Recipe Enhancement**:
  - Ingredient quality
  - Recipe complexity
  - Special effects
- **Facility Expansion**:
  - Laboratory capacity
  - Scientist efficiency
  - Facility automation
- **Strategic Marketing** (Foundation):
  - Basic tower research
  - Customer flow analysis
  - Competition preparation

### 4.3 Research Management
- [ ] Create research purchase interface
- [ ] Implement research progress tracking
- [ ] Add research reset functionality
- [ ] Create research save/load system
- [ ] Add research configuration export/import

**Implementation Details**:
- **Purchase Interface**: 
  - Research tree visualization
  - Cost display and affordability
  - Prerequisite checking
  - Effect preview
- **Progress Tracking**:
  - Completed research
  - Available research
  - Locked research
  - Research tree completion %
- **Reset System**:
  - Reset all research
  - Refund research points
  - Confirmation dialog
- **Configuration System**:
  - Save research state
  - Export to clipboard
  - Import from clipboard
  - Share configurations

## Phase 3E: Worker Assignment System 👥 **PRIORITY 5**

### 5.1 Worker Management Interface
- [ ] Create `WorkerManager.gd` autoload
- [ ] Implement worker assignment system
- [ ] Add worker quota monitoring
- [ ] Create worker efficiency tracking
- [ ] Add worker hiring and firing system

**Implementation Details**:
- **Worker Types**:
  - Food Truck Workers: Auto-click make hot dog button
  - Laboratory Workers: Convert hot dogs to research points
  - Marketing Workers: Generate market research points
- **Assignment System**: Drag-and-drop or button-based assignment
- **Quota Monitoring**: Real-time hot dog consumption tracking
- **Efficiency Tracking**: Performance metrics for each worker type
- **Hiring System**: Currency-based worker recruitment

### 5.2 Station Worker Assignment
- [ ] Create station worker capacity system
- [ ] Implement worker assignment interface
- [ ] Add worker quota display
- [ ] Create worker performance metrics
- [ ] Add worker upgrade system

**Implementation Details**:
- **Station Capacity**: Maximum workers per station type
- **Assignment Interface**: Visual worker assignment system
- **Quota Display**: Show hot dog consumption rates
- **Performance Metrics**: Research points generated, efficiency
- **Worker Upgrades**: Improve worker efficiency and capacity

## Phase 3F: Event System Foundation 🎯 **PRIORITY 6**

### 6.1 Achievement Events
- [ ] Create `AchievementManager.gd` autoload
- [ ] Implement achievement tracking system
- [ ] Add achievement event triggers
- [ ] Create achievement notification system
- [ ] Add achievement rewards and effects

**Implementation Details**:
- **Achievement Types**:
  - Hot dog production milestones (100, 1K, 10K, etc.)
  - Customer service milestones
  - Research milestones
  - Facility milestones
- **Event Triggers**: Automatic detection of milestone completion
- **Notifications**: Modal popups with animations
- **Rewards**: Currency, research points, or special unlocks

### 6.2 Random Events
- [ ] Create `EventManager.gd` autoload
- [ ] Implement random event system
- [ ] Add event probability calculations
- [ ] Create event effect system
- [ ] Add event log and history

**Implementation Details**:
- **Event Triggers**:
  - Hot dog production
  - Customer purchases
  - Research completion
  - Time-based events
- **Event Types**:
  - Positive events (bonuses, rewards)
  - Negative events (penalties, challenges)
  - Neutral events (story, information)
- **Probability System**: 
  - Base probabilities
  - Modifiers from research/upgrades
  - Cooldown periods
- **Event Effects**:
  - Currency bonuses/penalties
  - Research point gains
  - Temporary buffs/debuffs
  - Special unlocks

### 6.3 Event UI System
- [ ] Create `EventModal.tscn` scene
- [ ] Implement event notification system
- [ ] Add event log interface
- [ ] Create event history tracking
- [ ] Add event animation system

**Implementation Details**:
- **Event Modal**:
  - Animated popup for important events
  - Event description and effects
  - Confirm/acknowledge button
  - Background blur effect
- **Event Log**:
  - Scrollable event history
  - Event filtering options
  - Event search functionality
  - Event export/import
- **Animations**:
  - Modal entrance/exit animations
  - Text reveal animations
  - Effect highlight animations

## Technical Implementation Details

### Data Models

#### Truck Identity System
```gdscript
# GameData.gd additions
var truck_name: String = ""
var alien_cypher_level: int = 2
var alien_cypher_enabled: bool = true

# AlienCypher.gd
class_name AlienCypher
extends Node

var character_mappings: Dictionary = {
    "a": "x", "b": "y", "c": "z", # ... etc
}
var intensity_levels: Dictionary = {
    1: ["a", "e", "i", "o", "u"],  # Vowels only
    2: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"],  # All letters
    3: ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]  # Letters + numbers
}

func transform_text(text: String, level: int = 2) -> String:
    # Implementation for alien cypher transformation
```

#### Office & Laboratory System
```gdscript
# GameData.gd additions
var office_purchased: bool = false
var laboratory_purchased: bool = false
var research_points: int = 0
var scientists: Array[ScientistData] = []
var completed_research: Array[String] = []

# ScientistData.gd
class_name ScientistData
extends Resource

@export var scientist_id: String
@export var name: String
@export var research_rate: float  # Points per second
@export var hot_dog_quota: int
@export var quota_curve: Curve
@export var specialization: String
@export var is_active: bool = true
@export var hired_date: String
```

#### Research System
```gdscript
# ResearchDefinition.gd
class_name ResearchDefinition
extends Resource

@export var research_id: String
@export var display_name: String
@export var description: String
@export var cost: int
@export var prerequisites: Array[String]
@export var research_tree: String
@export var effect_type: ResearchEffectType
@export var effect_value: float
@export var research_time: float  # Time to complete research

enum ResearchEffectType {
    PRODUCTION_EFFICIENCY,
    CUSTOMER_ATTRACTION,
    RECIPE_ENHANCEMENT,
    FACILITY_EXPANSION,
    STRATEGIC_MARKETING
}
```

#### Event System
```gdscript
# EventDefinition.gd
class_name EventDefinition
extends Resource

@export var event_id: String
@export var event_name: String
@export var description: String
@export var event_type: EventType
@export var trigger_type: TriggerType
@export var trigger_value: int
@export var probability: float
@export var effects: Array[EventEffect]

enum EventType {
    ACHIEVEMENT,
    RANDOM,
    STORY
}

enum TriggerType {
    HOT_DOGS_PRODUCED,
    CUSTOMERS_SERVED,
    RESEARCH_COMPLETED,
    TIME_BASED
}
```

### UI Components

#### Truck Naming Interface
- **Name Input**: LineEdit with validation
- **Preview Display**: Real-time cypher preview
- **Validation Feedback**: Error messages and suggestions
- **Confirm Button**: Proceed to game with chosen name

#### Office Menu
- **Office Status**: Purchase status and benefits
- **Facility List**: Available and locked facilities
- **Purchase Interface**: Cost display and confirmation
- **Progress Tracking**: Facility unlock progress

#### Laboratory Interface
- **Scientist Management**: Hire, fire, and manage scientists
- **Research Points**: Current points and generation rate
- **Research Trees**: Visual research tree interface
- **Laboratory Upgrades**: Capacity and efficiency upgrades

#### Event System
- **Event Modal**: Animated popup for important events
- **Event Log**: Scrollable history of all events
- **Event Filters**: Filter by type, date, importance
- **Event Effects**: Display of event outcomes and rewards

## Testing Strategy

### Unit Tests
- Alien cypher text transformation
- Research point calculations
- Scientist quota monitoring
- Event probability calculations
- Achievement milestone detection

### Integration Tests
- Truck name persistence across saves
- Research tree progression
- Event system integration
- Scientist research point generation
- Office/laboratory unlock flow

### User Experience Tests
- Truck naming flow
- Research tree navigation
- Event modal interactions
- Scientist management interface
- Achievement notification system

## Success Criteria

### Phase 3A Success Criteria
- [ ] Players can name their food truck
- [ ] Alien cypher transforms all game text
- [ ] Truck name appears throughout the game
- [ ] Name persists across save/load cycles

### Phase 3B Success Criteria
- [ ] Office can be purchased with currency
- [ ] Office purchase unlocks new menu sections
- [ ] Facility system is accessible
- [ ] Office status is displayed in main UI

### Phase 3C Success Criteria
- [ ] Laboratory can be purchased after office
- [ ] Scientists can be hired with hot dog quotas
- [ ] Research points are generated continuously
- [ ] Scientist management interface is functional

### Phase 3D Success Criteria
- [ ] Research trees are implemented and functional
- [ ] Research can be purchased with points
- [ ] Research effects are applied to gameplay
- [ ] Research reset and configuration system works

### Phase 3E Success Criteria
- [ ] Worker assignment system functional
- [ ] Station worker capacity working
- [ ] Worker quota monitoring active
- [ ] Worker performance metrics displayed

### Phase 3F Success Criteria
- [ ] Achievement events trigger correctly
- [ ] Random events occur based on gameplay
- [ ] Event modals display with animations
- [ ] Event log tracks all events
- [ ] Debug event triggering works

## Timeline

**Estimated Duration**: 3-4 weeks
**Dependencies**: Phase 2 completion (✅ DONE)
**Risk Assessment**: Medium - Complex systems require careful integration
**Priority**: High - Foundation for advanced gameplay systems

This implementation plan provides a comprehensive roadmap for Phase 3, establishing the core identity and research systems that will support the advanced gameplay features in later phases. 