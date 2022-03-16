# from collections import namedtuple

# class Vector:
#     def __init__(self, n, *kwargs):
#         self.x, self.y, self.z, self.w = list(kwargs) + [None] * (4 - len(kwargs))
#         self.n = n
#         self.d = {}
#         for i in "xyzw"[:n]:
#             self.d[i] = eval("self." + i)
    
#     def __str__(self):
#         return "vec{}{{{}}}".format(
#             self.n,
#             ', '.join(str(i) for i in self.d.values())
#         )
    

# vec2 = lambda x=0,y=0: Vector(2, x, y)
# vec3 = lambda x=0,y=0,z=0: Vector(3, x, y, z)
# vec4 = lambda x=0,y=0,z=0,w=0: Vector(4, x, y, z, w)

# print(vec4(1, 2, 3, 4))

