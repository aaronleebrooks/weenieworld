# Strategic Questions & Decisions - Alien Hot Dog Food Truck

## Overview
This document tracks strategic questions, decisions, and technical considerations for the development of "Alien Hot Dog Food Truck". These discussions will help shape the implementation strategy and ensure consistent design decisions.

## 🏗️ Architecture & Data Models

### 1. Naming Conventions & Terminology

**Question**: What should we call the "buildings" or "rooms" system? "Buildings" doesn't make sense for a food truck.

**Options Considered**:
- **Facilities**: Generic, works for any type of upgrade
- **Modules**: Suggests modular components
- **Systems**: Implies different functional systems
- **Departments**: Business-oriented terminology
- **Stations**: Food service terminology

**Decision**: **Stations** - Better fits the food truck theme and enables worker assignment system.

I like stations the most. This will help with worker assignment. each station should be able to have workers assigned to it, up to a max amount. The food truck workers auto click the make hot dog button. The lab workers should be converting hot dogs to research points. The marketing workers should accrue market research points that are needed for the tower defence towers.

**Question**: How should we structure the menu hierarchy?

**Current Structure**:
```
Main Menu
├── Facilities
│   ├── Office
│   ├── Laboratory
│   ├── Kitchen
│   └── Marketing
├── Upgrades
├── Recipes
└── Settings
```

This looks good. Call them stations

**Decision**: Keep current structure, add Stations as new top-level section.

### 2. Data Model Design

**Question**: How should we handle the relationship between hot dogs and ingredients?

**Options**:
- **Hot dogs as base resource**: All hot dogs are the same, ingredients modify recipes
- **Hot dogs as recipes**: Each hot dog type is a separate recipe
- **Hybrid system**: Base hot dogs + recipe modifications

**Decision**: **Hybrid system** - Base hot dogs for production, recipes for customization.
Hot dogs should be a total value, and there should be a value for how many recipe hot dogs we own for selling purposes.

**Question**: How should research trees be structured?

**Options**:
- **Linear trees**: Simple progression paths
- **Branching trees**: Multiple paths with convergence
- **Web structure**: Complex interconnected research
- **Modular trees**: Separate trees for different systems

**Decision**: **Branching trees with convergence** - Allows for strategic choices while maintaining balance.

I'll also say there should be things to purchase outside of the tree as well, or single branch one offs that can be aquired on most builds. I think it should start with one simple research that everyone would want, and immediatly follow with a branch.

### 3. Save System Architecture

**Question**: How should we handle save data for the new systems?

**Current Save Structure**:
```gdscript
{
    "hot_dogs": {...},
    "currency": {...},
    "upgrades": {...}
}
```

**Proposed Structure**:
```gdscript
{
    "truck_identity": {
        "name": "String",
        "cypher_level": "int"
    },
    "facilities": {
        "office_purchased": "bool",
        "laboratory_purchased": "bool"
    },
    "research": {
        "points": "int",
        "scientists": "Array",
        "completed_research": "Array"
    },
    "recipes": {...},
    "events": {...}
}
```

**Decision**: **Modular save structure** - Separate sections for each major system.

## 🎮 Gameplay Mechanics

### 4. Research Point Economy

**Question**: How should research points be balanced?

**Considerations**:
- **Generation rate**: How fast should scientists generate points? I'd say it should start at 1 every ten minutes. We should have a debug button to add one. We need debug buttons for all values as well. This value is something that will be altered with events, upgrades, etc. 
- **Cost scaling**: How should research costs increase? Yeah exponential seems good, but maybe we can have this accept a curve instead for easy testing.
- **Point sources**: Should there be multiple ways to earn points? No, not for now. Eventually I could see a random event or something awarding points.
- **Point sinks**: How should players spend points? They should be spent to unlock researchs.

**Proposed Balance**:
- **Base rate**: 1 point per second per scientist
- **Cost scaling**: Exponential (base_cost * 1.5^level)
- **Additional sources**: Events, achievements, special upgrades
- **Point sinks**: Research purchases, facility upgrades

### 5. Scientist Quota System

**Question**: How should the hot dog quota system work?

