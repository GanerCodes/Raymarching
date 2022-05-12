from vectors import *

class quat:
    def __init__(self, x=0, y=0, z=0, r=0):
        self.r = r # w / real
        self.x = x # i
        self.y = y # j
        self.z = z # k
    def __neg__(self):
        return quat(-self.x, -self.y, -self.z, self.r)
    def __mul__(q1, q2):
        x1, y1, z1, w1 = q1
        x2, y2, z2, w2 = q2
        return quat(r=w1*w2-x1*x2-y1*y2-z1*z2,
                    x=w1*x2+x1*w2+y1*z2-z1*y2,
                    y=w1*y2-x1*z2+y1*w2+z1*x2,
                    z=w1*z2+x1*y2-y1*x2+z1*w2)
    def __repr__(self):
        return '[<{}, {}, {}>, {}]'.format(*("{: 02.4f}".format(i) for i in self))
    def __str__(self):
        return repr(self)
    def __iter__(self):
        return iter((self.x, self.y, self.z, self.r))
    def vec(self):
        return v3(self.x, self.y, self.z)
    def dir(self):
        return v3(2 * (self.x * self.z - self.r * self.y),
                  2 * (self.y * self.z + self.r * self.x),
                  1 - 2 * (self.x ** 2 + self.y ** 2))
    def norm(self):
        h = hypot(*self)
        return quat(*(i/h for i in self))
    def copy(self):
        return quat(*self)

def quat_create_axis_rot(vhat, angle):
    angle *= 0.5
    q = quat(r=sin(angle)) * vhat
    q.r = cos(angle)
    return q.norm()

def quat_rot_point(p, vhat, angle):
    q = quat_create_axis_rot(vhat, angle)
    return q * quat(*p) * (-q)

def quat_rot_axis(axis, a):
    a = 0.5 * a
    axis = axis.norm() * sin(a)
    return quat(axis.x, axis.y, axis.z, cos(a)).norm()

def quat_get_euler(q):
    sinr_cosp = 2 * (q.r * q.x + q.y * q.z)
    cosr_cosp = 1 - 2 * (q.x * q.x + q.y * q.y)
    roll = atan2(sinr_cosp, cosr_cosp)
    sinp = 2 * (q.r * q.y - q.z * q.x)
    if abs(sinp) >= 1:
        pitch = (1 if sinp >= 0 else -1) * HALF_PI
    else:
        pitch = asin(sinp)
    siny_cosp = 2 * (q.r * q.z + q.x * q.y)
    cosy_cosp = 1 - 2 * (q.y * q.y + q.z * q.z)
    yaw = atan2(siny_cosp, cosy_cosp)
    return v3(roll, pitch, yaw)

quatX, quatY, quatZ = quat(1,0,0), quat(0,1,0), quat(0,0,1)