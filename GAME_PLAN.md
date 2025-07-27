# Alien Hot Dog Food Truck - Development Plan

## Project Overview
**Alien Hot Dog Food Truck** is an alien-themed hot dog food truck idle game built in Godot 4.4 with responsive design for both desktop and mobile platforms. The game features a hot dog production system with customer sales, research and development, strategic marketing, and exploration mechanics.

## Core Gameplay Mechanics

### Hot Dog Production System
- **Primary Resource**: Hot dogs produced through clicking and holding
- **Click Mechanics**: 
  - Single click = +1 hot dog (instant production)
  - Hold click = +1 hot dog every 0.3 seconds (continuous production)
- **Upgradeable Values**:
  - Hot dogs per click (how many hot dogs produced per click)
  - Production speed (how fast hot dogs are produced when holding)

### Customer Sales System
- **Customer Purchases**: Customers automatically purchase hot dogs at regular intervals
- **Purchase Rate**: Upgradeable time rate for customer purchases
- **Sale Value**: Upgradeable amount of currency earned per hot dog sold
- **Inventory Management**: Hot dogs are stored until customers purchase them

### Food Truck Identity System
- **Truck Naming**: Players enter their food truck name at game start
- **Truck Identity**: Name appears throughout the game and in all references
- **Alien Theme**: All text runs through "alien cypher" for immersion

### Progression System
- Currency earned from hot dog sales can be spent on upgrades
- Upgrades increase production capacity and sales efficiency
- Persistent save system to maintain progress
- Achievement and random event systems for progression

## Major Feature Systems

### 1. Office & Research System
- **Office Purchase**: Unlocks research capabilities and new menu sections
- **Laboratory Station**: Research facility with scientists and research points
- **Scientists**: Hired with hot dog quotas, generate research points
- **Research Trees**: Multiple upgrade paths for different strategies
- **Research Management**: Save/load research configurations, reset options

### 2. Recipe & Menu System
- **Recipe Creation**: Custom hot dog recipes with ingredients
- **Ingredient Types**: Bun, weenie, greenTopping, whiteTopping, redTopping
- **Menu Management**: Select which recipes to offer customers
- **Customer Preferences**: Different customer types prefer different recipes
- **Recipe Upgrades**: Multiple topping slots, special effects
- **Recipe Hot Dogs**: Separate inventory for recipe-based hot dogs vs base hot dogs

### 3. Strategic Marketing (Tower Defense)
- **Customer Line Visualization**: Top-down view of customer flow
- **Tower Placement**: Buff/debuff towers to influence customer behavior
- **Competition**: Competing food trucks with their own towers
- **Grid System**: Parking lot grid for strategic placement
- **Customer Waves**: Wave-based customer spawning system
- **Marketing Workers**: Generate market research points for tower purchases

### 4. Exploration & Hex Crawl
- **Hex Map**: Explore new locations for your food truck (12x12 or 24x24 grid)
- **Random Encounters**: Events while exploring hexes
- **New Locations**: Different parking spots with unique challenges
- **Food Truck Challenges**: 1v1 competitions against other trucks
- **Location Variety**: Different customer types and competition levels
- **Competition Balance**: AI trucks simulate specific builds as skill checks

### 5. Event System
- **Achievement Events**: Triggered by reaching milestones
- **Random Events**: Based on gameplay actions (hot dogs produced, customers served)
- **Event Effects**: Defined event types with specific outcomes
- **Event Log**: In-game log showing event history
- **Event Modals**: Animated modals for important events
- **Debug Events**: Manual event triggering for testing

### 6. Worker Assignment System
- **Station Workers**: Assign workers to different stations
- **Food Truck Workers**: Auto-click the make hot dog button
- **Laboratory Workers**: Convert hot dogs to research points
- **Marketing Workers**: Generate market research points for towers
- **Worker Management**: Hire, assign, and manage worker quotas
- **Worker Quotas**: Hot dog consumption rates (1 hot dog/second per scientist)

## Technical Architecture

### Project Structure
```
alien-hot-dog-truck/
├── scenes/
│   ├── main_menu/
│   │   ├── MainMenu.tscn
│   │   ├── TruckNaming.tscn
│   │   └── MainMenu.gd
│   ├── game/
│   │   ├── Game.tscn
│   │   ├── Game.gd
│   │   └── components/
│   │       ├── HotDogDisplay.gd
│   │       ├── CurrencyDisplay.gd
│   │       └── ProgressBar.gd
│   ├── ui/
│   │   ├── upgrades/
│   │   │   ├── UpgradesMenu.tscn
│   │   │   └── UpgradesMenu.gd
│   │   ├── stations/
│   │   │   ├── OfficeMenu.tscn
│   │   │   ├── OfficeMenu.gd
│   │   │   ├── LaboratoryMenu.tscn
│   │   │   ├── LaboratoryMenu.gd
│   │   │   ├── KitchenMenu.tscn
│   │   │   ├── KitchenMenu.gd
│   │   │   ├── MarketingMenu.tscn
│   │   │   └── MarketingMenu.gd
│   │   ├── recipes/
│   │   │   ├── RecipeMenu.tscn
│   │   │   └── RecipeMenu.gd
│   │   ├── exploration/
│   │   │   ├── ExplorationMenu.tscn
│   │   │   └── ExplorationMenu.gd
│   │   ├── events/
│   │   │   ├── EventModal.tscn
│   │   │   └── EventLog.tscn
│   │   └── settings/
│   │       ├── SettingsMenu.tscn
│   │       └── SettingsMenu.gd
│   └── shared/
│       ├── SaveSystem.gd
│       └── GameData.gd
├── assets/
│   ├── animations/
│   │   ├── background/
│   │   ├── foreground/
│   │   └── ui/
│   ├── sounds/
│   └── ui/
│       └── wireframe/
└── scripts/
    ├── autoload/
    │   ├── GameManager.gd
    │   ├── HotDogManager.gd
    │   ├── CustomerManager.gd
    │   ├── ResearchManager.gd
    │   ├── RecipeManager.gd
    │   ├── MarketingManager.gd
    │   ├── ExplorationManager.gd
    │   ├── EventManager.gd
    │   ├── WorkerManager.gd
    │   ├── AlienCypher.gd
    │   └── AudioManager.gd
    ├── components/
    │   ├── ClickableButton.gd
    │   ├── AnimatedBackground.gd
    │   └── FloatingText.gd
    └── resources/
        ├── RecipeDefinition.gd
        ├── ResearchDefinition.gd
        ├── EventDefinition.gd
        └── TowerDefinition.gd
```

