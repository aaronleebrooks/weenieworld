# Office Purchase System - Implementation Plan

## Overview
This document outlines the implementation plan for the Office Purchase System, which introduces worker management, building upgrades, and enhanced progression mechanics to the Alien Hot Dog Food Truck game.

## Requirements Analysis

### Core Requirements
1. **Menu System Restructure**: Split upgrades into "Kitchen Upgrades" and "Buildings" submenus
2. **Office Purchase**: 500 currency cost, unlocks after 100 currency earned
3. **Worker System**: Hire workers (10, 100, 1000 currency), assign to Kitchen/Office
4. **Worker Mechanics**: 1 hot dog/second consumption, different production rates
5. **Rate Display**: Multi-line display showing $/s, hot dogs/s, consumption rates
6. **Debug System**: Manual currency/hot dog addition for testing
7. **Achievement System**: Milestone achievements (25$, 100$, etc.) with event log integration

### Technical Requirements
- **Menu Architecture**: Submenu system with unlock progression
- **Worker Management**: Autoload system for worker hiring and assignment
- **Rate Calculations**: Real-time calculation and display of production/consumption rates
- **Save Integration**: Persistence of office, workers, and assignments
- **Event System**: Achievement triggers and event log integration

## Epic-Level Tickets

### Epic 1: Menu System Restructure 🏗️
**Priority**: Critical
**Estimated Effort**: 3-4 days
**Dependencies**: None

**Description**: Restructure the current upgrade menu into two submenus - "Kitchen Upgrades" for existing upgrades and "Buildings" for new facility purchases.

**Acceptance Criteria**:
- [x] Upgrades menu split into "Kitchen Upgrades" and "Buildings" submenus
- [ ] "Buildings" submenu unlocks after earning 100 currency
- [ ] Office appears as first option in Buildings submenu
- [x] Existing upgrades moved to Kitchen Upgrades submenu
- [?] Menu navigation works seamlessly between submenus

### Epic 2: Office Purchase System 🏢 Cannot test because of above
**Priority**: Critical
**Estimated Effort**: 2-3 days
**Dependencies**: Epic 1

**Description**: Implement the office purchase system with proper unlock conditions, purchase mechanics, and integration with the building system.

**Acceptance Criteria**:
- [ ] Office costs 500 currency
- [ ] Office unlocks after earning 100 currency for the first time
- [ ] Office purchase is instant (no confirmation modal)
- [ ] Office purchase unlocks worker system
- [ ] Office status is tracked in save system
- [ ] Purchase feedback appears in event log

### Epic 3: Worker Management System 👥
**Priority**: Critical
**Estimated Effort**: 4-5 days
**Dependencies**: Epic 2

**Description**: Implement the complete worker system including hiring, assignment, and management mechanics.

**Acceptance Criteria**:
- [ ] Workers can be hired for 10, 100, 1000 currency (increasing cost)
- [ ] Workers consume 0.5 hot dog per second
- [ ] Workers can be assigned to Kitchen or Office
- [ ] Kitchen workers auto-produce hot dogs (different rate than clicks)
- [ ] Office workers improve work rate of all workers
- [ ] Worker assignments are saved and loaded
- [ ] Worker quota monitoring and warnings

### Epic 4: Rate Display System 📊
**Priority**: High
**Estimated Effort**: 2-3 days
**Dependencies**: Epic 3

**Description**: Implement multi-line rate display showing currency per second, hot dog production rates, and consumption rates.

**Acceptance Criteria**:
- [ ] Multi-line display format (Currency: X | Hot Dogs: Y → separate lines)
- [ ] Currency per second rate display
- [ ] Hot dog production per second rate (manual + worker)
- [ ] Hot dog consumption per second rate (negative display)
- [ ] Real-time rate updates
- [ ] Responsive formatting for different screen sizes

### Epic 5: Worker-Specific Upgrades 🔧
**Priority**: Medium
**Estimated Effort**: 3-4 days
**Dependencies**: Epic 3

**Description**: Implement worker-specific upgrades that only appear after office purchase.

**Acceptance Criteria**:
- [ ] Kitchen efficiency upgrades (increase worker hot dog production)
- [ ] Worker consumption reduction upgrades
- [ ] Upgrades only appear after office purchase
- [ ] Upgrade effects apply to worker mechanics
- [ ] Upgrade costs and effects are balanced

### Epic 6: Debug System 🐛 This should be first priority.
**Priority**: Medium
**Estimated Effort**: 1-2 days
**Dependencies**: None

**Description**: Implement debug system for manual currency and hot dog addition during development.

**Acceptance Criteria**:
- [ ] Debug menu accessible in development builds
- [ ] Manual currency addition (specify amount)
- [ ] Manual hot dog addition (specify amount)
- [ ] Debug actions logged in event log
- [ ] Debug system disabled in production builds

### Epic 7: Achievement System 🏆
**Priority**: High
**Estimated Effort**: 3-4 days
**Dependencies**: Epic 2

**Description**: Implement achievement system with milestone triggers and event log integration.

