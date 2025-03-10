lifetime--;
if (lifetime <= 0) {
    ds_list_destroy(hit_enemies);
    instance_destroy();
    exit;
}

var hitbox_size = sprite_get_width(sprite_index) / 2;
var left = x - hitbox_size;
var top = y - hitbox_size;
var right = x + hitbox_size;
var bottom = y + hitbox_size;

var enemy_list = ds_list_create();
var num_enemies = collision_rectangle_list(left, top, right, bottom, o_Enemy, false, true, enemy_list, false);
for (var i = 0; i < num_enemies; i++) {
    var enemy = ds_list_find_value(enemy_list, i);
    if (enemy != noone && ds_list_find_index(hit_enemies, enemy) == -1) {
        ds_list_add(hit_enemies, enemy);
        enemy.hp -= damage;
        enemy.hit_flash = 10;
        if (enemy.hp > 0) {
            with (o_Player) {
                alarm[0] = 4; // Hit stop
                isAttacking = true;
            }
        }
        if (enemy.hp <= 0) {
            instance_destroy(enemy);
        }
        if (owner != noone && owner.weapon_inventory[owner.active_weapon_slot] != noone) {
            owner.weapon_inventory[owner.active_weapon_slot].uses -= 1;
            if (owner.weapon_inventory[owner.active_weapon_slot].uses <= 0) {
                owner.weapon_inventory[owner.active_weapon_slot] = noone;
            }
        }
    }
}
ds_list_destroy(enemy_list);