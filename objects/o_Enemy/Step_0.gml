// Patrol Movement
if (abs(x - start_x) >= patrol_distance) {
    move_dir *= -1;
    hspeed = move_speed * move_dir;
}
hspeed = move_speed * move_dir;

// Apply Gravity
if (!place_meeting(x, y + 1, o_Solid)) {
    vspeed += gravity;
} else {
    vspeed = 0;
    // Snap to floor if slightly below
    if (place_meeting(x, y, o_Solid)) {
        while (place_meeting(x, y, o_Solid)) {
            y -= 1;
        }
    }
}

// Horizontal Collision
if (place_meeting(x + hspeed, y, o_Solid)) {
    while (!place_meeting(x + sign(hspeed), y, o_Solid)) {
        x += sign(hspeed);
    }
    hspeed = 0;
    move_dir *= -1;
    hspeed = move_speed * move_dir;
}

// Vertical Collision (Improved Precision)
if (vspeed != 0) {
    if (place_meeting(x, y + vspeed, o_Solid)) {
        while (!place_meeting(x, y + sign(vspeed), o_Solid)) {
            y += sign(vspeed);
        }
        vspeed = 0;
    } else {
        y += vspeed; // Only move if no collision
    }
} else {
    y += vspeed; // Apply vspeed if 0 (no change)
}

// Damage Player on Contact
if (place_meeting(x, y, o_Player) && o_Player.iframes <= 0 && !o_Player.roll_invincible) {
    with (o_Player) {
        hp -= other.damage;
        iframes = 30;
        hspeed += sign(x - other.x) * 5;
        vspeed = -5;
        if (hp <= 0) {
            game_restart();
        }
    }
}

// Visual Feedback (Hit Flash)
if (hit_flash > 0) {
    hit_flash--;
    image_alpha = (hit_flash mod 2 == 0) ? 0.5 : 1;
} else {
    image_alpha = 1;
}

// Debug Position and HP
show_debug_message("o_Enemy at (" + string(x) + ", " + string(y) + "), HP = " + string(hp));