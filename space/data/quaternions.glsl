vec4 quat_mul(vec4 q1, vec4 q2) {
    return vec4(q1.w*q2.x+q1.x*q2.w+q1.y*q2.z-q1.z*q2.y,
                q1.w*q2.y-q1.x*q2.z+q1.y*q2.w+q1.z*q2.x,
                q1.w*q2.z+q1.x*q2.y-q1.y*q2.x+q1.z*q2.w,
                q1.w*q2.w-q1.x*q2.x-q1.y*q2.y-q1.z*q2.z);
}
vec4 quat_conj(vec4 q) {
    return vec4(-q.xyz, q.w);
}
vec4 quat_rot(vec4 p, vec4 vhat, float angle) {
    angle *= 0.5;
    vec4 q = quat_mul(vec4(vec3(0.0), sin(angle)), vhat);
    q.w = cos(angle);
    return quat_mul(quat_mul(q, p), quat_conj(q));
}