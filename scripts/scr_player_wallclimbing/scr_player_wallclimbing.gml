function scr_player_wallclimbing(){
hspeed = 0;
vspeed = 0; // Stay still unless moving
var v_move = 0;
if (input_mode == "keyboard") {
    if (keyboard_check(ord("W"))) v_move = -1;
    if (keyboard_check(ord("S"))) v_move = 1;
} else {
    var v_axis = gamepad_axis_value(0, gp_axislv);
    if (abs(v_axis) > controller_deadzone) v_move = sign(v_axis);
}
if (v_move != 0) {
    vspeed = v_move * 2.5;
    stamina -= stamina_drain_rate;
} else if (!on_ground) {
    stamina -= stamina_drain_rate_wall_idle;
}
if (!climb_pressed || !on_wall || stamina <= 0) {
    state = (on_ground) ? (move != 0 ? scr_player_running : scr_player_idle) : scr_player_jumping;
}
if (jump_pressed) {
    vspeed = global.wall_jump_vspeed;
    hspeed = (place_meeting(x-4*image_xscale, y, o_Solid)) ? global.wall_jump_push : -global.wall_jump_push;
    stamina = max(0, stamina - stamina_wall_jump_cost);
    state = scr_player_jumping;
    audio_play_sound(snd_jump, 1, false);
}
}