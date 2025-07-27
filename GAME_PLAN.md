# WeenieWorld - Idle Game Development Plan

## Project Overview
WeenieWorld is a simple idle game built in Godot 4.4 with responsive design for both desktop and mobile platforms. The game features a click-based currency system with upgrades and a persistent save system.

## Core Gameplay Mechanics

### Currency System
- **Primary Currency**: Main game currency earned through clicking
- **Click Mechanics**: 
  - Single click = +1 currency
  - Hold click = +1 currency every 1 second (auto-clicker)
- **Upgradeable Values**:
  - Click value multiplier (how much currency per click)
  - Auto-clicker speed (how fast currency accrues when holding)

### Progression System
- Currency can be spent on upgrades
- Upgrades increase earning potential
- Persistent save system to maintain progress

## Technical Architecture

### Project Structure
```
weenieworld/
├── scenes/
│   ├── main_menu/
│   │   ├── MainMenu.tscn
│   │   └── MainMenu.gd
│   ├── game/
│   │   ├── Game.tscn
│   │   └── Game.gd
│   ├── ui/
│   │   ├── upgrades/
│   │   │   ├── UpgradesMenu.tscn
│   │   │   └── UpgradesMenu.gd
│   │   ├── stats/
│   │   │   ├── StatsMenu.tscn
│   │   │   └── StatsMenu.gd
│   │   └── settings/
│   │       ├── SettingsMenu.tscn
│   │       └── SettingsMenu.gd
│   └── shared/
│       ├── SaveSystem.gd
│       └── GameData.gd
├── assets/
│   ├── animations/
│   │   ├── background/
│   │   └── foreground/
│   ├── ui/
│   │   └── wireframe/
│   └── sounds/
└── scripts/
    ├── autoload/
    │   ├── GameManager.gd
    │   └── AudioManager.gd
    └── components/
        ├── ClickableButton.gd
        └── AnimatedBackground.gd
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

#### Game Scene
```
Game (Control)
├── BackgroundAnimation (AnimatedSprite2D)
├── ForegroundAnimation (AnimatedSprite2D)
├── ClickArea (TextureButton)
├── UIContainer (Control)
│   ├── CurrencyDisplay (Label)
│   ├── TopButtons (HBoxContainer)
│   │   ├── UpgradesButton (Button)
│   │   ├── StatsButton (Button)
│   │   └── SettingsButton (Button)
│   └── BottomUI (Control)
│       └── WorkersAndCustomers (AnimatedSprite2D)
└── MenuOverlays
    ├── UpgradesMenu (Control)
    ├── StatsMenu (Control)
    └── SettingsMenu (Control)
