# WeenieWorld - Idle Game

A simple idle game built in Godot 4.4 with responsive design for both desktop and mobile platforms.

## Project Status

**Phase 1: Core Foundation** - ✅ **COMPLETED**

- ✅ Main menu with New Game, Continue, Options, and Quit buttons
- ✅ Basic save system with auto-save functionality
- ✅ Scene navigation between main menu and game
- ✅ Responsive design configuration
- ✅ Git repository setup with comprehensive .gitignore

## Features Implemented

### Main Menu
- **New Game**: Starts fresh game, clears save data
- **Continue**: Loads existing save data (if available)
- **Options**: Placeholder for future settings menu
- **Quit**: Exits application

### Save System
- Automatic save every 30 seconds
- Manual save when leaving game scene
- JSON-based save file format
- Save data includes currency, click values, and game statistics

### Game Scene (Placeholder)
- Simple "Hello World" display
- Shows current game data (currency, click value)
- Back button to return to main menu
- Escape key support for navigation

## How to Run

### Prerequisites
- Godot 4.4 or later
- Git (for version control)

### Setup
1. Clone or download this repository
2. Open Godot 4.4
3. Click "Import" and select the `project.godot` file
4. Click "Import & Edit"

### Running the Game
1. In Godot, press F5 or click the "Play" button
2. The main menu will load automatically
3. Test the following functionality:
   - Click "New Game" to start a fresh game
   - Click "Continue" to load existing save (if available)
   - Navigate to the game scene and back
   - Use Escape key to return to menu from game scene

## Project Structure

```
weenieworld/
├── scenes/
│   ├── main_menu/          # Main menu scene and script
│   ├── game/              # Game scene and script
│   ├── ui/                # Future UI scenes (upgrades, stats, settings)
│   └── shared/            # Shared scene components
├── scripts/
│   ├── autoload/          # Global scripts (GameManager, SaveSystem)
│   └── components/        # Reusable component scripts
├── assets/
│   ├── animations/        # Background and foreground animations
│   ├── ui/               # UI assets and wireframes
│   └── sounds/           # Audio files
├── GAME_PLAN.md          # Complete game development plan
├── PHASE_1_DETAILED.md   # Detailed Phase 1 implementation
└── README.md             # This file
```

## Testing Checklist

### Main Menu Functionality
- [ ] Main menu loads correctly
- [ ] "New Game" button starts fresh game
- [ ] "Continue" button loads saved game (if exists)
- [ ] "Continue" button is disabled when no save exists
- [ ] "Options" button shows placeholder message
- [ ] "Quit" button exits application

### Save System
- [ ] New game creates fresh save data
- [ ] Continue loads existing save data
- [ ] Auto-save works (check save file after 30 seconds)
- [ ] Manual save works when leaving game scene
- [ ] Save file is created in user data directory

### Navigation
- [ ] Scene transitions work smoothly
- [ ] Back button returns to main menu
- [ ] Escape key returns to main menu
- [ ] Game data displays correctly in game scene

### Responsive Design
- [ ] UI scales properly on different window sizes
- [ ] Elements remain properly positioned
- [ ] Text remains readable

## Development Notes

### Wireframe Design
- All UI elements are currently simple wireframes
- Colors: Dark backgrounds with white text
- Simple rectangles and labels for buttons
- Easy to replace with final art assets

### Save File Location
- Windows: `%APPDATA%/Godot/app_userdata/WeenieWorld/`
- Save file: `weenieworld_save.json`

### Next Steps (Phase 2)
- Implement currency system
- Add click mechanics
- Create upgrade system
- Add basic animations

## Troubleshooting

### Common Issues
1. **Script errors**: Make sure all autoload scripts are properly configured in project settings
2. **Save file issues**: Check user data directory permissions
3. **Scene loading errors**: Verify scene file paths in project settings

### Debug Information
- Check the output panel in Godot for debug messages
- Save system logs operations to console
- Game data is displayed in the game scene

## Contributing

This is a personal project, but feedback and suggestions are welcome!

## License

This project is for educational and personal use. 