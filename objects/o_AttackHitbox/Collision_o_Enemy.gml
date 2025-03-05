// o_AttackHitbox - Collision with o_Enemy
with (other) {
    hp -= 25; // Deal damage
}
instance_destroy(); // Destroy hitbox after hitting
