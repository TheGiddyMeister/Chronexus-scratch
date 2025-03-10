// Initialize Variables
on_ground = place_meeting(x, y+1, o_Solid);
on_wall = place_meeting(x+4, y, o_Solid) || place_meeting(x-4, y, o_Solid);

// Track if the player was previously on a wall
if (is_wall_climbing) {
    was_on_wall = true;
} else if (on_ground) {
    was_on_wall = false;
    has_attacked_in_air = false;
}

// Restart Game on 'R' Press
if (input_mode == "keyboard" && keyboard_check_pressed(ord("R"))) {
    game_restart();
} else if (input_mode == "controller" && gamepad_button_check_pressed(0, gp_start)) {
    game_restart();
}

// Detect Input Mode
var kb_input = keyboard_check(vk_anykey) || mouse_check_button(mb_any);
var controller_input = false;
var lh_axis = gamepad_axis_value(0, gp_axislh);
var lv_axis = gamepad_axis_value(0, gp_axislv);
var rh_axis = gamepad_axis_value(0, gp_axisrh);
var rv_axis = gamepad_axis_value(0, gp_axisrv);
if (abs(lh_axis) > controller_deadzone || abs(lv_axis) > controller_deadzone ||
    abs(rh_axis) > controller_deadzone || abs(rv_axis) > controller_deadzone ||
    gamepad_button_check_pressed(0, gp_face1) || gamepad_button_check_pressed(0, gp_face2) ||
    gamepad_button_check_pressed(0, gp_face3) || gamepad_button_check(0, gp_shoulderr)) {
    controller_input = true;
}
if (kb_input && !controller_input) {
    input_mode = "keyboard";
} else if (controller_input && !kb_input) {
    input_mode = "controller";
}

// Apply Gravity
if (!on_ground && !is_wall_climbing && !wall_jump_locked) {
    vspeed = min(vspeed + global.gravity, 10);
}

// Handle Input Based on Input Mode
move = 0;
if (input_mode == "keyboard") {
    if (keyboard_check(vk_right) || keyboard_check(ord("D"))) move = 1;
    if (keyboard_check(vk_left) || keyboard_check(ord("A"))) move = -1;
} else if (input_mode == "controller") {
    var h_axis = gamepad_axis_value(0, gp_axislh);
    if (abs(h_axis) > controller_deadzone) {
        move = sign(h_axis);
    }
}
if (is_wall_climbing) move = 0;

// Apply Movement (Smoother Acceleration)
if (!wall_jump_locked && !isRolling && !isAttacking) {
    if (move != 0) {
        hspeed += (move * global.max_speed - hspeed) * 0.2;
    } else {
        hspeed *= global.friction;
    }
}

// Apply Friction
if (!isAttacking && on_ground) {
    vspeed = 0;
    hspeed *= global.friction;
    show_debug_message("Friction applied: hspeed = " + string(hspeed));
}

// Debug input detection
var attack_pressed = false;
var jump_pressed = false;
var jump_released = false;
var roll_pressed = false;
var switch_weapon = false;
var throw_weapon = false;
var climb_pressed = false;

if (input_mode == "keyboard") {
    attack_pressed = mouse_check_button_pressed(mb_left);
    jump_pressed = keyboard_check_pressed(vk_space);
    jump_released = keyboard_check_released(vk_space);
    roll_pressed = keyboard_check_pressed(vk_shift);
    switch_weapon = keyboard_check_pressed(ord("Q"));
    throw_weapon = keyboard_check_pressed(ord("T"));
    climb_pressed = keyboard_check(ord("E"));
} else if (input_mode == "controller") {
    attack_pressed = gamepad_button_check_pressed(0, gp_face3);
    jump_pressed = gamepad_button_check_pressed(0, gp_face1);
    jump_released = gamepad_button_check_released(0, gp_face1);
    roll_pressed = gamepad_button_check_pressed(0, gp_face2);
    switch_weapon = gamepad_button_check_pressed(0, gp_shoulderrb);
    throw_weapon = gamepad_button_check_pressed(0, gp_face4);
    climb_pressed = gamepad_button_check(0, gp_shoulderr);
}

// Switch Weapons
if (switch_weapon) {
    active_weapon_slot = (active_weapon_slot == 0) ? 1 : 0;
    show_debug_message("Switched to weapon slot: " + string(active_weapon_slot));
}

