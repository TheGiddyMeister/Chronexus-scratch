hp = 1; // Low HP for testing
damage = 10; // Damage to player on contact
move_speed = 2; // Patrol speed
move_dir = 1; // 1 = right, -1 = left
patrol_distance = 100; // Distance before turning
start_x = x; // Initial position
vspeed = 0; // Vertical speed
hspeed = move_speed * move_dir; // Horizontal speed
gravity = 0.5; // Match player’s gravity
hit_flash = 0; // Flash when hit
sprite_index = s_Enemy; // Ensure this sprite exists (e.g., 32x32)
image_speed = 1;
show_debug_message("o_Enemy created at (" + string(x) + ", " + string(y) + ") with HP = " + string(hp));