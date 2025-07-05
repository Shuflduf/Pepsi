# Vision System Documentation

## Overview
The Vision System is a field-of-view (FOV) detection system that allows the player to "see" what objects are within their line of sight. It uses raycasting to detect objects in a cone-shaped area in front of the player's camera.

## What Can You See?
The vision system answers the question "what can you see" by:
- Detecting objects within the player's field of view
- Calculating distances to detected objects
- Providing visual feedback through debug visualization
- Tracking when objects enter or leave the field of view

## Features

### Core Functionality
- **Field of View Detection**: Uses a cone-shaped detection area with configurable angle
- **Distance Calculation**: Measures distance to detected objects
- **Real-time Updates**: Continuously scans for objects at configurable intervals
- **Object Tracking**: Emits signals when objects are detected or lost

### Visual Debug System
- **FOV Cone Visualization**: Shows the field of view as colored lines
- **Ray Visualization**: Displays individual detection rays (green for hits, red for misses)
- **Object Highlighting**: Detected objects are highlighted with yellow spheres
- **Distance Display**: Shows object names and distances in 3D space
- **Status Information**: Real-time debug UI showing system status

### Interactive Controls
- **V Key**: Toggle vision debug visualization on/off
- **[ ] Keys**: Adjust field of view angle (10° to 180°)
- **- = Keys**: Adjust detection range (5m to 50m)

## Configuration Parameters

### VisionSystem Class
- `fov_angle`: Field of view angle in degrees (default: 60°)
- `max_range`: Maximum detection range in meters (default: 20m)
- `ray_count`: Number of rays cast for detection (default: 16)
- `update_frequency`: How often to update vision in seconds (default: 0.1s)
- `show_debug_visualization`: Whether to show debug visuals (default: true)

## Usage

### Basic Setup
```gdscript
# In your player script
var vision_system: VisionSystem

func _ready():
    vision_system = VisionSystem.new()
    add_child(vision_system)
    
    # Connect to vision events
    vision_system.object_detected.connect(_on_object_detected)
    vision_system.object_lost.connect(_on_object_lost)

func _on_object_detected(object: Node3D, distance: float):
    print("Detected: ", object.name, " at ", distance, "m")

func _on_object_lost(object: Node3D):
    print("Lost: ", object.name)
```

### Getting Detected Objects
```gdscript
var detected_objects = vision_system.get_detected_objects()
for obj in detected_objects:
    print("Can see: ", obj.name)
```

### Checking Object Visibility
```gdscript
if vision_system.is_object_visible(some_object):
    print("Object is visible!")
```

## Technical Details

### Ray Casting
The system casts multiple rays in a cone pattern from the camera position:
- Rays are distributed evenly across the field of view angle
- Each ray extends to the maximum range
- Collision detection excludes the player object
- Hit results are used to determine visible objects

### Performance Considerations
- Update frequency can be adjusted to balance performance vs. responsiveness
- Number of rays affects accuracy vs. performance
- Debug visualization can be disabled in production

### Debug Visualization
The debug system uses the DebugDraw3D addon to display:
- FOV cone outline in cyan
- Detection rays in green (hit) or red (miss)
- Object highlights in yellow
- Distance text in white
- System status in the UI

## Example Use Cases
- Enemy AI vision detection
- Player awareness systems
- Stealth gameplay mechanics
- Environmental interaction detection
- Security camera simulation
- Line-of-sight checking for gameplay

## Integration with Pepsi Game
In the Pepsi game, the vision system is integrated into the player character to show what objects are visible in their field of view. This helps players understand their spatial awareness and can be used for gameplay mechanics like stealth or tactical awareness.

The system works alongside the existing weapon states (Melee, Ranged, Aiming) and can be toggled on/off for debugging purposes.