// Throw Active Weapon
if (throw_weapon && weapon_inventory[active_weapon_slot] != noone) {
    var weapon = weapon_inventory[active_weapon_slot];
    var throw_dir;
    if (input_mode == "keyboard") {
        throw_dir = point_direction(x, y, mouse_x, mouse_y);
    } else {
        var lh_axis = gamepad_axis_value(0, gp_axislh);
        var lv_axis = gamepad_axis_value(0, gp_axislv);
        if (abs(lh_axis) > controller_deadzone || abs(lv_axis) > controller_deadzone) {
            throw_dir = point_direction(0, 0, lh_axis, lv_axis);
        } else {
            throw_dir = (move != 0) ? (move > 0 ? 0 : 180) : (hspeed != 0 ? (hspeed > 0 ? 0 : 180) : 0);
        }
    }
    var thrown = instance_create_layer(x, y, "Instances", o_ThrownWeapon);
    with (thrown) {
        direction = throw_dir;
        speed = 10;
        damage = weapon.damage * 2;
        sprite_index = weapon.sprite;
    }
    weapon_inventory[active_weapon_slot] = noone;
    show_debug_message("Thrown weapon from slot: " + string(active_weapon_slot));
    audio_play_sound(snd_throw, 1, false);
}

// Melee Attack (Refined)
var attack_triggered = false;
var attackDir = 0;

if (attack_pressed) {
    attack_buffer = attack_buffer_max;
}
if (attack_buffer > 0) {
    attack_buffer--;
}

if (attack_buffer > 0 && ((input_mode == "keyboard" && mouse_check_button(mb_left)) || (input_mode == "controller" && gamepad_button_check(0, gp_face3)))) {
    if (!isAttacking && attackCooldown <= 0 && !isRolling && (!has_attacked_in_air || on_ground) && weapon_inventory[active_weapon_slot] != noone) {
        attack_triggered = true;
        var weapon = weapon_inventory[active_weapon_slot];
        show_debug_message("Attack triggered: type = " + weapon.type + ", range = " + string(weapon.range) + ", speed = " + string(weapon.speed));
        if (input_mode == "keyboard") {
            attackDir = point_direction(x, y, mouse_x, mouse_y);
            show_debug_message("Mouse attack: direction = " + string(attackDir));
        } else {
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
            show_debug_message("Controller attack: direction = " + string(attackDir));
        }
        attack_buffer = 0;
    }
}

if (attack_triggered) {
    isAttacking = true;
    var weapon = weapon_inventory[active_weapon_slot];
    attackTimer = 8;
    attackCooldown = 10;
    if (!on_ground) {
        has_attacked_in_air = true;
    }
    
    hspeed = lengthdir_x(16, attackDir);
    vspeed = lengthdir_y(16, attackDir);
    show_debug_message("Attack dash: hspeed = " + string(hspeed) + ", vspeed = " + string(vspeed));
    
    var target_layer = layer_exists("Instances") ? "Instances" : layer;
    var hitbox = instance_create_layer(x, y, target_layer, o_AttackHitbox);
    with (hitbox) {
        direction = attackDir;
        owner = other;
        damage = weapon.damage;
        lifetime = 8;
        x = other.x + lengthdir_x(weapon.range, attackDir);
        y = other.y + lengthdir_y(weapon.range, attackDir);
        image_angle = attackDir;
    }
    
    screen_shake_amount = 3;
    screen_shake_duration = 6;
    repeat(3) {
        instance_create_layer(x, y, target_layer, o_TrailEffect);
    }
    audio_play_sound(snd_attack, 1, false);
}

if (isAttacking) {
    attackTimer--;
    if (attackTimer <= 0) {
        isAttacking = false;
        hspeed *= 0.6;
        vspeed *= 0.6;
        show_debug_message("Attack ended: hspeed = " + string(hspeed) + ", vspeed = " + string(vspeed));
    }
}
if (attackCooldown > 0) {
    attackCooldown--;
}

// Wall Climbing
if (climb_pressed && on_wall && stamina > 0) {
    is_wall_climbing = true;
    vspeed = 0;
    var is_moving_vertically = false;
    if (input_mode == "keyboard") {
        is_moving_vertically = (keyboard_check(ord("W")) || keyboard_check(ord("S")));
    } else {
        is_moving_vertically = (gamepad_axis_value(0, gp_axislv) < -0.5 || gamepad_axis_value(0, gp_axislv) > 0.5);
    }
    if (is_moving_vertically) {
        stamina -= stamina_drain_rate;
        if ((input_mode == "keyboard" && keyboard_check(ord("W"))) || (input_mode == "controller" && gamepad_axis_value(0, gp_axislv) < -0.5)) {
            vspeed = -2.5;
        }
        if ((input_mode == "keyboard" && keyboard_check(ord("S"))) || (input_mode == "controller" && gamepad_axis_value(0, gp_axislv) > 0.5)) {
            vspeed = 2.5;
        }
    } else {
        stamina -= stamina_drain_rate_wall_idle;
        if (vspeed > 0) vspeed *= 0.95;
    }
} else {
    is_wall_climbing = false;
}