**Options**:
- **Daily quotas**: Scientists need X hot dogs per day
- **Continuous quotas**: Scientists consume hot dogs continuously
- **Batch quotas**: Scientists need X hot dogs per research cycle
- **Flexible quotas**: Quotas adjust based on production

**Decision**: **Daily quotas with curves** - Predictable but scalable system.
Yeah where you assign workers should be able to show you how many hot dogs they take and at what rate. It should be like 1 hot dog p second per scientist to start.

**Question**: What happens when quotas aren't met?

**Options**:
- **No research**: Scientists stop generating points
- **Reduced efficiency**: Slower point generation
- **Penalty system**: Negative effects
- **Grace period**: Allow temporary shortfalls

**Decision**: **No research** - Clear consequence, encourages strategic planning.

### 6. Event System Design

**Question**: How should events be triggered and balanced?

**Trigger Types**:
- **Achievement-based**: Milestone completions
- **Random-based**: Probability-based events
- **Time-based**: Scheduled events
- **Action-based**: Specific player actions

**Balance Considerations**:
- **Frequency**: How often should events occur?
- **Impact**: How significant should event effects be?
- **Predictability**: Should events be predictable or surprising?
- **Player control**: How much control should players have?

**Decision**: **Mixed trigger system** with configurable probabilities and cooldowns.

## 🎨 UI/UX Design

### 7. Alien Cypher Implementation

**Question**: How should the alien cypher be implemented?

**Technical Considerations**:
- **Performance**: Real-time text transformation - yeah, maybe we can have a generated translation file at runtime so we don't have to calculate anything other then user submitted names.
- **Accessibility**: Toggle for disabled players
- **Intensity levels**: How extreme should the transformation be? They should be that cypher where it's the location of the letter on the alphabet, plus a value, followed by a letter on the alphabet minus a value. There should be capital letters integrated as well. What do you think about that? I cant remember that name of that traditional cypher.
- **Consistency**: Should all text be transformed? I think all text that is from the humans/customers. So upgrades, all of our menus, etc will all be legible in english.

**Implementation Plan**:
- **Character mapping**: Simple substitution cipher
- **Intensity levels**: 3 levels (subtle, moderate, extreme)
- **Performance**: Efficient string processing
- **Accessibility**: Settings toggle

### 8. Menu Navigation

**Question**: How should the expanded menu system be navigated?

**Options**:
- **Tab-based**: Horizontal tabs for major sections
- **Tree-based**: Expandable tree structure
- **Grid-based**: Icon grid for different systems
- **Hierarchical**: Nested menu structure

**Decision**: **Tab-based with submenus** - Clear hierarchy, familiar interface. Yep. Just make sure the tabs are left aligned and vertical. I'm looking at examples from like Melvor Idle and Magic Research and Antimatter Dimensions.

## 🔧 Technical Implementation

### 9. Research Tree Visualization

**Question**: How should research trees be displayed?

**Options**:
- **Node-based**: Visual nodes connected by lines
- **List-based**: Hierarchical list structure
- **Grid-based**: Grid layout for research items
- **Tree-view**: Expandable tree interface

**Decision**: **Node-based visualization** - Clear progression paths, visual appeal.

### 10. Event System Architecture

**Question**: How should the event system be architected?

**Components Needed**:
- **Event definitions**: Data structure for events
- **Event manager**: Handles event triggering and processing
- **Event UI**: Modal and log interfaces
- **Event effects**: System for applying event outcomes

**Architecture Plan**:
- **EventManager autoload**: Central event handling
- **EventDefinition resources**: Configurable event data
- **Event UI components**: Modal and log scenes
- **Effect system**: Modular effect application

### 11. Save System Migration

**Question**: How should we handle save data migration for existing players?

**Options**:
- **Automatic migration**: Convert old saves to new format
- **Fresh start**: Require new saves for new features
- **Hybrid approach**: Migrate what we can, default the rest


Fresh start. Delete all saves currently present.
**Decision**: **Fresh start** - Delete all existing saves for new features.

## 🎯 Game Balance

### 12. Progression Pacing

**Question**: How should the new systems affect game progression?

