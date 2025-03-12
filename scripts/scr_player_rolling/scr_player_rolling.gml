function scr_player_rolling(){
rollTimer--;
if (rollTimer <= 0) {
    isRolling = false;
    roll_invincible = false;
    state = (on_ground) ? (move != 0 ? scr_player_running : scr_player_idle) : scr_player_jumping;
    show_debug_message("Roll ended: state = " + script_get_name(state));
}
if (!on_ground) vspeed = min(vspeed + global.gravity, 10);
}