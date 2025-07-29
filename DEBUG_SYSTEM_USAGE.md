# Debug System Usage Guide

## Overview
The debug system has been successfully implemented to help test the Office Purchase and Worker Management systems. This allows you to manually add currency and hot dogs, plus perform quick actions to set up testing scenarios.

## Accessing the Debug Panel

### Method 1: Debug Button
- Click the **🔧 Debug** button in the top-left menu (expanded mode)
- Or click the **🔧** icon when the menu is collapsed

### Method 2: Keyboard Shortcut
- Press **F12** at any time during gameplay to toggle the debug panel

## Debug Panel Features

### Manual Resource Addition
1. **Add Currency**
   - Use the Currency input field to specify amount (1-999,999)
   - Click "Add Currency" to add the specified amount
   - Both current balance and total earned are updated

2. **Add Hot Dogs**
   - Use the Hot Dog input field to specify amount (1-999,999)
   - Click "Add Hot Dogs" to add the specified amount
   - Uses the existing production system for consistency

### Quick Actions for Testing

#### Quick Office Unlock
- **Purpose**: Instantly provides enough currency (600) to unlock and purchase the office
- **Requirements**: Office must not already be purchased
- **What it does**: 
  - Adds 100 currency to meet unlock threshold
  - Adds 500 currency for office purchase cost
  - Enables Buildings tab and office purchase

#### Quick Worker Setup
- **Purpose**: Provides resources needed for worker hiring and management
- **Requirements**: Office must be purchased first
- **What it does**:
  - Adds 20 currency for worker hiring costs
  - Adds 10 hot dogs for worker consumption
  - Enables immediate worker testing

## Testing Workflow

### Testing Office Purchase System
1. Start a new game or reset progress
2. Open debug panel (F12 or 🔧 button)
3. Click "Quick Office Unlock (600 currency)"
4. Check that Buildings tab unlocks in Upgrades menu
5. Navigate to Buildings tab and purchase office
6. Verify office purchase works and unlocks worker system

### Testing Worker Management System
1. Complete office purchase (see above)
2. Click "Quick Worker Setup (20 currency + 10 hot dogs)"
3. Navigate to Buildings tab in Upgrades menu
4. Scroll down to see Worker Management section
5. Test worker hiring (costs: 10, 100, 1000 currency)
6. Test worker assignment (Kitchen ↔ Office)
7. Observe rate calculations in main game display

## Event Logging
All debug actions are automatically logged to the event system:
- Debug events show in the event log with 🔧 icon
- Track what testing actions have been performed
- Helps identify which debug actions caused specific game states

## Production vs Development
- Debug system is controlled by `DEBUG_MODE` constant in `DebugPanel.gd`
- Currently set to `true` for development
- Set to `false` for production builds to hide debug features
- Debug panel will be completely hidden in production mode

## Input Validation
- Amount inputs are validated (must be positive, max 999,999)
- Error messages printed to console for invalid inputs
- Quick actions check prerequisites (e.g., office must exist for worker setup)
- Graceful handling of missing managers or systems

## Troubleshooting

### Debug Panel Not Appearing
- Check that `DEBUG_MODE = true` in `DebugPanel.gd`
- Verify F12 key or debug button functionality
- Check console for error messages

### Quick Actions Not Working
- Ensure prerequisite conditions are met
- Office unlock: Office must not already be purchased
- Worker setup: Office must be purchased first
- Check console output for specific error messages

### Event Log Not Showing Debug Events
- Verify EventLogManager is available
- Check that debug events use 🔧 icon in event log
- Debug events may be filtered by event type in UI

## Implementation Details
The debug system integrates seamlessly with existing game systems:
- Uses existing HotDogManager methods for consistency
- Connects to EventLogManager for logging
- Integrates with BuildingManager and WorkerManager
- Follows established UI patterns and conventions

## Next Steps for Testing
With the debug system in place, you can now effectively test:
1. Office purchase workflow and unlock conditions
2. Worker hiring with different cost tiers
3. Worker assignment and reassignment
4. Production rate calculations
5. Worker consumption and quota systems
6. Building and worker persistence in save/load

The debug system provides a solid foundation for testing all implemented Office Purchase and Worker Management features!