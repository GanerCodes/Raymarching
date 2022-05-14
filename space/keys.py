class KEY: pass
for i in range(65, 91):
    setattr(KEY,     chr(i), i)
for i in range(48, 58):
    setattr(KEY, '_'+chr(i), i)
KEY.SPACE = 32
KEY.SHIFT = 16
KEY.CTRL  = 17
KEY.LEFT  = 37
KEY.UP    = 38
KEY.RIGHT = 39
KEY.DOWN  = 40
_keys = {}

class __keys:
    def __getattr__(self, name):
        global _keys
        name = getattr(KEY, name)
        return (name in _keys) and _keys[name]
keys = __keys()

def setKey(key, state=True):
    global _keys
    _keys[key] = state