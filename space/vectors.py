class Vec(PVector):
    def __init__(self, *args):
        a = []
        for i in args:
            if i is None: continue
            if isinstance(i, Vec): a += list(i)
            else: a += [i]
        self.dimensions = len(a)
        PVector.__init__(self, *a)
    def __str__(self):
        return "<{}>".format(', '.join(map(lambda x: str(round(x, 4)), self)))
    def __iter__(self):
        l = [self.x, self.y]
        if self.dimensions > 2:
            l += [self.z]
        return iter(l)
    def __str__(self):
        return repr(self)
    def __repr__(self):
        return '<{}>'.format(', '.join("{: 010.4f}".format(i) for i in self))
    def __getattribute__(self, name):
        if 4 > len(name) > 1 and not len(set(name).difference(set('xyz'))):
            return Vec(*(getattr(self, i) for i in name))
        return PVector.__getattribute__(self, name)
    def __add__(self, other):
        q = list(self)
        for i, v in enumerate(other):
            q[i] += v
        return Vec(*q)
    def __sub__(self, other):
        return self + (-other)
    def __mul__(self, other):
        if isinstance(other, Vec):
            return Vec(*(i * o for i, o in zip(self, other)))
        else:
            return Vec(*(i * other for i in self))
    def __neg__(self):
        return Vec(*(-i for i in self))
    def copy(self):
        return Vec(*self)
    def setXY(self, a, b=None):
        a, b = Vec(a, b)
        self.x, self.y = a, b
        return self
    def setXZ(self, a, b=None):
        a, b = Vec(a, b)
        self.x, self.z = a, b
        return self
    def setYZ(self, a, b=None):
        a, b = Vec(a, b)
        self.y, self.z = a, b
        return self
    def setXYZ(self, a, b=None, c=None):
        a, b, c = Vec(a, b, c)
        self.x, self.y, self.z = a, b, c
        return self

class Obj3d:
    def __init__(self, loc=None, ang=None):
        self.loc = loc or v3()
        self.ang = ang or v2()
        self.init_data = {
            'loc': self.loc.copy(),
            'ang': self.ang.copy()}
    def __str__(self):
        return "{}, {}".format(self.loc, self.ang)

class Player3d(Obj3d):
    def __init__(self, loc=None, ang=None, loc_vel=None, ang_vel=None):
        Obj3d.__init__(self, loc, ang)
        self.loc_vel = loc_vel or v3()
        self.ang_vel = ang_vel or v3()
        self.init_data['loc_vel'] = self.loc_vel.copy()
        self.init_data['ang_vel'] = self.ang_vel.copy()
    def __str__(self):
        return "Loc: {} - {}, Ang: {} - {}".format(self.loc, self.loc_vel, self.ang, self.ang_vel)

def v2(x=None, y=None):
    if y is None:
        if x is None:
            return Vec(0, 0)
        return Vec(x, x)
    return Vec(x or 0, y)

def v3(x=None, y=None, z=None):
    if isinstance(x, Vec):
        (x, y), z = x, y
    elif isinstance(y, Vec):
        y, z = y
    if y is None and z is None:
        if x is None:
            return Vec(0, 0, 0)
        return v3(x, x, x)
    return Vec(x or 0, y or 0, z or 0)

def hypot(*q):
    return sqrt(sum(map(lambda x: x ** 2, q)))

def rot(x, y, a=None):
    if isinstance(x, Vec):
        (x, y), a = x, y
    d = hypot(x, y)
    a = atan2(y, x) + a
    return v2(d * cos(a), d * sin(a))
def rot_XY(p, r):
    k = rot(p.xy, r)
    return v3(k.x, k.y, p.z)
def rot_XZ(p, r):
    k = rot(p.xz, r)
    return v3(k.x, p.y, k.y)
def rot_YZ(p, r):
    k = rot(p.yz, r)
    return v3(p.x, k.x, k.y)

def rotate3(p, R):
    p = p.copy()
    p.setXZ( *rot(p.x, p.z, -R.x) )
    p.setXY( *rot(p.x, p.y, -R.y) )
    p.setYZ( *rot(p.y, p.z,  R.z) )
    p.setXY( *rot(p.x, p.y,  R.y) )
    p.setXZ( *rot(p.x, p.z,  R.x) )
    return p

def rotateAxis(p, V, a):
    return rotate3(p, v3(dirToAng(V), a))

def dirToAng(p):
    return v2(
        atan2(p.z, p.x),
        atan2(p.y, hypot(*p.xz)))

def angsToDir(rots):
    p = v3(1.0, 0.0, 0.0)
    p.setXY(*rot(p.x, p.y, rots.y))
    p.setXZ(*rot(p.x, p.z, rots.x))
    return p

fixmod = lambda x: ((x + PI) % TWO_PI) - PI

def find_euler(p1, p2, p3):
    a = atan2(p2.z, p3.z)
    b = atan2(p1.z, hypot(p2.z, p3.z))
    c = atan2(p1.y, p1.x)
    return v3(a, b, c)

class _BASIS(object):
    def __init__(self):
        self.x = v3(1, 0, 0)
        self.y = v3(0, 1, 0)
        self.z = v3(0, 0, 1)
    def __iter__(self):
        return iter((self.x, self.y, self.z))
    def __getitem__(self, i):
        return list(self)[i]

BASIS = _BASIS()

def app(p1, q):
    p1 = rot_YZ(p1, q.x)
    p1 = rot_XZ(p1, q.y)
    p1 = rot_XY(p1, q.z)
    return p1
    
# for x in [-1, 1]:
#     for y in [-1, 1]:
#         for z in [-1, 1]:
#             w = v3(HALF_PI * 0.95, HALF_PI * 0.95, HALF_PI * 0.95) * v3(x, y, z)
#             print("{} : {}".format(w, find_euler(*(app(i, w) for i in BASIS))))