// Jumping
if (jump_pressed) {
    jump_buffer = 6;
}
if (jump_buffer > 0) {
    jump_buffer--;
    if (on_ground || coyote_timer > 0 || is_wall_climbing) {
        vspeed = global.jump_speed;
        if (is_wall_climbing) {
            vspeed = global.wall_jump_vspeed;
            hspeed = (place_meeting(x-4, y, o_Solid)) ? global.wall_jump_push : -global.wall_jump_push;
            stamina = max(0, stamina - stamina_wall_jump_cost);
        }
        coyote_timer = 0;
        is_wall_climbing = false;
        jump_buffer = 0;
        audio_play_sound(snd_jump, 1, false);
        instance_create_layer(x, y, "Instances", o_DustEffect);
    }
} else if (!on_ground) {
    coyote_timer = max(coyote_timer - 1, 0);
    if (jump_released && vspeed < global.jump_speed_min) {
        vspeed = global.jump_speed_min;
    }
} else {
    coyote_timer = global.coyote_time;
}

// Rolling
var roll_buffer = 0;
if (roll_pressed) {
    if (on_ground) {
        if (rollTimer <= 0 && stamina >= 10 && !isAttacking) {
            isRolling = true;
            rollTimer = global.roll_duration;
            rollDirection = (move != 0) ? move : sign(hspeed);
            if (rollDirection == 0) rollDirection = 1;
            hspeed = rollDirection * (global.roll_speed * 7.0);
            stamina -= 10;
            roll_invincible = true;
            audio_play_sound(snd_roll, 1, false);
        }
    } else if (vspeed > 0) {
        roll_buffer = 10;
    }
}

if (roll_buffer > 0) {
    roll_buffer--;
    if (on_ground && rollTimer <= 0 && stamina >= 10 && !isAttacking) {
        isRolling = true;
        rollTimer = global.roll_duration;
        rollDirection = (move != 0) ? move : sign(hspeed);
        if (rollDirection == 0) rollDirection = 1;
        hspeed = rollDirection * (global.roll_speed * 7.0);
        stamina -= 10;
        roll_invincible = true;
        roll_buffer = 0;
        audio_play_sound(snd_roll, 1, false);
    }
}

if (isRolling) {
    image_alpha = 0.5;
    rollTimer--;
    if (rollTimer <= 0 || place_meeting(x + rollDirection * 4, y, o_Solid)) {
        isRolling = false;
        rollTimer = 0;
        hspeed *= 0.7;
        image_alpha = 1;
        roll_invincible = false;
    }
    stamina -= stamina_drain_rate;
    if (stamina <= 0) {
        stamina = 0;
        isRolling = false;
        roll_invincible = false;
    }
}

// Side Collision
if (place_meeting(x + hspeed, y, o_Solid) && hspeed != 0) {
    while (!place_meeting(x + sign(hspeed), y, o_Solid) && abs(hspeed) > 0.1) {
        x += sign(hspeed);
    }
    hspeed = 0;
}

// Vertical Collision (With Squash and Stretch)
var was_in_air = !on_ground;
if (place_meeting(x, y + vspeed, o_Solid)) {
    while (!place_meeting(x, y + sign(vspeed), o_Solid) && abs(vspeed) > 0.1) {
        y += sign(vspeed);
    }
    vspeed = 0;
    on_ground = true;
    if (was_in_air) {
        instance_create_layer(x, y, "Instances", o_DustEffect);
    }
}

// Squash and Stretch
if (vspeed < 0) {
    image_yscale = 1.1;
    image_xscale = 0.9;
} else if (vspeed > 0) {
    image_yscale = 0.9;
    image_xscale = 1.1;
} else {
    image_yscale = 1;
    image_xscale = 1;
}

// Stamina Regeneration
if (!isRolling) {
    if (on_ground) {
        stamina = min(stamina + stamina_recover_rate, max_stamina);
    } else if (!on_ground && !was_on_wall) {
        stamina = min(stamina + stamina_recover_rate_air, max_stamina);
    }
}

// Stamina Flash Effect
if (stamina < 10) {
    stamina_flash = (stamina_flash + 0.2) mod (2 * pi);
    image_alpha = 0.5 + 0.5 * sin(stamina_flash);
} else if (iframes <= 0) {
    image_alpha = 1;
}

// Screen Shake
if (screen_shake_duration > 0) {
    if (instance_exists(o_Camera)) {
        o_Camera.screen_shake_amount = screen_shake_amount;
        o_Camera.screen_shake_duration = screen_shake_duration;
    }
    screen_shake_duration--;
}