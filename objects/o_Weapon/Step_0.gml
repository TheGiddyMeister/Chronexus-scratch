hspeed = 0;
vspeed = 0;
gravity = 0;
x = start_x;
y = start_y;

if (!initialized) {
    switch (weapon_type) {
        case "sword":
            uses = 25;
            max_uses = 25;
            range = 16;
            damage = 1;
            speed = 1;
            sprite = spr_sword;
            break;
        case "bow":
            uses = 25;
            max_uses = 25;
            range = 32;
            damage = 0.8;
            speed = 1.5;
            sprite = spr_bow;
            break;
        case "spear":
            uses = 25;
            max_uses = 25;
            range = 20;
            damage = 1;
            speed = 0.8;
            sprite = spr_spear;
            break;
    }
    sprite_index = sprite;
    show_debug_message("o_Weapon initialized: weapon_type = " + weapon_type);
    initialized = true;
}

show_debug_message("o_Weapon position: (" + string(x) + ", " + string(y) + ")");

if (place_meeting(x, y, o_Player)) {
    show_debug_message("Player collided with o_Weapon: weapon_type = " + weapon_type);
    with (o_Player) {
        var slot = -1;
        if (weapon_inventory[0] == noone) slot = 0;
        else if (weapon_inventory[1] == noone) slot = 1;
        
        if (slot != -1) {
            weapon_inventory[slot] = {
                type: other.weapon_type,
                uses: other.uses,
                max_uses: other.max_uses,
                range: other.range,
                damage: other.damage,
                speed: other.speed,
                sprite: other.sprite
            };
            active_weapon_slot = slot;
            show_debug_message("Weapon added to slot " + string(slot) + ": " + other.weapon_type);
        } else {
            weapon_inventory[active_weapon_slot] = {
                type: other.weapon_type,
                uses: other.uses,
                max_uses: other.max_uses,
                range: other.range,
                damage: other.damage,
                speed: other.speed,
                sprite: other.sprite
            };
            show_debug_message("Weapon replaced in slot " + string(active_weapon_slot) + ": " + other.weapon_type);
        }
    }
    instance_destroy();
}