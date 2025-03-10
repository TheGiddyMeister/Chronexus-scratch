// Move and check collisions
if (place_meeting(x, y, o_Solid)) {
    instance_destroy();
}

// Damage enemies
var enemy = instance_place(x, y, o_Enemy);
if (enemy != noone) {
    enemy.hp -= damage;
    if (enemy.hp <= 0) {
        instance_destroy(enemy);
    }
    instance_destroy();
}