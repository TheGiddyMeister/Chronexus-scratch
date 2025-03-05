// --- Initialize State ---
on_ground = place_meeting(x, y + 1, o_Solid);
on_wall = place_meeting(x + 4, y, o_Solid) || place_meeting(x - 4, y, o_Solid);

// Track wall climbing history and reset aerial attack flag
if (is_wall_climbing) {
    was_on_wall = true;
} else if (on_ground) {
    was_on_wall = false; // Reset when landing
    has_attacked_in_air = false; // Reset aerial attack flag when landing
}

// --- Input Handling (Shared Across States) ---
move = 0;
if (keyboard_check(vk_right) || keyboard_check(ord("D")) || gamepad_axis_value(0, gp_axislh) > 0.5) move = 1;
if (keyboard_check(vk_left) || keyboard_check(ord("A")) || gamepad_axis_value(0, gp_axislh) < -0.5) move = -1;
if (is_wall_climbing) move = 0;

// Check if controller is being used (stick movement or attack button)
var lh_axis = gamepad_axis_value(0, gp_axislh);
var lv_axis = gamepad_axis_value(0, gp_axislv);
var rh_axis = gamepad_axis_value(0, gp_axisrh);
var rv_axis = gamepad_axis_value(0, gp_axisrv);
var stick_used = (abs(lh_axis) > controller_deadzone || abs(lv_axis) > controller_deadzone || abs(rh_axis) > controller_deadzone || abs(rv_axis) > controller_deadzone);
var button_used = gamepad_button_check_pressed(0, gp_face3);
using_controller = (stick_used || button_used);

// Shared input variables
var attack_pressed = (mouse_check_button_pressed(mb_left) || gamepad_button_check_pressed(0, gp_face3));
var jump_pressed = (keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1));
var roll_pressed = (keyboard_check_pressed(vk_shift) || gamepad_button_check_pressed(0, gp_face2));
var climb_pressed = (keyboard_check(ord("E")) || gamepad_button_check(0, gp_shoulderr));

// Debug input detection
if (jump_pressed) show_debug_message("Jump pressed");
if (attack_pressed) show_debug_message("Attack pressed");
if (roll_pressed) show_debug_message("Roll pressed: stamina = " + string(stamina));

// --- Restart Game (Shared) ---
if (keyboard_check_pressed(ord("R"))) {
    game_restart();
}