```

## UI/UX Design

### Wireframe Elements (Temporary)
- **Buttons**: Simple rectangles with text labels
- **Backgrounds**: Solid color rectangles
- **Animations**: Placeholder colored rectangles that move/scale
- **Icons**: Text labels or simple geometric shapes

### Responsive Design
- **Desktop**: 1920x1080 (16:9 aspect ratio)
- **Mobile Landscape**: 1920x1080 scaled down
- **Mobile Portrait**: 1080x1920 (9:16 aspect ratio)
- **Responsive Breakpoints**:
  - Desktop: > 1200px width
  - Tablet: 768px - 1200px width
  - Mobile: < 768px width

### Layout Adaptation
- **Desktop**: Full UI visible, side-by-side elements
- **Mobile Landscape**: Condensed UI, stacked elements
- **Mobile Portrait**: Vertical layout, larger touch targets

## Game Features

### Main Menu
- **New Game**: Starts fresh game, clears save data
- **Continue**: Loads existing save data
- **Options**: Opens settings menu
- **Quit**: Exits application

### Main Game Screen
- **Background Animation**: Looping animated background
- **Foreground Animation**: Workers and customers at bottom
- **Click Button**: Large, prominent button for currency earning
- **Currency Display**: Shows current currency amount
- **UI Buttons**: Upgrades, Stats, Settings

### Upgrades Menu
- **Click Value Upgrade**: Increases currency per click
- **Auto-Clicker Speed Upgrade**: Increases hold-click speed
- **Cost Display**: Shows upgrade costs
- **Back Button**: Returns to main game

### Stats Menu
- **Total Currency Earned**: Lifetime earnings
- **Total Clicks**: Click count
- **Play Time**: Session and total time
- **Upgrades Purchased**: Upgrade history
- **Back Button**: Returns to main game

### Settings Menu
- **Audio Volume**: Master, SFX, Music sliders
- **Graphics Quality**: Low/Medium/High options
- **Save Data**: Export/Import save data
- **Reset Game**: Clear all progress
- **Back Button**: Returns to main game

## Data Management

### Save System
- **Save Data Structure**:
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
- **Auto-Save**: Every 30 seconds
- **Manual Save**: When leaving game
- **Save Location**: User data directory

### Game Data
- **Upgrade Definitions**: Cost, effect, max level
- **Achievement System**: Milestone tracking
- **Statistics Tracking**: Real-time data collection

## Animation System

### Background Animation
- **Looping Animation**: Seamless background movement
- **Parallax Effect**: Multiple layers for depth
- **Performance Optimized**: Efficient rendering

### Foreground Animation
- **Workers**: Animated characters at bottom
- **Customers**: Moving customer animations
- **Interactive Elements**: Respond to game events

## Audio System

### Sound Effects
- **Click Sound**: Button press feedback
- **Upgrade Sound**: Purchase confirmation
- **Menu Navigation**: UI interaction sounds
- **Achievement Sound**: Milestone reached

### Background Music
- **Main Menu**: Calm, welcoming music
- **Game Loop**: Engaging, loopable track
- **Volume Control**: Separate SFX and music controls

## Performance Considerations

### Optimization
- **Efficient Rendering**: Minimal draw calls
- **Memory Management**: Proper resource cleanup
- **Mobile Optimization**: Battery and performance friendly
- **Scalable UI**: Responsive without performance impact

### Platform Support
- **Desktop**: Windows, macOS, Linux
- **Mobile**: Android, iOS (future consideration)
- **Web**: HTML5 export capability

## Development Phases

### Phase 1: Core Foundation ✅ COMPLETED
**Status**: Successfully implemented and tested

**Completed Systems**:
1. **Project Structure**: Git repository, .gitignore, organized file structure
2. **Main Menu Scene**: New Game, Continue, Options, Quit with responsive sizing
3. **Save System**: JSON-based with autosave and manual saves (up to 3)
4. **Wireframe UI Elements**: Clean, minimalist design ready for future assets

**Key Achievements**:
- **Native Godot Event System**: Uses `viewport.size_changed` for real-time responsive updates
- **Percentage-Based Sizing**: Font sizes scale with viewport width (2.5% vw), button heights with viewport height (8% vh)
- **Multiple Save Support**: Autosave + 3 manual saves with timestamps
- **Save Management**: Delete saves with confirmation dialog
- **Mobile-Friendly**: Touch targets remain usable at all screen sizes
- **Debug Logging**: Comprehensive logging for responsive system troubleshooting

**Technical Implementation**:
- **Responsive System**: `get_viewport().size_changed.connect()` with percentage calculations
- **Save System**: `SaveSystem` autoload with JSON persistence
- **UI Scaling**: Dynamic font sizes (16px-64px) and button heights (40px-120px)
- **Scene Management**: `GameManager` autoload for global state

**Known Issues**:
1. **Button Height Scaling**: Maximum heights could be higher for better touch interaction
2. **Font Size Bounds**: May need adjustment for extreme screen sizes
3. **Container Sizing**: Some containers use fixed offsets instead of percentage-based sizing

**Files Created**:
- `scripts/autoload/GameManager.gd` - Global game state
- `scripts/autoload/SaveSystem.gd` - Save/load functionality
- `scripts/autoload/GameData.gd` - Data structures
- `scenes/main_menu/MainMenu.tscn/.gd` - Responsive main menu
- `scenes/ui/SaveSelectionMenu.tscn/.gd` - Save management UI
- `scenes/ui/ConfirmationDialog.tscn/.gd` - Confirmation dialogs
- `scenes/game/Game.tscn/.gd` - Placeholder game scene

### Phase 2: Game Mechanics ✅ IN PROGRESS
**Status**: Planning and implementation phase

**Core Systems**:
1. **Currency System**: Global currency management with persistence
2. **Click Mechanics**: Single-click and hold-to-click with progress bars
3. **Upgrade System**: Flexible 10-upgrade system with configurable scaling
4. **Animation System**: Wireframe animations synchronized with game timing
5. **Event Logging**: Configurable log system for player actions

**Key Features**:
- **Click Rate**: 0.1s single-click timing (upgradeable)
- **Idle Rate**: 0.3s hold-click timing (upgradeable)
- **Currency Per Click**: Starts at 1, increases with upgrades
- **Progress Bars**: Visual feedback for click timing
- **Wireframe Animations**: Two squares moving left-right during currency gain
- **Flexible Upgrades**: Linear, exponential, or curved cost scaling
- **Event Log**: Tracks upgrades, saves, and future random events

**Technical Approach**:
- Native Godot event system (`_input()`, `Timer`, `AnimationPlayer`)
- Resource-based upgrade configuration
- Signal-driven communication between systems
- Responsive UI with percentage-based sizing
- Comprehensive save/load integration

**Naming Conventions**:
- `currency_balance` (not "currency")
- `click_rate_seconds` and `idle_rate_seconds` (explicit units)
- `currency_per_click` (not "value")
- `upgrade_levels` (not "upgrades")
- `click_progress_timer` and `idle_progress_timer` (descriptive)

### Phase 3: UI and Polish
1. Create all menu scenes
2. Implement responsive design
3. Add sound effects
4. Polish animations

### Phase 4: Testing and Optimization
1. Cross-platform testing
2. Performance optimization
3. Bug fixes and refinement
4. User testing and feedback

## Technical Requirements

### Godot Version
- **Engine**: Godot 4.4
- **Rendering**: GL Compatibility mode
- **Scripting**: GDScript

### Dependencies
- **Built-in Godot Features**: No external dependencies required
- **Future Considerations**: May add plugins for analytics, ads, etc.

### Export Settings
- **Desktop**: Windows, macOS, Linux
- **Mobile**: Android (APK/AAB)
- **Web**: HTML5

## Future Enhancements

### Planned Features
- **Achievement System**: Milestone rewards
- **Offline Progress**: Background earning
- **Social Features**: Leaderboards, sharing
- **Customization**: Themes, skins
- **Events**: Special time-limited events

### Monetization (Future)
- **Ad Integration**: Rewarded ads for bonuses
- **In-App Purchases**: Premium currency, boosters
- **Premium Version**: Ad-free experience

## Development Guidelines

### Code Standards
- **Naming Convention**: snake_case for variables, PascalCase for classes
- **Documentation**: Inline comments for complex logic
- **Modular Design**: Reusable components and systems
- **Error Handling**: Graceful error management

### Asset Guidelines
- **Wireframe Phase**: Simple geometric shapes and colors
- **Future Assets**: Consistent art style and theme
- **Performance**: Optimized textures and animations
- **Accessibility**: High contrast, readable text

This plan provides a comprehensive roadmap for developing WeenieWorld as a successful idle game with responsive design and engaging gameplay mechanics. 