function scr_player_attacking(){
attackTimer--;
if (attackTimer <= 0) {
    isAttacking = false;
    state = (on_ground) ? (move != 0 ? scr_player_running : scr_player_idle) : scr_player_jumping;
    show_debug_message("Attack ended: state = " + script_get_name(state));
}
if (!on_ground) vspeed = min(vspeed + global.gravity, 10);
}