// --- State Machine ---
switch (current_state) {
    case "idle":
        // Physics
        if (on_ground) {
            vspeed = 0;
            if (move == 0) {
                hspeed *= global.friction;
            }
        }
        
        // Transitions
        if (attack_pressed && !isAttacking && attackCooldown <= 0 && (!has_attacked_in_air || on_ground)) {
            show_debug_message("Transition to attack from idle");
            current_state = "attack";
        } else if (roll_pressed && rollTimer <= 0 && stamina >= 10) {
            show_debug_message("Transition to roll from idle");
            current_state = "roll";
        } else if (climb_pressed && on_wall && stamina > 0) {
            show_debug_message("Transition to wall_climb from idle");
            current_state = "wall_climb";
        } else if (jump_pressed && (on_ground || coyote_timer > 0)) {
            show_debug_message("Transition to jump from idle");
            current_state = "jump";
        } else if (move != 0) {
            show_debug_message("Transition to run from idle");
            current_state = "run";
        } else if (!on_ground) {
            show_debug_message("Transition to jump from idle (not on ground)");
            current_state = "jump";
        }
        break;
        
    case "run":
        // Physics
        if (on_ground) {
            vspeed = 0;
            if (!wall_jump_locked) {
                if (move != 0) {
                    hspeed = approach(hspeed, move * global.max_speed, global.acceleration);
                } else {
                    hspeed *= global.friction;
                }
            }
        }
        
        // Transitions
        if (attack_pressed && !isAttacking && attackCooldown <= 0 && (!has_attacked_in_air || on_ground)) {
            show_debug_message("Transition to attack from run");
            current_state = "attack";
        } else if (roll_pressed && rollTimer <= 0 && stamina >= 10) {
            show_debug_message("Transition to roll from run");
            current_state = "roll";
        } else if (climb_pressed && on_wall && stamina > 0) {
            show_debug_message("Transition to wall_climb from run");
            current_state = "wall_climb";
        } else if (jump_pressed && (on_ground || coyote_timer > 0)) {
            show_debug_message("Transition to jump from run");
            current_state = "jump";
        } else if (move == 0) {
            show_debug_message("Transition to idle from run");
            current_state = "idle";
        } else if (!on_ground) {
            show_debug_message("Transition to jump from run (not on ground)");
            current_state = "jump";
        }
        break;
        
    case "jump":
        // Physics
        if (!on_ground && !wall_jump_locked) {
            vspeed = min(vspeed + global.gravity, 10);
        }
        
        // Allow movement in air
        if (!wall_jump_locked) {
            if (move != 0) {
                hspeed = approach(hspeed, move * global.max_speed, global.acceleration);
            } else {
                hspeed *= global.friction;
            }
        }
        
        // Update coyote timer
        if (!on_ground) {
            coyote_timer = max(coyote_timer - 1, 0);
        } else {
            coyote_timer = global.coyote_time;
        }
        
        // Transitions
        if (attack_pressed && !isAttacking && attackCooldown <= 0 && !has_attacked_in_air) {
            show_debug_message("Transition to attack from jump");
            current_state = "attack";
        } else if (roll_pressed && rollTimer <= 0 && stamina >= 10) {
            show_debug_message("Transition to roll from jump");
            current_state = "roll";
        } else if (climb_pressed && on_wall && stamina > 0) {
            show_debug_message("Transition to wall_climb from jump");
            current_state = "wall_climb";
        } else if (on_ground) {
            if (move != 0) {
                show_debug_message("Transition to run from jump");
                current_state = "run";
            } else {
                show_debug_message("Transition to idle from jump");
                current_state = "idle";
            }
        }
        break;
        
    case "attack":
        // Handle attack timer and cooldown
        if (attackTimer > 0) {
            attackTimer--;
            if (attackTimer <= 0) {
                isAttacking = false;
                hspeed *= attack_momentum_decay;
                if (!on_ground) {
                    vspeed *= attack_momentum_decay;
                }
            }
        }
        if (attackCooldown > 0) {
            attackCooldown--;
        }
        
        // Physics (allow movement during attack)
        if (!on_ground) {
            vspeed = min(vspeed + global.gravity, 10);
        }
        
        // Transitions
        if (!isAttacking) {
            if (isRolling) {
                show_debug_message("Transition to roll from attack");
                current_state = "roll";
            } else if (is_wall_climbing) {
                show_debug_message("Transition to wall_climb from attack");
                current_state = "wall_climb";
            } else if (!on_ground) {
                show_debug_message("Transition to jump from attack");
                current_state = "jump";
            } else if (move != 0) {
                show_debug_message("Transition to run from attack");
                current_state = "run";
            } else {
                show_debug_message("Transition to idle from attack");
                current_state = "idle";
            }
        }
        break;
        
    case "wall_climb":
        // Physics
        vspeed = 0;
        if (stamina > 0) {
            var is_moving_vertically = (keyboard_check(ord("W")) || keyboard_check(ord("S")) || gamepad_axis_value(0, gp_axislv) < -0.5 || gamepad_axis_value(0, gp_axislv) > 0.5);
            if (is_moving_vertically) {
                stamina -= stamina_drain_rate;
                if (keyboard_check(ord("W")) || gamepad_axis_value(0, gp_axislv) < -0.5) {
                    vspeed = -2.5;
                }
                if (keyboard_check(ord("S")) || gamepad_axis_value(0, gp_axislv) > 0.5) {
                    vspeed = 2.5;
                }
            } else {
                stamina -= stamina_drain_rate_wall_idle;
            }
        }
        
        // Transitions
        if (!climb_pressed || !on_wall || stamina <= 0) {
            is_wall_climbing = false;
            if (!on_ground) {
                show_debug_message("Transition to jump from wall_climb");
                current_state = "jump";
            } else if (move != 0) {
                show_debug_message("Transition to run from wall_climb");
                current_state = "run";
            } else {
                show_debug_message("Transition to idle from wall_climb");
                current_state = "idle";
            }
        } else if (attack_pressed && !isAttacking && attackCooldown <= 0 && (!has_attacked_in_air || on_ground)) {
            show_debug_message("Transition to attack from wall_climb");
            current_state = "attack";
            is_wall_climbing = false;
        } else if (roll_pressed && rollTimer <= 0 && stamina >= 10) {
            show_debug_message("Transition to roll from wall_climb");
            current_state = "roll";
            is_wall_climbing = false;
        } else if (jump_pressed) {
            show_debug_message("Jump pressed in wall_climb: transitioning to jump");
            vspeed = global.jump_speed;
            stamina = max(0, stamina - stamina_wall_jump_cost);
            hspeed = (place_meeting(x - 4, y, o_Solid)) ? 5 : -5;
            is_wall_climbing = false;
            wall_jump_locked = true;
            current_state = "jump";
        }
        break;
        
    case "roll":
        // Physics
        image_alpha = 0.5;
        rollTimer--;
        if (rollTimer <= 0 || place_meeting(x + rollDirection * 4, y, o_Solid)) {
            isRolling = false;
            rollTimer = 0;
            hspeed = 0;
            image_alpha = 1;
        }
        stamina -= stamina_drain_rate;
        if (stamina <= 0) {
            stamina = 0;
            isRolling = false;
        }
        
        // Transitions
        if (!isRolling) {
            if (attack_pressed && !isAttacking && attackCooldown <= 0 && (!has_attacked_in_air || on_ground)) {
                show_debug_message("Transition to attack from roll");
                current_state = "attack";
            } else if (climb_pressed && on_wall && stamina > 0) {
                show_debug_message("Transition to wall_climb from roll");
                current_state = "wall_climb";
            } else if (!on_ground) {
                show_debug_message("Transition to jump from roll");
                current_state = "jump";
            } else if (move != 0) {
                show_debug_message("Transition to run from roll");
                current_state = "run";
            } else {
                show_debug_message("Transition to idle from roll");
                current_state = "idle";
            }
        }
        break;
}

