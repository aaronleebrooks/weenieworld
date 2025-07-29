# Development Workflows for Alien Hot Dog Food Truck

This document provides standardized workflows for agents working on this Godot project. Follow these patterns to maintain code quality and project consistency.

## 🎯 Project Overview

- **Engine**: Godot 4.4+ 
- **Language**: GDScript with strict typing encouraged
- **Architecture**: Autoload managers + scene-specific scripts
- **Testing**: GdUnit4 for unit/integration tests
- **CI/CD**: GitHub Actions with automated quality checks

## 📁 Project Structure

```
├── scripts/
│   ├── autoload/          # Global managers (HotDogManager, SaveSystem, etc.)
│   ├── scenes/           # Scene-specific scripts
│   │   ├── ui/          # UI component scripts
│   │   ├── game/        # Main game logic scripts
│   │   └── main_menu/   # Menu system scripts
│   ├── components/      # Reusable component scripts
│   └── resources/       # Enums, data structures
├── scenes/              # .tscn files ONLY (no .gd files)
├── tests/
│   ├── unit/           # Unit tests for individual classes
│   └── integration/    # Integration tests for system interactions
├── addons/gdUnit4/     # Testing framework
└── .github/workflows/  # CI/CD automation
```

## 🔄 Standard Development Workflow

### **1. Branch Management**
```bash
# Always work on feature branches
git checkout -b feature/your-feature-name
# OR for refactoring
git checkout -b refactor/improvement-description
```

### **2. Code Development Cycle**

#### **Before Making Changes**:
1. **Understand the System**: Use `codebase_search` to understand existing patterns
2. **Check Dependencies**: Identify which autoloads and systems you'll interact with
3. **Plan Testing**: Consider what tests you'll need to add/update

#### **During Development**:
1. **Follow GDScript Conventions**:
   ```gdscript
   # Class structure order:
   class_name YourClass
   extends Node
   
   # Constants first
   const DEBUG_MODE: bool = false
   const MAX_ITEMS: int = 100
   
   # Signals second  
   signal item_changed(new_value: int)
   
   # Variables third
   @export var initial_value: int = 0
   @onready var ui_element: Control = get_node("UIElement")
   
   # Functions last
   func _ready() -> void:
       pass
   ```

2. **Use Type Hints Everywhere**:
   ```gdscript
   func process_currency(amount: int) -> bool:
       var success: bool = HotDogManager.spend_currency(amount)
       return success
   ```

3. **Safe Node References**:
   ```gdscript
   # Always use get_node_or_null for critical dependencies
   var manager: Node = get_node_or_null("/root/HotDogManager")
   if not manager:
       push_error("HotDogManager not found - check autoload configuration")
       return
   ```

4. **Debug Control**:
   ```gdscript
   const DEBUG_MODE: bool = false
   
   func _log_debug(message: String) -> void:
       if DEBUG_MODE:
           print("DebugTag: ", message)
   ```

### **3. Testing Requirements**

#### **After Every Code Change**:
```bash
# 1. Format code
gdformat path/to/your/file.gd

# 2. Run linting  
gdlint path/to/your/file.gd

# 3. Run relevant tests
# For autoload changes:
godot --headless --script addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/unit/ -c --ignoreHeadlessMode

# For specific test file:
godot --headless --script addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/unit/test_your_component.gd -c --ignoreHeadlessMode
```

#### **Test Patterns to Follow**:
```gdscript
# tests/unit/test_your_component.gd
class_name TestYourComponent
extends GdUnitTestSuite

var component: YourComponent

func before() -> void:
    # Setup - prefer autoload access when available
    component = get_node_or_null("/root/YourComponent")
    if not component:
        component = YourComponent.new()
        add_child(component)

func test_basic_functionality() -> void:
    """Test core feature works correctly"""
    var result: bool = component.do_something(5)
    assert_bool(result).is_true()

func test_signal_emission() -> void:
    """Test signals are emitted correctly"""
    component.trigger_action()
    await assert_signal(component, "action_completed").is_emitted()
```

### **4. Commit Strategy**

#### **Commit After Each Logical Unit**:
```bash
# Small, focused commits
git add specific/files/changed.gd
git commit -m "feat: Add currency validation to HotDogManager

- Add input validation for spend_currency()  
- Add error handling for negative amounts
- Update related unit tests"

git push origin your-branch-name
```

#### **Commit Message Format**:
```
type: Brief description (50 chars max)

- Bullet point of change 1
- Bullet point of change 2  
- Reference to tests added/updated

[Optional: Addresses issue #123]
```

**Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`

### **5. CI/CD Monitoring**

#### **After Every Push**:
1. **Check GitHub Actions**: Monitor all CI jobs immediately
2. **Fix Failures Promptly**: Don't let CI stay broken
3. **Common Failure Patterns**:
   - **Formatting**: Run `gdformat --check .` locally first  
   - **Linting**: Run `gdlint .` locally first
   - **Tests**: Ensure tests pass locally before pushing
   - **Missing Files**: Check all references are correct

#### **CI Job Descriptions**:
- **code-quality**: Formatting (`gdformat --check`) and linting (`gdlint`)
- **testing**: GdUnit4 test execution in headless mode
- **security**: Secret scanning and dependency validation  
- **build-check**: Godot project validation and export testing
- **documentation**: Required documentation presence

## 🧪 Testing Guidelines

### **When to Add Tests**:
- **New Autoload Managers**: Always add comprehensive unit tests
- **Core Game Logic**: Production, sales, upgrades, save/load
- **UI Interactions**: User input validation, state management
- **Bug Fixes**: Add regression tests for fixed issues

### **Test Organization**:
```
tests/
├── unit/
│   ├── test_hot_dog_manager.gd      # Core production/sales logic
│   ├── test_save_system.gd          # Save/load functionality  
│   ├── test_upgrade_manager.gd      # Upgrade logic
│   └── test_customer_manager.gd     # Customer behavior
└── integration/
    ├── test_manager_interactions.gd  # Cross-manager communication
    └── test_game_flow.gd            # Complete gameplay scenarios
```

### **Test Coverage Priority**:
1. **Critical Path**: Save/load, currency, production
2. **User Features**: Upgrades, customer purchases, clicking
3. **Edge Cases**: Boundary conditions, error states
4. **Performance**: No tests needed unless specific performance requirements

## 🔧 Common Patterns

### **Autoload Communication**:
```gdscript
# Signal-based communication (preferred)
HotDogManager.hot_dogs_produced.connect(_on_hot_dogs_produced)

# Direct method calls (when needed)
var success: bool = UpgradeManager.purchase_upgrade("faster_production")
```

### **Error Handling**:
```gdscript
func safe_operation() -> bool:
    if not validate_prerequisites():
        push_error("Prerequisites not met for operation")
        return false
    
    var result: bool = perform_operation()
    if not result:
        push_warning("Operation completed with warnings")
    
    return result
```

### **Resource Management**:
```gdscript
# Object pooling for frequently created/destroyed objects
# Example: FloatingTextManager uses pooling for floating text instances

# Proper cleanup in _exit_tree()
func _exit_tree() -> void:
    if timer and timer.is_valid():
        timer.queue_free()
```

## 🚨 Critical Patterns to Avoid

### **❌ Don't Do This**:
```gdscript
# Magic numbers
timer.wait_time = 2.5

# No error handling
var node = get_node("Path/To/Node")

# Untyped variables  
var data = some_function()

# Debug prints without controls
print("Debug message")
```

### **✅ Do This Instead**:
```gdscript
# Named constants
const CUSTOMER_PURCHASE_INTERVAL: float = 2.5
timer.wait_time = CUSTOMER_PURCHASE_INTERVAL

# Safe node access
var node: Node = get_node_or_null("Path/To/Node")
if not node:
    push_error("Required node not found")
    return

# Typed variables
var data: Dictionary = some_function()

# Controlled debug output
const DEBUG_MODE: bool = false
if DEBUG_MODE:
    print("Debug message")
```

## 📋 Checklist for Each Task

### **Before Starting**:
- [ ] Branch created from latest main
- [ ] Understand existing code patterns via `codebase_search`
- [ ] Identify test requirements

### **During Development**:
- [ ] Follow GDScript style conventions
- [ ] Add comprehensive type hints
- [ ] Use safe node references (`get_node_or_null`)
- [ ] Add debug controls (`DEBUG_MODE` flags)
- [ ] Update/add relevant tests

### **Before Committing**:
- [ ] `gdformat` applied to all changed files
- [ ] `gdlint` passes with no errors
- [ ] Unit tests pass locally (when possible)
- [ ] Manual testing in Godot editor completed
- [ ] Commit message follows format standards

### **After Pushing**:
- [ ] Monitor CI/CD pipeline
- [ ] Fix any CI failures immediately  
- [ ] Verify all automated checks pass
- [ ] Update documentation if needed

## 🔗 Useful Commands Reference

```bash
# Code Quality
gdformat .                          # Format all GDScript files
gdformat --check .                  # Check formatting without changes
gdlint .                           # Lint all GDScript files
gdlint path/to/specific/file.gd    # Lint specific file

# Testing  
godot --headless --script addons/gdUnit4/bin/GdUnitCmdTool.gd -a tests/unit/ -c --ignoreHeadlessMode

# Git Workflow
git checkout -b feature/branch-name
git add .
git commit -m "type: description"
git push origin branch-name

# Project Validation
godot --headless --quit             # Basic project validation
```

## 📞 Getting Help

### **Common Issues**:
- **Autoload not found**: Check `project.godot` autoload configuration
- **Scene references broken**: Verify `.tscn` files point to correct script paths
- **Tests failing in CI but not locally**: Environment differences - trust CI results
- **Linting errors**: Follow patterns in existing codebase

### **Key Project Files to Reference**:
- **Architecture**: `scripts/autoload/` for core patterns
- **Testing Examples**: `tests/unit/test_hot_dog_manager.gd`
- **UI Patterns**: `scripts/scenes/game/Game.gd`
- **Configuration**: `.gdlintrc`, `project.godot`

---

**Last Updated**: During refactor/code-quality phase
**Next Review**: When major architectural changes are planned