### Scene Hierarchy

#### Main Menu Scene
```
MainMenu (Control)
├── Background (ColorRect)
├── Title (Label)
├── MenuContainer (VBoxContainer)
│   ├── NewGameButton (Button)
│   ├── ContinueButton (Button)
│   ├── OptionsButton (Button)
│   └── QuitButton (Button)
└── VersionLabel (Label)
```

#### Truck Naming Scene
```
TruckNaming (Control)
├── Background (ColorRect)
├── Title (Label)
├── NameInput (LineEdit)
├── ConfirmButton (Button)
└── BackButton (Button)
```

#### Game Scene
```
Game (Control)
├── BackgroundAnimation (AnimatedSprite2D)
├── ForegroundAnimation (AnimatedSprite2D)
├── ClickArea (TextureButton)
├── UIContainer (Control)
│   ├── TruckNameDisplay (Label)
│   ├── CurrencyDisplay (Label)
│   ├── HotDogDisplay (Label)
│   ├── TopButtons (HBoxContainer)
│   │   ├── OfficeButton (Button)
│   │   ├── LaboratoryButton (Button)
│   │   ├── RecipesButton (Button)
│   │   ├── MarketingButton (Button)
│   │   ├── ExplorationButton (Button)
│   │   └── SettingsButton (Button)
│   └── BottomUI (Control)
│       └── WorkersAndCustomers (AnimatedSprite2D)
└── MenuOverlays
```

## Development Phases

### Phase 1: Core Foundation ✅ **COMPLETED**
- Basic hot dog production system
- Customer sales mechanics
- Simple upgrade system
- Save/load functionality
- Responsive UI design

### Phase 2: Game Mechanics ✅ **COMPLETED**
- Click and hold mechanics
- Progress bars and animations
- Floating text system
- Upgrade panel UI
- Animation system

### Phase 3: Food Truck Identity & Office System
- Truck naming system
- Alien cypher implementation
- Office purchase and unlock
- Laboratory system
- Research points and scientists
- Basic research trees

### Phase 4: Recipe & Menu System
- Recipe creation interface
- Ingredient system
- Menu management
- Customer preference system
- Recipe upgrades and effects

### Phase 5: Strategic Marketing
- Tower defense mechanics
- Customer line visualization
- Tower placement system
- Competition mechanics
- Grid-based parking lot

### Phase 6: Exploration & Events
- Hex crawl system
- Random encounter system
- Event system with modals
- Achievement system
- Location variety

### Phase 7: Advanced Features
- Advanced research trees
- Complex customer AI
- Multi-location management
- Advanced recipe system
- Competition challenges

## Key Technical Decisions

### Data Models
- **Recipe System**: Flexible ingredient-based recipes
- **Research Trees**: Configurable upgrade paths
- **Event System**: Event-driven architecture
- **Save System**: Comprehensive data persistence
- **Alien Cypher**: Text transformation system

### Performance Considerations
- **Animation Optimization**: Efficient sprite and tween management
- **Memory Management**: Object pooling for frequent operations
- **Save System**: Efficient data serialization
- **UI Responsiveness**: Smooth transitions and updates

### Scalability
- **Modular Architecture**: Easy to add new features
- **Configuration-Driven**: Easy to balance and adjust
- **Event System**: Flexible event handling
- **Research System**: Extensible upgrade trees

## Success Criteria

### Phase 3 Success Criteria
- [ ] Truck naming system functional
- [ ] Alien cypher working on all text
- [ ] Office purchase unlocks new menus
- [ ] Laboratory with scientists functional
- [ ] Research points system working
- [ ] Basic research trees implemented

### Phase 4 Success Criteria
- [ ] Recipe creation interface complete
- [ ] Ingredient system functional
- [ ] Menu management working
- [ ] Customer preferences implemented
- [ ] Recipe effects working

### Phase 5 Success Criteria
- [ ] Tower defense mechanics functional
- [ ] Customer line visualization working
- [ ] Tower placement system complete
- [ ] Competition mechanics implemented
- [ ] Grid system working

### Phase 6 Success Criteria
- [ ] Hex crawl system functional
- [ ] Random encounters working
- [ ] Event system with modals complete
- [ ] Achievement system implemented
- [ ] Location variety working

## Timeline

**Estimated Duration**: 6-12 months
**Dependencies**: Phase 1-2 completion (✅ DONE)
**Risk Assessment**: Medium-High - Complex systems require careful planning
**Priority**: High - Core gameplay expansion

This development plan provides a comprehensive roadmap for transforming the current hot dog store into the full "Alien Hot Dog Food Truck" experience with all the planned features and systems. 