if (iframes <= 0 && !roll_invincible) {
    hp -= other.damage;
    iframes = 30;
    show_debug_message("Player hit! HP = " + string(hp));
}