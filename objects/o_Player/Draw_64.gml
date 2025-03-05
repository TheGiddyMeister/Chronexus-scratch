/// o_Player - Draw GUI Event (Health & Stamina Bar)

// Draw GUI Event (Debugging Coyote Time Display)
draw_set_color(c_white);
draw_text(display_get_width() - 150, 60, "Coyote Timer: " + string(self.coyote_timer));

// Bar Position
var bar_x = 20;
var bar_y = 20;
var bar_width = 200;
var bar_height = 20;
var spacing = 5; // Space between bars

// Draw Health Bar (Red)
draw_set_color(c_black);
draw_rectangle(bar_x - 2, bar_y - 2, bar_x + bar_width + 2, bar_y + bar_height + 2, false);
draw_set_color(c_red);
draw_rectangle(bar_x, bar_y, bar_x + (hp / max_hp) * bar_width, bar_y + bar_height, false);

// Draw Stamina Bar (Green)
draw_set_color(c_black);
draw_rectangle(bar_x - 2, bar_y + bar_height + spacing - 2, bar_x + bar_width + 2, bar_y + bar_height * 2 + spacing + 2, false);
draw_set_color(c_lime);
draw_rectangle(bar_x, bar_y + bar_height + spacing, bar_x + (stamina / max_stamina) * bar_width, bar_y + bar_height * 2 + spacing, false);

// Draw Text
draw_set_color(c_white);
draw_text(bar_x + 5, bar_y + 2, "HP: " + string(hp) + "/" + string(max_hp));
draw_text(bar_x + 5, bar_y + bar_height + spacing + 2, "Stamina: " + string(stamina) + "/" + string(max_stamina));