**Considerations**:
- **Early game**: How quickly should players access new features?
- **Mid game**: How should research and facilities scale?
- **Late game**: What should end-game progression look like?
- **Balance**: How should new systems interact with existing ones?

**Proposed Pacing**:
- **Office**: Available after 1000 currency (early game)
- **Laboratory**: Available after office purchase (early-mid game)
- **Research trees**: Unlock progressively (mid game)
- **Advanced features**: Require significant research (late game)

### 13. Resource Balance

**Question**: How should the new resources (research points, scientists) be balanced?

**Resource Types**:
- **Currency**: Primary resource for purchases
- **Hot dogs**: Production resource, scientist quotas. - you can have indivdual recipe types owned for selling.
- **Research points**: Research currency
- **Scientists**: Research generators
- there's also topping materials, like green toppings, red toppings, and white toppings.

**Balance Strategy**:
- **Currency**: Primary for facility purchases
- **Hot dogs**: Production focus, scientist maintenance
- **Research points**: Research progression
- **Scientists**: Research investment, hot dog sink

Yeah these values should be able ot be controlled in a central location for easy altering from the godot ui instead of in code.They should also be alterable with a debug menu in game.

## 🔮 Future Considerations

### 14. Scalability Planning

**Question**: How should we design systems to support future features?

**Areas to Consider**:
- **Recipe system**: Support for complex recipes
    - the recipies will have a name, as well as slots for up to three toppings. To start, only one topping will be available, with additional toppings on recipies being unlocked through upgrades. These are things like buns, raw onion, caramelized onions, bacon, etc.
- **Marketing system**: Tower defense mechanics

- **Exploration system**: Hex crawl implementation
- **Competition system**: Multi-truck challenges
Additional upgrades are based on a whole other system called strategic marketing. This will be a tower defence section of the game, where the line of customers can be seen from above. We can place towers that provide buffs or debuffs to customers. Eventually, there will be competing food trucks in the same parking lot, and they will have their own towers trying to get customers to buy from them instead of you. the parking lot will be a big grid, and customers will spawn in waves. You won't be able to see this screen or anything until you purchase that strategic marketing. You should be able to buy towers and line guides that are decorative, the customers pile into in that order, until there is no where else left in the line. Then they wait in a waiting line where they will just go to whatever line has an open slot, in order of the waiting line. There will also be different background/foreground animations as we move through these menus.
There will also be a hex crawl element as you explore for new locations for your food truck. This is the next big suite of things unlocked for you. You will be able to have random encounters from the hexes as you explore, and you will be able to find new places to park your hot dog food truck. These places will have different hot dog food trucks that do different things to siphon off customers. You can also get into a food truck challenge, where you compete in challenges vs another food truck one on one, in a test of your research tree and worker configurations.

**Design Principles**:
- **Modular architecture**: Independent systems
- **Configurable data**: Resource-based definitions
- **Extensible interfaces**: Easy to add new features
- **Performance optimization**: Scalable for complex systems

### 15. Content Creation

**Question**: How should we structure content creation for the new systems?

**Content Types**:
- **Research trees**: Multiple upgrade paths
- **Events**: Achievement and random events
- **Recipes**: Ingredient combinations
- **Scientists**: Character definitions

**Content Strategy**:
- **Data-driven**: Resource-based content definition
- **Modular**: Easy to add new content
- **Balanced**: Configurable balance parameters
- **Extensible**: Support for future content types

## 📋 Implementation Priorities

### Phase 3 Priorities
1. **Truck naming system** - Foundation for identity
2. **Alien cypher** - Core theme implementation
3. **Office purchase** - Gateway to new systems
4. **Laboratory system** - Core research mechanics
5. **Basic research trees** - Progression system
6. **Event system foundation** - Achievement and random events

### Future Phase Considerations
- **Recipe system design** - Plan for Phase 4
- **Marketing system architecture** - Plan for Phase 5
- **Exploration system foundation** - Plan for Phase 6
- **Competition mechanics** - Plan for Phase 7

## 🤔 Open Questions

