// o_Player Step Event

// Debug: Start of Step
show_debug_message("Step started: x = " + string(x) + ", y = " + string(y) + ", hspeed = " + string(hspeed) + ", vspeed = " + string(vspeed));

// Debug: Check for o_Solid instances in the room
var solid_count = instance_number(o_Solid);
show_debug_message("Number of o_Solid instances in room: " + string(solid_count));
if (solid_count == 0) {
    show_debug_message("WARNING: No o_Solid instances found in the room!");
}

// Initialize State (if not already done)
if (!variable_instance_exists(id, "state_initialized")) {
    state = scr_player_idle;
    state_initialized = true;
    show_debug_message("State initialized to scr_player_idle");
}

// Core Variables
var ground_check = place_meeting(x, y + 1, o_Solid);
on_ground = ground_check && vspeed >= 0;
show_debug_message("Ground check: on_ground = " + string(on_ground) + ", ground_check = " + string(ground_check) + ", vspeed = " + string(vspeed));

// Debug collision check for ground
if (ground_check) {
    show_debug_message("Ground collision detected at x = " + string(x) + ", y = " + string(y + 1));
} else {
    show_debug_message("No ground collision at x = " + string(x) + ", y = " + string(y + 1));
}

// Wall check
on_wall = place_meeting(x + 2 * sign(hspeed), y, o_Solid) || place_meeting(x - 2 * sign(hspeed), y, o_Solid);
show_debug_message("Wall check: on_wall = " + string(on_wall) + ", hspeed = " + string(hspeed));
if (place_meeting(x + 2 * sign(hspeed), y, o_Solid)) {
    show_debug_message("Wall detected on right at x = " + string(x + 2 * sign(hspeed)) + ", y = " + string(y));
}
if (place_meeting(x - 2 * sign(hspeed), y, o_Solid)) {
    show_debug_message("Wall detected on left at x = " + string(x - 2 * sign(hspeed)) + ", y = " + string(y));
}
if (on_ground) was_on_wall = false;
if (on_wall) was_on_wall = true;

// Apply Gravity (only if not on ground)
if (!on_ground) {
    vspeed += 0.15; // Gravity
    show_debug_message("Gravity applied: vspeed = " + string(vspeed));
} else {
    if (vspeed > 0) vspeed = 0; // Ensure vspeed is 0 when on ground
}

// Input Detection
move = 0;
if (keyboard_check(vk_right) || keyboard_check(ord("D"))) move = 1;
if (keyboard_check(vk_left) || keyboard_check(ord("A"))) move = -1;
jump_pressed = keyboard_check_pressed(vk_space);
jump_released = keyboard_check_released(vk_space);
climb_pressed = keyboard_check(ord("E"));

// Reset Game
if (keyboard_check_pressed(ord("R"))) {
    show_debug_message("Reset game triggered!");
    game_restart();
}

if (jump_pressed) jump_buffer = 6;
if (jump_buffer > 0) jump_buffer--;

// Define Other Variables Used in State Scripts
if (!variable_instance_exists(id, "stamina")) stamina = 100; // Ensure stamina is defined for scr_player_idle

// Update Facing Direction
if (move != 0) {
    facing = move;
} else if (hspeed != 0) {
    facing = sign(hspeed);
} else {
    facing = facing; // Retain last direction if no movement
}

// Movement and Collision
hspeed = move * 4; // Simplified movement speed
hspeed = clamp(hspeed, -4, 4); // Cap horizontal speed
vspeed = clamp(vspeed, -10, 10); // Cap vertical speed

