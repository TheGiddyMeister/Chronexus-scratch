// Player Stats
hp = 100;
max_hp = 100;
stamina = 50;
max_stamina = 50;
stamina_drain_rate = 0.3; // Normal drain rate (used for rolling and wall climbing with movement)
stamina_drain_rate_wall_idle = 0.05; // Reduced drain rate when wall climbing without vertical movement
stamina_recover_rate = 0.25; // Normal regen rate (on ground or other valid states)
stamina_recover_rate_air = 0.2; // Slower regen rate in the air
stamina_wall_jump_cost = 5; // Extra stamina cost when jumping off a wall
stamina_depleted = false;
iframes = 0;

// Movement Variables
global.gravity = 0.6;
global.max_speed = 7;
global.jump_speed = -9.5;
global.friction = 0.85; // Friction factor (higher = slower stop)
global.acceleration = 2.5; // How quickly the player reaches max speed

// Rolling Variables
global.roll_speed = 3;
global.roll_duration = 10;

// Coyote Time Variables
if (!variable_global_exists("coyote_time")) global.coyote_time = 7;
coyote_timer = 0;
was_on_ground = false;

// Wall Climb Variables
global.wall_climb_speed = -2.5;
global.wall_jump_push = 5.0;
is_wall_climbing = false;
wall_jump_locked = false;
was_on_wall = false;

// Rolling Variables
isRolling = false;
rollTimer = 0;
rollDirection = 0;

// Attack Variables
isAttacking = false;
attackTimer = 0;
attackCooldown = 0;
attack_duration = 8; // Duration of attack in frames
attack_cooldown_duration = 15; // Cooldown between attacks in frames
attack_force_ground = 24; // Attack boost strength on ground
attack_force_air = 16; // Attack boost strength in air
attack_momentum_decay = 0.7; // Momentum retained after attack ends
controller_deadzone = 0.3; // Deadzone for sticks to avoid jitter
using_controller = false; // Track whether controller input is active
has_attacked_in_air = false; // Track if player has attacked in the air

// State Machine Variables
current_state = "idle"; // Initial state