### Immediate Questions
1. **Scientist names**: Should they be alien-themed or human names? We can use a random human name generator. 
2. **Research tree themes**: What should the different research trees focus on? They should be different farms or generation method improvements, autobuyers, recipies for sale, different facilities
3. **Event frequency**: How often should random events occur? Fairly infrequently. We should have a debug button to trigger these
4. **Cypher intensity**: What should the default cypher level be?

### Phase 3 Priority 1 Decisions ✅

#### Truck Naming System
- **Validation**: 3-20 characters, allow special characters safely, no profanity filter
- **Uniqueness**: Single truck name per save file, changeable throughout game
- **Preview**: No alien cypher preview needed (truck name stays in English)
- **Flow**: After main menu → New Game → Name modal → Main game
- **Display**: Prominent header at top, variable substitution in descriptions
- **UI**: Text wrapping for long names, not in all menu headers

#### Alien Cypher System
- **Implementation**: `(letter_position + offset) % 26` then `(result - offset) % 26`
- **Scope**: Only customer/human text (orders, event dialogue), not UI elements
- **Toggle**: No accessibility toggle needed
- **Truck Name**: Not cyphered, stays in English

#### Fresh Start
- **Save Deletion**: Delete immediately during development, warnings for user actions
- **Modal**: Integrated into main menu flow, not separate scene

### Future Questions
1. **Recipe complexity**: How complex should the recipe system be? It should be fairly simple. You can save, edit, and load recipies. You can have any number, and sort by name, last created, or popularity. You can purchase recipies that might unlock you new toppings. The recipies should show the hot dog expected value, plus a list of all effects from the recipie. When in the kitchen screen, 
2. **Marketing mechanics**: How should the tower defense system work? There will be a grid featuring where your food truck is on the bottom row, with the line forming in front of it. The customers move towards your food truck following the paths you put down, at the rate of hot dogs being sold. You can place down towers along the path you make to give buffs to your customers or try to nullify the effects of bad customers.The buffs could be +50% tip chance, increasing chance to buy multiple hot dogs, or bad things like not paying for a hot dog or taking twice as long to order. The system will start out with you in an empty parking lot. eventually, it will be you on one side of the grid, and another food truck at the opposite side. At that point, you can place towers along the other path that attempt to give priority to your restaurant, such as a tower that has a 10% chance of making someone swap lines, or one that has a high likelyhood of converting, but a 100% chance of creating a bad customer.
3. **Exploration scope**: How large should the hex map be? It should be small to begin with, so maybe 24 x 24? Or 12 x 12? Regardless, we should be able to esily test these maps.
4. **Competition balance**: How should competing trucks be balanced? I think they should simultate a build of a food truck with upgrades attuned to a specific output that acts as a skill/settings check for the player to move onto the next area.

## 📝 Decision Log

### Decisions Made
- **Facilities**: Chosen over "buildings" or "rooms"
- **Hybrid hot dog system**: Base hot dogs + recipe modifications
- **Branching research trees**: Multiple paths with convergence
- **Daily scientist quotas**: Predictable but scalable system
- **Node-based research visualization**: Clear progression paths
- **Automatic save migration**: Preserve player progress

### Pending Decisions
- Scientist naming convention
- Default cypher intensity level
- Research tree themes and focus areas
- Event frequency and balance parameters

This document will be updated as decisions are made and new questions arise during development. 


## Phase 3 Priority 2 Decisions - Office Purchase System 🏢

🏢 Office Purchase Mechanics:
1. Cost Structure & Prerequisites:
- **Office Cost**: 1000 currency (fixed amount)
- **Debug Requirement**: Need debug button to give 1000 currency for testing
- **Prerequisites**: Only appears after earning 100 currency for the first time
- **Cost Scaling**: Fixed amount, no scaling with existing upgrades

2. Purchase Location & UI:
- **Location**: In existing upgrade panel at the bottom in a "Stations" section
- **Presentation**: Same style as other upgrades (inline purchase)
- **Visual Style**: Consistent with existing upgrade UI

3. Purchase Flow:
- **Confirmation**: No confirmation modal needed
- **Purchase Type**: Instant purchase
- **Feedback**: Visible in in-game event log (needs implementation - add to phase document)
📋 Menu System Integration:
4. Stations Menu Structure:
- **Office Button**: New button for office access (like "Upgrades")
- **Navigation**: Arrow button on main screen to access office
- **Worker System**: 
  - Hire workers for increasing costs: 10, 100, 1000 currency
  - Maximum 2 workers initially (upgradeable)
  - Workers consume 1 hot dog per second each
  - Workers can be assigned to different stations
