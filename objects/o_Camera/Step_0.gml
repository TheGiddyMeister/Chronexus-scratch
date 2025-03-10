if (instance_exists(o_Player)) {
    // Base target is player's position
    target_x = o_Player.x;
    target_y = o_Player.y;
    
    // Add look-ahead based on input mode
    var look_x = target_x;
    var look_y = target_y;
    
    if (o_Player.input_mode == "controller") {
        // Look-ahead based on facing direction
        var facing_dir;
        if (o_Player.move != 0) {
            facing_dir = sign(o_Player.move);
        } else if (o_Player.hspeed != 0) {
            facing_dir = sign(o_Player.hspeed);
        } else {
            facing_dir = 1;
        }
        look_x += facing_dir * look_ahead_dist;
        
        // Add right stick camera control
        var rh_axis = gamepad_axis_value(0, gp_axisrh);
        var rv_axis = gamepad_axis_value(0, gp_axisrv);
        var camera_look_dist = 100; // Max distance the camera can look with right stick
        if (abs(rh_axis) > o_Player.controller_deadzone) {
            look_x += rh_axis * camera_look_dist;
        }
        if (abs(rv_axis) > o_Player.controller_deadzone) {
            look_y += rv_axis * camera_look_dist;
        }
    } else {
        // Keyboard/mouse: look toward mouse position
        var mouse_dir = point_direction(o_Player.x, o_Player.y, mouse_x, mouse_y);
        look_x += lengthdir_x(look_ahead_dist, mouse_dir);
        look_y += lengthdir_y(look_ahead_dist, mouse_dir);
    }
    
    // Smoothly interpolate toward target
    var cam_x = camera_get_view_x(camera);
    var cam_y = camera_get_view_y(camera);
    cam_x += (look_x - cam_x - camera_get_view_width(camera)/2) * follow_speed;
    cam_y += (look_y - cam_y - camera_get_view_height(camera)/2) * follow_speed;
    
    // Add screen shake
    if (screen_shake_duration > 0) {
        cam_x += random_range(-screen_shake_amount, screen_shake_amount);
        cam_y += random_range(-screen_shake_amount, screen_shake_amount);
        screen_shake_duration--;
    }
    
    // Clamp camera to room bounds
    cam_x = clamp(cam_x, 0, room_width_max);
    cam_y = clamp(cam_y, 0, room_height_max);
    
    // Update camera position
    camera_set_view_pos(camera, cam_x, cam_y);
}