**Acceptance Criteria**:
- [ ] Currency milestone achievements (25$, 100$, 500$, 1000$)
- [ ] Hot dog production milestones (100, 1K, 10K, 100K)
- [ ] Worker hiring milestones (1, 5, 10 workers)
- [ ] Achievement notifications in event log
- [ ] Achievement tracking and persistence
- [ ] Achievement rewards (optional currency bonuses)

## Detailed Task Breakdown

### Epic 1: Menu System Restructure

#### Task 1.1: Create Submenu Architecture
**Files**: `scripts/scenes/ui/UpgradePanel.gd`, `scenes/ui/UpgradePanel.tscn`
**Method**: `_create_submenu_system()`, `_setup_submenu_navigation()`
**Description**: Implement submenu system with tab-based navigation between Kitchen Upgrades and Buildings.

**Detailed Steps**:
1. Add submenu container to UpgradePanel.tscn
2. Create tab buttons for "Kitchen Upgrades" and "Buildings"
3. Implement submenu switching logic in UpgradePanel.gd
4. Add submenu state tracking and persistence
5. Update menu styling for tab-based layout

#### Task 1.2: Migrate Existing Upgrades
**Files**: `scripts/autoload/UpgradeManager.gd`, `scripts/scenes/ui/UpgradePanel.gd`
**Method**: `_migrate_upgrades_to_kitchen()`, `_filter_upgrades_by_category()`
**Description**: Move existing upgrades to Kitchen Upgrades submenu and implement category filtering.

**Detailed Steps**:
1. Add upgrade category field to UpgradeDefinition
2. Update existing upgrades with "kitchen" category
3. Implement upgrade filtering by category in UpgradeManager
4. Update UpgradePanel to display filtered upgrades
5. Test upgrade functionality in new submenu structure

#### Task 1.3: Implement Buildings Submenu
**Files**: `scripts/scenes/ui/UpgradePanel.gd`, `scripts/autoload/BuildingManager.gd` (new)
**Method**: `_create_buildings_submenu()`, `_setup_building_purchases()`
**Description**: Create Buildings submenu with office as first purchase option.

**Detailed Steps**:
1. Create BuildingManager autoload for building management
2. Implement building unlock conditions (100 currency earned)
3. Create office building definition and purchase logic
4. Add building submenu UI elements
5. Implement building purchase feedback and validation

#### Task 1.4: Add Menu Unlock Logic
**Files**: `scripts/scenes/ui/UpgradePanel.gd`, `scripts/autoload/HotDogManager.gd`
**Method**: `_check_buildings_unlock()`, `_update_menu_visibility()`
**Description**: Implement logic to unlock Buildings submenu after earning 100 currency.

**Detailed Steps**:
1. Add currency milestone tracking to HotDogManager
2. Implement unlock condition checking in UpgradePanel
3. Add visual indicators for locked/unlocked submenus
4. Create unlock notification system
5. Test unlock progression with different currency amounts

### Epic 2: Office Purchase System

#### Task 2.1: Create Office Building Definition
**Files**: `scripts/resources/BuildingDefinition.gd` (new), `scripts/autoload/BuildingManager.gd`
**Method**: `_create_office_definition()`, `_initialize_buildings()`
**Description**: Define office building properties and purchase mechanics.

**Detailed Steps**:
1. Create BuildingDefinition resource class
2. Define office properties (cost: 500, unlock: 100 currency)
3. Implement building purchase validation
4. Add building state tracking (purchased/not purchased)
5. Create building save/load integration

#### Task 2.2: Implement Office Purchase Logic
**Files**: `scripts/autoload/BuildingManager.gd`, `scripts/autoload/HotDogManager.gd`
**Method**: `purchase_office()`, `_validate_office_purchase()`
**Description**: Implement office purchase with currency deduction and unlock effects.

**Detailed Steps**:
1. Implement office purchase validation (cost, unlock conditions)
2. Add currency deduction on purchase
3. Set office as purchased in building state
4. Emit purchase signals for event log
5. Trigger worker system unlock

#### Task 2.3: Add Office Purchase UI
**Files**: `scripts/scenes/ui/UpgradePanel.gd`, `scenes/ui/UpgradePanel.tscn`
**Method**: `_create_office_purchase_button()`, `_update_office_status()`
**Description**: Create office purchase button with status display and feedback.

**Detailed Steps**:
1. Add office purchase button to Buildings submenu
2. Implement button state management (available/purchased/unlocked)
3. Add purchase confirmation feedback
4. Create office status indicator
5. Test purchase flow and error handling

#### Task 2.4: Integrate with Event System
**Files**: `scripts/autoload/BuildingManager.gd`, `scripts/autoload/EventLogManager.gd`
**Method**: `_add_office_purchase_event()`, `_trigger_office_unlock_event()`
**Description**: Add office purchase and unlock events to event log system.

**Detailed Steps**:
1. Add office purchase event to EventLogManager
2. Implement unlock notification event
3. Connect building purchase signals to event system
4. Test event logging for office purchases
5. Verify events appear in event log UI

### Epic 3: Worker Management System