- **Worker Assignments**:
  - Kitchen: Auto-clicker on slow timer (slower than manual holding)
  - Office: Auto-buyer for lowest affordable upgrade on interval
- **Station Navigation**: Big station map with clickable rooms
- **Kitchen Integration**: Current game screen becomes kitchen with key rate displays

5. Unlock Progression:
- **Order**: Kitchen (start) → Office → Laboratory (3000 currency)
- **Available After Office**: Kitchen and Office stations
- **Milestone Requirements**: Laboratory unlocks at 3000 currency

6. Visual Status Indicators:
- **Normal State**: White outline for operational stations
- **Warning State**: Red outline when worker needs cannot be met (hot dog quota)
- **Notification**: Exclamation mark when affordable upgrades available
- **Worker Status**: Workers turned off when quota cannot be met
⚙️ Office Functionality:
7. Office Benefits:
Beyond unlocking stations, what immediate benefits should the office provide?
A) Small currency bonus (e.g., +5% to all sales)
B) Unlock new upgrade categories
C) Provide a "management bonus" to existing systems
D) Just be a gateway to other systems (no direct benefits)
8. Office Management:
Should the office itself be upgradeable? (Capacity, efficiency, etc.) Yes, you should be able the ability to hire more workers than the initial 3.
Should there be an office management interface or just "purchase and forget"? You should be able to eventually upgrade into autobuying setting, but they are hardset in the beginning.
Should the office have any ongoing costs or maintenance? Just the costs of any worker assigned to the office.
9. Integration with Existing Systems:
How should the office integrate with the save system? Office purchases should be registered in the save. Since the game will mostly be a lot of things purchased and upgradedetc, I don't think the office purchases should be unique. I think we will want ot track the upgrades, the settings, and how many workers are currently assgined there. 
Should it affect any existing UI elements or just add new ones? New ones.
How should it work with the truck naming system (e.g., "Office of [Truck Name]")? Nothing specifically for now.
�� Visual Design & UX:
10. Office Theme & Aesthetics:
Should the office have an alien theme to match the truck naming? It should be fairly normal if not plain. This is the start of the game so things should get cooler as you go along.
What visual style should the office interface have? It should be a guy at a desk, typing away in the background. For the settings, I am thinking of the magic Research game how you assign researchers plus a button to purchase a worker.
Should there be any background animations or effects? Yes, there should be a sound effect played as you purchase a new worker, or as you change the worker assignments.
11. Accessibility & Usability:
How should the office be discoverable to new players? there should be an exclamation mark on the upgrade store showing new purchases available.
Should there be tooltips or help text explaining the office system? Yes, there should be an info icon that shows an explanation modal for each station.
How should it integrate with the existing game flow? It will allow the player to assign workers as autoclickers to start idle progression

## ✅ Priority 2 Implementation Decisions Summary

### 🏢 Office Purchase System - Final Decisions:
- **Cost**: 1000 currency (fixed)
- **Prerequisites**: Appears after earning 100 currency
- **Location**: Upgrade panel "Stations" section
- **Purchase**: Instant, no confirmation
- **Feedback**: In-game event log

### 👥 Worker System:
- **Costs**: 10, 100, 1000 currency (increasing)
- **Max Workers**: 2 initially (upgradeable)
- **Consumption**: 1 hot dog per second per worker
- **Assignments**: Kitchen (auto-clicker) or Office (auto-buyer)

### 🎮 UI/UX:
- **Office Button**: New main menu button
- **Navigation**: Arrow button on main screen
- **Theme**: Normal/plain (gets cooler later)
- **Discovery**: Exclamation mark on upgrade store
- **Help**: Info icon with explanation modals

### 🔧 Technical Requirements:
- **Event Log System**: Needs implementation
- **Worker Manager**: New autoload for worker management
- **Station System**: Foundation for future stations
- **Save Integration**: Track office, workers, assignments