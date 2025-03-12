// Debug: Start of Step
show_debug_message("Step started: state = " + ((state == -1) ? "uninitialized" : script_get_name(state)) + ", x = " + string(x) + ", y = " + string(y) + ", hspeed = " + string(hspeed) + ", vspeed = " + string(vspeed));

// Initialize State
if (!state_initialized) {
    state = scr_player_idle;
    state_initialized = true;
    show_debug_message("State initialized to scr_player_idle");
}

// Core Variables
on_ground = place_meeting(x, y+1, o_Solid);
on_wall = place_meeting(x+4*image_xscale, y, o_Solid) || place_meeting(x-4*image_xscale, y, o_Solid);

// Coyote Time
if (on_ground) coyote_timer = global.coyote_time else if (coyote_timer > 0) coyote_timer--;

// Input Detection
var kb_input = keyboard_check(vk_anykey) || mouse_check_button(mb_any);
var controller_input = false;
var lh_axis = gamepad_axis_value(0, gp_axislh);
var lv_axis = gamepad_axis_value(0, gp_axislv);
var rh_axis = gamepad_axis_value(0, gp_axisrh);
var rv_axis = gamepad_axis_value(0, gp_axisrv);
if (abs(lh_axis) > controller_deadzone || abs(lv_axis) > controller_deadzone ||
    abs(rh_axis) > controller_deadzone || abs(rv_axis) > controller_deadzone ||
    gamepad_button_check_pressed(0, gp_face1) || gamepad_button_check_pressed(0, gp_face2) ||
    gamepad_button_check_pressed(0, gp_face3) || gamepad_button_check_pressed(0, gp_shoulderr)) {
    controller_input = true;
}
if (kb_input && !controller_input) input_mode = "keyboard";
else if (controller_input && !kb_input) input_mode = "controller";

move = 0;
if (input_mode == "keyboard") {
    if (keyboard_check(vk_right) || keyboard_check(ord("D"))) move = 1;
    if (keyboard_check(vk_left) || keyboard_check(ord("A"))) move = -1;
} else {
    var h_axis = gamepad_axis_value(0, gp_axislh);
    if (abs(h_axis) > controller_deadzone) move = sign(h_axis);
}

attack_pressed = (input_mode == "keyboard") ? mouse_check_button_pressed(mb_left) : gamepad_button_check_pressed(0, gp_face3);
jump_pressed = (input_mode == "keyboard") ? keyboard_check_pressed(vk_space) : gamepad_button_check_pressed(0, gp_face1);
jump_released = (input_mode == "keyboard") ? keyboard_check_released(vk_space) : gamepad_button_check_released(0, gp_face1);
roll_pressed = (input_mode == "keyboard") ? keyboard_check_pressed(vk_shift) : gamepad_button_check_pressed(0, gp_face2);
switch_weapon = (input_mode == "keyboard") ? keyboard_check_pressed(ord("Q")) : gamepad_button_check_pressed(0, gp_shoulderrb);
throw_weapon = (input_mode == "keyboard") ? keyboard_check_pressed(ord("T")) : gamepad_button_check_pressed(0, gp_face4);
climb_pressed = (input_mode == "keyboard") ? keyboard_check(ord("E")) : gamepad_button_check(0, gp_shoulderr);

// Debug Inputs
if (attack_pressed) show_debug_message("Attack pressed! input_mode = " + input_mode);
if (roll_pressed) show_debug_message("Roll pressed! input_mode = " + input_mode);
if (throw_weapon) show_debug_message("Throw pressed! input_mode = " + input_mode);

// Restart Game
if ((input_mode == "keyboard" && keyboard_check_pressed(ord("R"))) || (input_mode == "controller" && gamepad_button_check_pressed(0, gp_start))) {
    game_restart();
}

// Collision Handling
var h_move = hspeed;
var v_move = vspeed;
h_move = clamp(h_move, -global.max_speed * 3, global.max_speed * 3); // Increased cap for longer dash/roll
v_move = clamp(v_move, -10, 10);

if (place_meeting(x, y, o_Solid) || place_meeting(x + sign(hspeed), y, o_Solid)) {
    show_debug_message("Overlap detected! Resolving...");
    var push_dir = [[0, -1], [-1, 0], [1, 0], [0, 1]];
    for (var i = 0; i < 4; i++) {
        var dx = push_dir[i][0];
        var dy = push_dir[i][1];
        var steps = 0;
        while (place_meeting(x + dx * steps, y + dy * steps, o_Solid) && steps < 10) steps++;
        if (!place_meeting(x + dx * steps, y + dy * steps, o_Solid)) {
            x += dx * steps;
            y += dy * steps;
            hspeed = 0;
            vspeed = 0;
            show_debug_message("Pushed out to x = " + string(x) + ", y = " + string(y));
            break;
        }
    }
}

if (h_move != 0 || v_move != 0) {
    var steps = max(1, ceil(max(abs(h_move), abs(v_move))));
    var h_step = h_move / steps;
    var v_step = v_move / steps;
    for (var i = 0; i < steps; i++) {
        var next_x = x + h_step;
        if (!place_meeting(next_x, y, o_Solid)) {
            x = next_x;
        } else {
            x = round(x); // Snap to edge
            hspeed = 0;
        }
        var next_y = y + v_step;
        if (!place_meeting(x, next_y, o_Solid)) {
            y = next_y;
        } else {
            y = round(y);
            vspeed = 0;
            if (v_step > 0) on_ground = true;
        }
    }
}

