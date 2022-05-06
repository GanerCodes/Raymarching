float stars_b1(vec2 p, vec2 q) {
    return pow(
        mod(p.x + 1, 2.0) - 1.0 + q.x,
        2.0
    ) + pow(
        mod(p.y + 1.0, 2.0) - 1.0 + q.y,
        2.0
    ) + 0.04 * sign(
        max(
            2.0 * abs(q.x - 0.5) - 0.6,
            2.0 * abs(q.y - 0.5) - 0.6
        )
    );
}
float stars_b2(vec2 p, vec2 reg) {
    return stars_b1(
        p,
        2.0 * vec2(
            rand(sin(reg.x) + cos(reg.y)),
            rand(cos(reg.x) + sin(reg.y))
        )
    );
}
float stars_bu(vec2 p) {
    return stars_b2(p,
        vec2(
            floor(0.5 * (p.x + 1)),
            floor(0.5 * (p.y + 1))
        )
    );
}