// Horizontal Movement
if (hspeed != 0) {
    var sign_h = sign(hspeed);
    var steps = abs(hspeed);
    repeat (steps) {
        var check_x = x + sign_h;
        var will_collide = place_meeting(check_x, y, o_Solid);
        show_debug_message("Checking horizontal collision at x = " + string(check_x) + ", y = " + string(y) + ": " + (will_collide ? "Collision detected" : "No collision"));
        if (!will_collide) {
            x += sign_h;
            show_debug_message("Moving horizontally: x = " + string(x));
        } else {
            // Find the nearest o_Solid instance to confirm collision
            var nearest_solid = instance_nearest(check_x, y, o_Solid);
            if (nearest_solid != noone) {
                show_debug_message("Nearest o_Solid at x = " + string(nearest_solid.x) + ", y = " + string(nearest_solid.y));
            } else {
                show_debug_message("No o_Solid instance found near collision point!");
            }
            hspeed = 0;
            show_debug_message("Wall collision detected at x = " + string(check_x) + ", stopping horizontal movement");
            break;
        }
    }
}
show_debug_message("Horizontal move completed: x = " + string(x) + ", hspeed = " + string(hspeed));

// Vertical Movement
if (vspeed != 0) {
    var sign_v = sign(vspeed);
    var steps = abs(vspeed);
    repeat (steps) {
        var check_y = y + sign_v;
        var will_collide = place_meeting(x, check_y, o_Solid);
        show_debug_message("Checking vertical collision at x = " + string(x) + ", y = " + string(check_y) + ": " + (will_collide ? "Collision detected" : "No collision"));
        if (!will_collide) {
            y += sign_v;
            show_debug_message("Moving vertically: y = " + string(y));
        } else {
            // Ceiling collision (moving up)
            if (sign_v < 0) {
                while (place_meeting(x, y, o_Solid)) {
                    y += 1; // Push down out of ceiling
                    show_debug_message("Ceiling collision detected, pushing down: y = " + string(y));
                }
                vspeed = 0;
                show_debug_message("Hit ceiling at y = " + string(y) + ", vspeed set to 0");
            }
            // Floor collision (moving down)
            else if (sign_v > 0) {
                while (place_meeting(x, y, o_Solid)) {
                    y -= 1; // Push up out of floor
                    show_debug_message("Floor collision detected, pushing up: y = " + string(y));
                }
                vspeed = 0;
                on_ground = true;
                show_debug_message("Landed on ground at y = " + string(y));
            }
            break;
        }
    }
}
show_debug_message("Vertical move completed: y = " + string(y) + ", vspeed = " + string(vspeed));

// Final Ground Stabilization (Ensure player doesn't fall through)
if (vspeed >= 0 && !place_meeting(x, y + 1, o_Solid)) {
    var ground_iterations = 0;
    while (!place_meeting(x, y + 1, o_Solid) && y < room_height && ground_iterations < 100) {
        y += 1;
        ground_iterations++;
        show_debug_message("Ground stabilization loop: y = " + string(y));
    }
    if (place_meeting(x, y + 1, o_Solid)) {
        on_ground = true;
        vspeed = 0;
        y = floor(y); // Snap to integer to avoid floating-point issues
        show_debug_message("Final ground stabilization at y = " + string(y));
    } else if (y >= room_height - sprite_height * image_yscale) {
        y = room_height - sprite_height * image_yscale; // Clamp to room bottom
        on_ground = true;
        vspeed = 0;
        show_debug_message("Clamped to room bottom at y = " + string(y));
    }
}

// Jump Buffer
if (jump_buffer > 0 && on_ground && variable_instance_exists(id, "state") && state != scr_player_attacking && state != scr_player_rolling) {
    state = scr_player_jumping;
    vspeed = -8; // Jump strength
    on_ground = false; // Force on_ground to false to allow jump
    jump_buffer = 0;
    show_debug_message("Buffered jump triggered! vspeed = " + string(vspeed));
}

// Execute State (After movement and collision)
show_debug_message("Executing state: " + string(state));
if (variable_instance_exists(id, "state") && script_exists(state)) {
    script_execute(state);
} else {
    show_debug_message("State script " + string(state) + " does not exist, defaulting to idle");
    if (on_ground && move != 0) state = scr_player_running;
    else if (on_ground) state = scr_player_idle;
    else state = scr_player_jumping;
}
show_debug_message("State execution completed");

// Visual Effects
image_xscale = 1.6 * facing;
image_yscale = 1.6;
image_alpha = 1;

// Debug: End of Step
show_debug_message("Step ended: x = " + string(x) + ", y = " + string(y) + ", hspeed = " + string(hspeed) + ", vspeed = " + string(vspeed));