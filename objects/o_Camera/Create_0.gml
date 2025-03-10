// Camera setup
view_enabled = true;
view_visible[0] = true;

// Create a camera
camera = camera_create_view(0, 0, 640, 360); // Adjust size based on your game resolution
view_camera[0] = camera;

// Variables for smooth camera follow
target_x = x;
target_y = y;
follow_speed = 0.15; // Slightly faster follow for better centering
look_ahead_dist = 30; // Reduced for subtler look-ahead
look_ahead_speed = 0.05;

// Variables for room bounds
room_width_max = room_width - camera_get_view_width(camera);
room_height_max = room_height - camera_get_view_height(camera);

// Screen shake variables
screen_shake_amount = 0;
screen_shake_duration = 0;

// Initialize camera position to center on player
if (instance_exists(o_Player)) {
    var cam_x = o_Player.x - camera_get_view_width(camera)/2;
    var cam_y = o_Player.y - camera_get_view_height(camera)/2;
    cam_x = clamp(cam_x, 0, room_width_max);
    cam_y = clamp(cam_y, 0, room_height_max);
    camera_set_view_pos(camera, cam_x, cam_y);
}