#### Task 3.1: Create WorkerManager Autoload
**Files**: `scripts/autoload/WorkerManager.gd` (new), `project.godot`
**Method**: `_ready()`, `_initialize_worker_system()`
**Description**: Create WorkerManager autoload for worker hiring and management.

**Detailed Steps**:
1. Create WorkerManager.gd with worker data structures
2. Add WorkerManager to project.godot autoloads
3. Implement worker hiring costs (10, 100, 1000)
4. Create worker assignment system (Kitchen/Office)
5. Add worker quota tracking (1 hot dog/second per worker)

#### Task 3.2: Implement Worker Hiring System
**Files**: `scripts/autoload/WorkerManager.gd`, `scripts/resources/WorkerDefinition.gd` (new)
**Method**: `hire_worker()`, `_calculate_worker_cost()`
**Description**: Implement worker hiring with increasing costs and validation.

**Detailed Steps**:
1. Create WorkerDefinition resource class
2. Implement worker hiring validation (currency check)
3. Add worker cost calculation (increasing: 10, 100, 1000)
4. Create worker data tracking (ID, assignment, quota)
5. Add worker hiring events to event log

#### Task 3.3: Create Worker Assignment Interface
**Files**: `scripts/scenes/ui/WorkerAssignmentPanel.gd` (new), `scenes/ui/WorkerAssignmentPanel.tscn`
**Method**: `_create_assignment_interface()`, `_handle_worker_assignment()`
**Description**: Create UI for assigning workers to Kitchen or Office stations.

**Detailed Steps**:
1. Create WorkerAssignmentPanel scene and script
2. Implement arrow key navigation for assignments
3. Add visual worker assignment indicators
4. Create assignment confirmation system
5. Add worker quota display for each station

#### Task 3.4: Implement Worker Production Logic
**Files**: `scripts/autoload/WorkerManager.gd`, `scripts/autoload/HotDogManager.gd`
**Method**: `_process_worker_production()`, `_calculate_kitchen_production()`
**Description**: Implement worker production mechanics with different rates for clicks vs workers.

**Detailed Steps**:
1. Implement kitchen worker auto-production (different from click rate)
2. Add office worker efficiency bonuses
3. Create worker production timer system
4. Implement hot dog consumption tracking
5. Add production rate calculations and display

#### Task 3.5: Add Worker Save/Load Integration
**Files**: `scripts/autoload/WorkerManager.gd`, `scripts/autoload/SaveSystem.gd`
**Method**: `get_save_data()`, `_load_worker_data()`
**Description**: Implement worker data persistence across game sessions.

**Detailed Steps**:
1. Add worker data to save system collection
2. Implement worker state serialization
3. Add worker data loading on game start
4. Test worker persistence across save/load cycles
5. Handle worker data migration for existing saves

### Epic 4: Rate Display System

#### Task 4.1: Update Display Format
**Files**: `scripts/scenes/game/Game.gd`, `scenes/game/Game.tscn`
**Method**: `_update_rate_display()`, `_format_rate_display()`
**Description**: Convert single-line display to multi-line format with rate information.

**Detailed Steps**:
1. Update Game.tscn to use multi-line layout
2. Modify display format to separate currency and hot dogs
3. Add rate calculation methods
4. Implement real-time rate updates
5. Test display formatting at different screen sizes

#### Task 4.2: Implement Rate Calculations
**Files**: `scripts/autoload/HotDogManager.gd`, `scripts/autoload/WorkerManager.gd`
**Method**: `get_currency_per_second()`, `get_hot_dogs_per_second()`
**Description**: Calculate real-time production and consumption rates.

**Detailed Steps**:
1. Calculate currency per second from customer purchases
2. Calculate hot dog production per second (manual + worker)
3. Calculate hot dog consumption per second (worker quota)
4. Implement rate update triggers
5. Add rate formatting for display

#### Task 4.3: Add Rate Display UI
**Files**: `scripts/scenes/game/Game.gd`, `scenes/game/Game.tscn`
**Method**: `_create_rate_display_labels()`, `_update_rate_labels()`
**Description**: Create UI labels for displaying various rates.

**Detailed Steps**:
1. Add rate display labels to Game.tscn
2. Create labels for currency/s, hot dogs/s, consumption/s
3. Implement label update methods
4. Add color coding for positive/negative rates
5. Test rate display accuracy and responsiveness

#### Task 4.4: Integrate with Worker System
**Files**: `scripts/scenes/game/Game.gd`, `scripts/autoload/WorkerManager.gd`
**Method**: `_on_worker_rates_changed()`, `_update_worker_rates()`
**Description**: Connect worker system to rate display updates.

**Detailed Steps**:
1. Connect worker manager signals to rate updates
2. Update rates when workers are hired/assigned
3. Implement worker production rate calculations
4. Add worker consumption rate tracking
5. Test rate updates with worker system changes

### Epic 5: Worker-Specific Upgrades

#### Task 5.1: Create Worker Upgrade Definitions
**Files**: `scripts/autoload/UpgradeManager.gd`, `scripts/resources/UpgradeDefinition.gd`