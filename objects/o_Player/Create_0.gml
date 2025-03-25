// State Machine
state = -1; // Uninitialized
state_initialized = false;
facing = 1; // Start facing right
base_scale = image_xscale; // Store original scale (set this in editor or here, e.g., 1)
jump_buffer = 0; // Initialize jump buffer
// Add to existing variables like hspeed, vspeed, etc.
// Health and Stamina
hp = 100;
max_hp = 100;
stamina = 50;
max_stamina = 50;
iframes = 0;

// Weapons
weapon_inventory[0] = { damage: 10, range: 20, sprite: spr_sword, uses: 50, max_uses: 50 };
weapon_inventory[1] = noone;
active_weapon_slot = 0;

// Attack Variables
isAttacking = false;
attackTimer = 0;
attackCooldown = 0;
attack_duration = 15;
attack_cooldown_duration = 20;
attack_dash_speed = 5; // Base value, modified in Step
attack_momentum_decay = 0.8;
has_attacked_in_air = false;

// Roll Variables
isRolling = false;
rollTimer = 0;
rollDirection = 0;
roll_invincible = false;
roll_buffer = 0;

// Wall Climbing Variables
was_on_wall = false;

// Collision and Jump Variables
on_ground = false;
on_wall = false;
coyote_timer = 0;
jump_buffer = 0;

// Visual Effects
stamina_flash = 0;
screen_shake_amount = 0;
screen_shake_duration = 0;

// Input
input_mode = "keyboard";
controller_deadzone = 0.2;

// Movement
hspeed = 0;
vspeed = 0;

// Global Constants
global.max_speed = 3;
global.jump_speed = -8;
global.wall_jump_vspeed = -6;
global.wall_jump_push = 4;
global.acceleration = 0.5;
global.friction = 0.85;
global.gravity = 0.4;
global.coyote_time = 4;
global.roll_duration = 20;
global.roll_speed = 5; // Base value, modified in Step
stamina_recover_rate = 0.5;
stamina_recover_rate_air = 0.25;
stamina_drain_rate = 0.5;
stamina_drain_rate_wall_idle = 0.1;
stamina_wall_jump_cost = 10;

// Appearance
image_xscale = 1.6;
image_yscale = 1.6;