class Vec(PVector):
    def __init__(self, *args):
        self.dimensions = len(args)
        PVector.__init__(self, *args)
    def __str__(self):
        return "<{}>".format(', '.join(map(lambda x: str(round(x, 4)), self)))
    def __iter__(self):
        l = [self.x, self.y]
        if self.dimensions > 2:
            l += [self.z]
        return iter(l)
    def __getattribute__(self, name):
        if 4 > len(name) > 1 and not len(set(name).difference(set('xyz'))):
            return Vec(*(getattr(self, i) for i in name))
        return PVector.__getattribute__(self, name)
    def setXY(self, x, y):
        self.x, self.y = x, y
    def setXZ(self, x, z):
        self.x, self.z = x, z
    def setYZ(self, y, z):
        self.y, self.z = y, z

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
    if y is None and z is None:
        if x is None:
            return Vec(0, 0, 0)
        return v3(x, x, x)
    return Vec(x or 0, y or 0, z or 0)

def hypot(*q):
    return sqrt(sum(map(lambda x: x ** 2, q)))

def rot(x, y, a):
    d = hypot(x, y)
    a = atan2(y, x) + a
    return (d * cos(a), d * sin(a))

def rotate3d(p, R):
    p.setXZ( *rot(p.x, p.z, -R.x) )
    p.setXY( *rot(p.x, p.y, -R.y) )
    p.setYZ( *rot(p.y, p.z,  R.z) )
    p.setXY( *rot(p.x, p.y,  R.y) )
    p.setXZ( *rot(p.x, p.z,  R.x) )
    return p

def dirToAng(p):
    return v2(
        atan2(p.z, p.x),
        atan2(p.y, hypot(*p.xz)))