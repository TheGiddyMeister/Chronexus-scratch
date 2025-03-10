hp = 100;
max_hp = 100;
stamina = 100;
max_stamina = 100;
iframes = 0;

weapon_inventory[0] = noone;
weapon_inventory[1] = noone;
active_weapon_slot = 0;

isAttacking = false;
attackTimer = 0;
attackCooldown = 0;
attack_duration = 15;
attack_cooldown_duration = 20;
attack_dash_speed = 5;
attack_momentum_decay = 0.8;
attack_buffer = 0;
attack_buffer_max = 5;
has_attacked_in_air = false;

isRolling = false;
rollTimer = 0;
rollDirection = 0;
roll_invincible = false;

is_wall_climbing = false;
was_on_wall = false;
wall_jump_locked = false;

on_ground = false;
on_wall = false;
coyote_timer = 0;
jump_buffer = 0;

stamina_flash = 0;
screen_shake_amount = 0;
screen_shake_duration = 0;

input_mode = "keyboard";
controller_deadzone = 0.2;

hspeed = 0;
vspeed = 0;

global.max_speed = 4;
global.jump_speed = -12;
global.jump_speed_min = -5;
global.wall_jump_vspeed = -8;
global.wall_jump_push = 5;
global.acceleration = 0.5;
global.friction = 0.85;
global.gravity = 0.6;
global.coyote_time = 4;
global.roll_duration = 20;
global.roll_speed = 1;
stamina_recover_rate = 0.5;
stamina_recover_rate_air = 0.25;
stamina_drain_rate = 0.5;
stamina_drain_rate_wall_idle = 0.1;
stamina_wall_jump_cost = 10;