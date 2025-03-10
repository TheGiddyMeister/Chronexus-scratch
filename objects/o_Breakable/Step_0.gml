if (place_meeting(x, y, o_AttackHitbox)) {
    hp -= 1;
    if (hp <= 0) {
        instance_destroy();
        repeat(3) {
            instance_create_layer(x, y, "Instances", o_DustEffect);
        }
    }
}