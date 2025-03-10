if (instance_exists(o_Player)) {
    var cam_w = display_get_gui_width(); // Use GUI width for consistent positioning
    var cam_h = display_get_gui_height();
    
    // Draw two boxes at bottom right with larger size
    var box_width = 48; // Increased from 32 to 48
    var box_height = 48; // Increased from 32 to 48
    var box_margin = 10;
    var box_x1 = cam_w - box_width - box_margin;
    var box_y1 = cam_h - box_height - box_margin;
    var box_x2 = cam_w - (box_width * 2) - (box_margin * 2);
    var box_y2 = cam_h - box_height - box_margin;
    
    // Draw box 1 (slot 0)
    draw_set_alpha(box_alpha);
    draw_set_color(box_color);
    draw_rectangle(box_x1, box_y1, box_x1 + box_width, box_y1 + box_height, false);
    if (o_Player.active_weapon_slot == 0) {
        draw_set_color(c_yellow); // Highlight active slot
        draw_rectangle(box_x1, box_y1, box_x1 + box_width, box_y1 + box_height, true);
    }
    if (o_Player.weapon_inventory[0] != noone) {
        var weapon = o_Player.weapon_inventory[0];
        draw_sprite_ext(weapon.sprite, 0, box_x1 + box_width/2, box_y1 + box_height/2, 1.5, 1.5, 0, c_white, 1); // Scale sprite up slightly
        
        // Draw durability bar (larger to match box size)
        var bar_width = 40; // Increased from 30
        var bar_height = 8; // Increased from 5
        var bar_x = box_x1 + (box_width - bar_width) / 2;
        var bar_y = box_y1 + box_height + 5;
        var fill_width = (weapon.uses / weapon.max_uses) * bar_width;
        draw_set_color(c_red);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
        draw_set_color(c_green);
        draw_rectangle(bar_x, bar_y, bar_x + fill_width, bar_y + bar_height, false);
        draw_set_color(c_black);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    }
    
    // Draw box 2 (slot 1)
    draw_set_color(box_color);
    draw_rectangle(box_x2, box_y2, box_x2 + box_width, box_y2 + box_height, false);
    if (o_Player.active_weapon_slot == 1) {
        draw_set_color(c_yellow);
        draw_rectangle(box_x2, box_y2, box_x2 + box_width, box_y2 + box_height, true);
    }
    if (o_Player.weapon_inventory[1] != noone) {
        var weapon = o_Player.weapon_inventory[1];
        draw_sprite_ext(weapon.sprite, 0, box_x2 + box_width/2, box_y2 + box_height/2, 1.5, 1.5, 0, c_white, 1); // Scale sprite up slightly
        
        // Draw durability bar (larger to match box size)
        var bar_width = 40; // Increased from 30
        var bar_height = 8; // Increased from 5
        var bar_x = box_x2 + (box_width - bar_width) / 2;
        var bar_y = box_y2 + box_height + 5;
        var fill_width = (weapon.uses / weapon.max_uses) * bar_width;
        draw_set_color(c_red);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, false);
        draw_set_color(c_green);
        draw_rectangle(bar_x, bar_y, bar_x + fill_width, bar_y + bar_height, false);
        draw_set_color(c_black);
        draw_rectangle(bar_x, bar_y, bar_x + bar_width, bar_y + bar_height, true);
    }
    
    // Reset draw settings
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}