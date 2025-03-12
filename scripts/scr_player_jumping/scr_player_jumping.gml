function scr_player_jumping(){
if (jump_released && vspeed < 0) vspeed *= 0.5;
if (on_ground) state = (move != 0) ? scr_player_running : scr_player_idle;
if (climb_pressed && on_wall && stamina > 0) state = scr_player_wallclimbing;
hspeed = clamp(hspeed + move * global.acceleration, -global.max_speed, global.max_speed);
vspeed = min(vspeed + global.gravity, 10);
}