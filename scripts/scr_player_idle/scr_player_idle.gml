function scr_player_idle(){
if (move != 0) state = scr_player_running;
if (jump_pressed && (on_ground || coyote_timer > 0)) {
    vspeed = global.jump_speed;
    state = scr_player_jumping;
    audio_play_sound(snd_jump, 1, false);
}
if (!on_ground) state = scr_player_jumping;
if (climb_pressed && on_wall && stamina > 0) state = scr_player_wallclimbing;
hspeed = 0;
if (!on_ground) vspeed = min(vspeed + global.gravity, 10);
}