# Phase 3C: Laboratory System - Implementation Quickstart

## Overview 🔬
Build the Laboratory system using the proven foundation from Office & Worker implementation. This leverages existing building framework, worker management, and UI architecture for rapid development.

## Ready Foundation ✅

**Existing Systems That Support Laboratory:**
- ✅ `BuildingManager.gd` - Ready for Laboratory as second building
- ✅ `WorkerManager.gd` - Ready for Scientists as specialized workers
- ✅ Tab-based UI - Buildings tab ready for Laboratory options
- ✅ Rate calculation system - Ready for Research Points/second
- ✅ Save/load system - Ready for research data persistence
- ✅ Unit testing patterns - Ready for new feature testing

## Implementation Plan 🎯

### Step 1: Laboratory Building (1-2 hours)
**Goal**: Add Laboratory as purchasable building in BuildingManager

**Tasks**:
1. **Add Laboratory Definition** in `BuildingManager._create_default_buildings()`:
   ```gdscript
   var laboratory = BuildingDefinition.new()
   laboratory.building_id = "laboratory"
   laboratory.display_name = "Laboratory"
   laboratory.description = "Research facility. Unlock the ability to hire scientists."
   laboratory.base_cost = 2000
   laboratory.unlock_condition_type = BuildingDefinition.UnlockConditionType.BUILDINGS_OWNED
   laboratory.unlock_condition_value = 1  # Requires Office purchase
   laboratory.effects = [
       "Unlock scientist hiring system",
       "Research points generation", 
       "Access to research trees"
   ]
   ```

2. **Test Laboratory Purchase** - Verify it appears after Office purchase

### Step 2: Research Points System (2-3 hours)
**Goal**: Create new currency type for research points

**Tasks**:
1. **Create ResearchManager.gd autoload**:
   ```gdscript
   extends Node
   
   signal research_points_changed(new_amount: int)
   
   var research_points: int = 0
   var total_research_earned: int = 0
   
   func add_research_points(amount: int, reason: String):
       research_points += amount
       total_research_earned += amount
       emit_signal("research_points_changed", research_points)
   
   func spend_research_points(amount: int, reason: String) -> bool:
       if research_points >= amount:
           research_points -= amount
           emit_signal("research_points_changed", research_points)
           return true
       return false
   
   func get_research_points_per_second() -> float:
       # Calculate from scientist workers
       return 0.0  # Implement based on scientists
   ```

2. **Add to project.godot autoloads**
3. **Create ResearchDisplay.gd** similar to CurrencyDisplay

### Step 3: Scientist Workers (2-3 hours) 
**Goal**: Add Scientists as specialized worker type

**Tasks**:
1. **Extend WorkerDefinition.gd** with Scientist assignment:
   ```gdscript
   enum WorkerAssignment {
       KITCHEN,  # Auto-produce hot dogs
       OFFICE,   # Improve all worker efficiency  
       SCIENTIST # Generate research points
   }
   ```

2. **Update WorkerManager** to handle Scientists:
   - Add `_process_scientist_worker()` method
   - Scientists consume hot dogs, produce research points
   - Research rate: ~0.1 research points/second per scientist

3. **Update UpgradePanel** worker UI for Scientist assignment

### Step 4: Laboratory UI Integration (1-2 hours)
**Goal**: Add Laboratory management to Buildings tab

**Tasks**:
1. **Update UpgradePanel.gd** to show Laboratory purchase option
2. **Add Scientist hiring interface** after Laboratory purchase
3. **Integrate Research Points display** in main UI
4. **Test full Laboratory workflow**

### Step 5: Testing & Polish (1-2 hours)
**Goal**: Comprehensive testing and quality assurance

**Tasks**:
1. **Create test_research_manager.gd** unit tests
2. **Update test_worker_manager.gd** for Scientist workers
3. **Test save/load** with research data
4. **Verify CI passes** with all new features

## Expected Implementation Timeline ⏰

**Total Estimated Time**: 6-10 hours (1-2 development sessions)
**Complexity**: Medium (leveraging proven patterns)
**Risk Level**: Low (building on solid foundation)

**Comparison to Office System**: 
- Office & Worker: ~20-30 hours (new architecture)
- Laboratory: ~6-10 hours (leveraging existing patterns)
- **60% time reduction** due to foundation

## Success Criteria ✅

**Must Have**:
- [ ] Laboratory purchasable after Office (2000 currency cost)
- [ ] Scientists hireable with Research Point generation
- [ ] Research Points displayed with rate calculations
- [ ] All features integrated into existing Buildings tab
- [ ] Save/load works with research data
- [ ] Unit tests cover new functionality

**Nice to Have**:
- [ ] Scientist efficiency affected by office workers  
- [ ] Research point formatting (1.2K, 1.5M style)
- [ ] Laboratory upgrade options (capacity, efficiency)

## Key Implementation Notes 📝

**Leverage Existing Patterns**:
- Copy BuildingManager patterns for Laboratory purchase
- Copy WorkerManager patterns for Scientist workers
- Copy rate calculation patterns for Research Points/second
- Copy UI patterns from existing Buildings tab

**Avoid Over-Engineering**:
- Start with basic functionality
- Add complexity in later iterations
- Focus on integration with existing systems

**Testing First**:
- Write unit tests as you implement
- Test integration with existing features
- Verify save/load compatibility

## Ready to Begin! 🚀

The Office & Worker System provides a **rock-solid foundation** for Laboratory implementation. Most of the hard architectural work is done - now it's about extending proven patterns to add research capabilities.

**Next Command**: `git checkout -b phase-3c-laboratory-system` and start with Step 1!