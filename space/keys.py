class Key: pass
for i in range(65, 91):
    setattr(Key,     chr(i), i)
for i in range(48, 58):
    setattr(Key, '_'+chr(i), i)
Key.SPACE = 32
Key.SHIFT = 16
Key.CTRL  = 17
Key.LEFT  = 37
Key.UP    = 38
Key.RIGHT = 39
Key.DOWN  = 40
keys = {}

def hasKey(key):
    global keys
    return key in keys and keys[key]