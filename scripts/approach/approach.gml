/// approach(current, target, amount)
/// @param current The current value
/// @param target The target value
/// @param amount The amount to move by
function approach(current, target, amount) {
    if (current < target) {
        return min(current + amount, target);
    } else {
        return max(current - amount, target);
    }
}