# Vision System Test

extends Node3D

var vision_system: VisionSystem

func _ready():
    # Create a basic vision system for testing
    vision_system = VisionSystem.new()
    add_child(vision_system)
    
    # Set up a basic camera
    var camera = Camera3D.new()
    add_child(camera)
    camera.transform.origin = Vector3(0, 2, 0)
    
    # Create test objects
    for i in range(3):
        var test_obj = CSGBox3D.new()
        test_obj.name = "TestObject" + str(i)
        test_obj.use_collision = true
        test_obj.transform.origin = Vector3(i * 2 - 2, 0, -5)
        add_child(test_obj)
    
    # Test vision system
    await get_tree().process_frame
    vision_system.update_vision()
    
    print("Vision system test complete")
    print("Objects detected: ", vision_system.get_detected_objects().size())
    
    # Clean up
    queue_free()