// --- Handle Attack Initiation (Shared Across States) ---
if (attack_pressed && !isAttacking && attackCooldown <= 0 && !isRolling && current_state != "attack" && (!has_attacked_in_air || on_ground)) {
    show_debug_message("Initiating attack: has_attacked_in_air = " + string(has_attacked_in_air));
    isAttacking = true;
    attackTimer = attack_duration;
    attackCooldown = attack_cooldown_duration;
    
    // Mark that an attack has occurred in the air
    if (!on_ground) {
        has_attacked_in_air = true;
    }
    
    // Determine attack direction
    var attackDir;
    if (using_controller) {
        var left_magnitude = sqrt(sqr(lh_axis) + sqr(lv_axis));
        var right_magnitude = sqrt(sqr(rh_axis) + sqr(rv_axis));
        
        if (left_magnitude > controller_deadzone || right_magnitude > controller_deadzone) {
            if (left_magnitude >= right_magnitude && left_magnitude > controller_deadzone) {
                attackDir = point_direction(0, 0, lh_axis, lv_axis);
            } else if (right_magnitude > controller_deadzone) {
                attackDir = point_direction(0, 0, rh_axis, rv_axis);
            }
        } else {
            if (move != 0) {
                attackDir = (move > 0) ? 0 : 180;
            } else if (hspeed != 0) {
                attackDir = (hspeed > 0) ? 0 : 180;
            } else {
                attackDir = 0;
            }
        }
    } else {
        attackDir = point_direction(x, y, mouse_x, mouse_y);
    }
    
    // Apply attack force
    var attackForce = on_ground ? attack_force_ground : attack_force_air;
    hspeed = lengthdir_x(attackForce, attackDir);
    vspeed = lengthdir_y(attackForce * 0.7, attackDir);
    
    // Create attack hitbox
    with (instance_create_layer(x + lengthdir_x(16, attackDir), y + lengthdir_y(16, attackDir), "Instances", o_AttackHitbox)) {
        direction = attackDir;
        owner = other;
    }
    
    current_state = "attack";
}

// --- Handle Jump Initiation (Shared Across States) ---
if (jump_pressed && (on_ground || coyote_timer > 0 || is_wall_climbing) && current_state != "jump") {
    show_debug_message("Initiating jump: on_ground = " + string(on_ground) + ", coyote_timer = " + string(coyote_timer));
    vspeed = global.jump_speed;
    if (is_wall_climbing) {
        stamina = max(0, stamina - stamina_wall_jump_cost);
        hspeed = (place_meeting(x - 4, y, o_Solid)) ? 5 : -5;
        is_wall_climbing = false;
        wall_jump_locked = true;
    }
    coyote_timer = 0;
    current_state = "jump";
}

// --- Handle Roll Initiation (Shared Across States) ---
if (roll_pressed && rollTimer <= 0 && stamina >= 10 && !isRolling && current_state != "roll") {
    show_debug_message("Initiating roll: stamina = " + string(stamina));
    isRolling = true;
    rollTimer = global.roll_duration;
    rollDirection = (move != 0) ? move : sign(hspeed);
    if (rollDirection == 0) rollDirection = 1;
    hspeed = rollDirection * (global.roll_speed * 7.0);
    stamina -= 10;
    current_state = "roll";
}

// --- Collision Handling (Shared Across States) ---
if (place_meeting(x + hspeed, y, o_Solid) && hspeed != 0) {
    while (!place_meeting(x + sign(hspeed), y, o_Solid) && abs(hspeed) > 0.1) {
        x += sign(hspeed);
    }
    hspeed = 0;
}
if (place_meeting(x, y + vspeed, o_Solid)) {
    while (!place_meeting(x, y + sign(vspeed), o_Solid) && abs(vspeed) > 0.1) {
        y += sign(vspeed);
    }
    vspeed = 0;
    on_ground = true;
}

// --- Stamina Regeneration (Shared Across States) ---
if (!isRolling) { // Allow regeneration unless rolling
    if (was_on_wall && !on_ground) {
        // Prevent regeneration after wall climbing until landing
        // Do nothing (stamina doesn’t regen in this state)
    } else {
        // Apply different regen rates based on ground state
        if (on_ground) {
            stamina = min(stamina + stamina_recover_rate, max_stamina);
        } else {
            stamina = min(stamina + stamina_recover_rate_air, max_stamina);
        }
    }
}