// Apply Friction Globally (except during attack/roll initial frames)
if (state != scr_player_attacking || attackTimer < attack_duration - 1) {
    if (state != scr_player_rolling || rollTimer < global.roll_duration - 1) {
        if (on_ground && !move) hspeed *= global.friction;
    }
}

// Throw Weapon
if (throw_weapon && weapon_inventory[active_weapon_slot] != noone && !isAttacking && !isRolling) {
    var weapon = weapon_inventory[active_weapon_slot];
    var throw_dir;
    if (input_mode == "keyboard") {
        throw_dir = point_direction(x, y, mouse_x, mouse_y);
    } else {
        if (abs(lh_axis) > controller_deadzone || abs(lv_axis) > controller_deadzone) {
            throw_dir = point_direction(0, 0, lh_axis, lv_axis);
        } else if (move != 0) {
            throw_dir = (move > 0) ? 0 : 180;
        } else if (hspeed != 0) {
            throw_dir = (hspeed > 0) ? 0 : 180;
        } else {
            throw_dir = 0;
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

// Attack Initiation
if (attack_pressed && weapon_inventory[active_weapon_slot] != noone && !isAttacking && !isRolling && attackCooldown <= 0) {
    show_debug_message("Attack initiated!");
    state = scr_player_attacking;
    isAttacking = true;
    attackTimer = attack_duration;
    attackCooldown = attack_cooldown_duration;
    if (!on_ground) has_attacked_in_air = true;
    var weapon = weapon_inventory[active_weapon_slot];
    var attackDir;
    if (input_mode == "keyboard") {
        attackDir = point_direction(x, y, mouse_x, mouse_y);
    } else {
        if (abs(lh_axis) > controller_deadzone || abs(lv_axis) > controller_deadzone) {
            attackDir = point_direction(0, 0, lh_axis, lv_axis);
        } else if (move != 0) {
            attackDir = (move > 0) ? 0 : 180;
        } else if (hspeed != 0) {
            attackDir = (hspeed > 0) ? 0 : 180;
        } else {
            attackDir = 0;
        }
    }
    hspeed = lengthdir_x(attack_dash_speed * 1.5, attackDir); // Increased from 5 to 7.5
    vspeed = lengthdir_y(attack_dash_speed * 1.5, attackDir);
    var hitbox = instance_create_layer(x + lengthdir_x(weapon.range, attackDir), y + lengthdir_y(weapon.range, attackDir), "Instances", o_AttackHitbox);
    with (hitbox) {
        direction = attackDir;
        owner = other;
        damage = weapon.damage;
        lifetime = 12;
        image_angle = attackDir;
    }
    screen_shake_amount = 3;
    screen_shake_duration = 6;
    repeat(3) instance_create_layer(x, y, "Instances", o_TrailEffect);
    audio_play_sound(snd_attack, 1, false);
}
if (attackCooldown > 0) attackCooldown--;

// Roll Initiation
if (roll_pressed && !isRolling && !isAttacking && stamina >= 10) {
    if (on_ground && rollTimer <= 0) {
        show_debug_message("Roll initiated!");
        state = scr_player_rolling;
        isRolling = true;
        rollTimer = global.roll_duration;
        rollDirection = (move != 0) ? move : (hspeed != 0 ? sign(hspeed) : 1);
        hspeed = rollDirection * global.roll_speed * 1.5; // Increased from 5 to 7.5
        vspeed = 0;
        stamina -= 10;
        roll_invincible = true;
        audio_play_sound(snd_roll, 1, false);
    } else if (!on_ground && vspeed > 0) {
        roll_buffer = 10;
    }
}
if (roll_buffer > 0) {
    roll_buffer--;
    if (on_ground && rollTimer <= 0 && stamina >= 10 && !isAttacking) {
        show_debug_message("Roll initiated from buffer!");
        state = scr_player_rolling;
        isRolling = true;
        rollTimer = global.roll_duration;
        rollDirection = (move != 0) ? move : (hspeed != 0 ? sign(hspeed) : 1);
        hspeed = rollDirection * global.roll_speed * 1.5;
        vspeed = 0;
        stamina -= 10;
        roll_invincible = true;
        roll_buffer = 0;
        audio_play_sound(snd_roll, 1, false);
    }
}

// Switch Weapons
if (switch_weapon) {
    active_weapon_slot = (active_weapon_slot == 0) ? 1 : 0;
    show_debug_message("Switched to weapon slot: " + string(active_weapon_slot));
}

// Execute State
script_execute(state);

// Stamina and Iframes
if (iframes > 0) iframes--;
if (state != scr_player_rolling) {
    if (on_ground) stamina = min(stamina + stamina_recover_rate, max_stamina);
    else if (!on_ground && !was_on_wall) stamina = min(stamina + stamina_recover_rate_air, max_stamina);
}

// Visual Effects
if (stamina < 10) {
    stamina_flash = (stamina_flash + 0.2) mod (2 * pi);
    image_alpha = 0.5 + 0.5 * sin(stamina_flash);
} else if (iframes <= 0) {
    image_alpha = 1;
}
if (screen_shake_duration > 0) {
    if (instance_exists(o_Camera)) {
        o_Camera.screen_shake_amount = screen_shake_amount;
        o_Camera.screen_shake_duration = screen_shake_duration;
    }
    screen_shake_duration--;
}

// Debug: End of Step
show_debug_message("Step ended: state = " + script_get_name(state) + ", x = " + string(x) + ", y = " + string(y) + ", hspeed = " + string(hspeed) + ", vspeed = " + string(vspeed));





