import java.lang.RuntimeException

FPS = 75
timeScale = 1

vp_loc = PVector(0, 0, 25)
vp_ang = PVector(0, 0)

shaderReloadTime = 0
canMoveCameraAngle = True
shade = None
keys = {}

def rot_XZ(p, r):
    return PVector(p.x*cos(r)-p.z*sin(r), p.y, p.x*sin(r)+p.z*cos(r))
def rot_YZ(p, r):
    return PVector(p.x, p.y*cos(r)-p.z*sin(r), p.y*sin(r)+p.z*cos(r))

def hasKey(key):
    global keys
    return key in keys and keys[key]

def setup():
    global buffer, mouse_pos
    # fullScreen(P2D)
    size(1500, 900, P2D)
    upscale = 1
    
    mouse_pos = PVector(width / 2, height / 2)
    frameRate(FPS)
    buffer = createGraphics(int(width * upscale), int(height * upscale), P2D)

def draw():
    global shade, vp_loc, vp_ang, shaderReloadTime
    
    if millis() >= shaderReloadTime:
        shaderReloadTime = millis() + 1000
        try:
            shade_temp = loadShader("shader.glsl")
            shade_temp.create()
            shade_temp.compile()
            if len(shade_temp.fragmentShaderSource) <= 12:
                raise java.lang.RuntimeException("Shader too short to compile.")
            shade = loadShader("shader.glsl")
        except java.lang.RuntimeException as err:
            print("Error compiling shader! {}".format(err))
            return

    shade.set("u_resolution", float(width), float(height))
    shade.set("u_time", 0.001 * timeScale * millis())
    
    if canMoveCameraAngle:
        mouse_pos.add(PVector(mouseX - pmouseX, mouseY - pmouseY))
        
        mouse_pos.y = constrain(mouse_pos.y, 0, height)
        
        vp_ang = PVector(
            map(mouse_pos.x, 0, width , -PI, PI),
            map(mouse_pos.y, 0, height, -PI / 2.0, PI / 2.0)
        )
    
    shade.set("vp_ang", vp_ang.x, vp_ang.y)
    shade.set("vp_loc", vp_loc.x, vp_loc.y, vp_loc.z)
    
    buffer.filter(shade)
    
    image(buffer, 0, 0, width, height)
    fill(255, 0, 0)
    text(frameRate, 0, 10)
    
    moveVec = PVector(0, 0, 0)
    if hasKey(87):
        moveVec.add(PVector( 0,  0, -1))
    if hasKey(83):
        moveVec.add(PVector( 0,  0,  1))
    if hasKey(65):
        moveVec.add(PVector(-1,  0,  0))
    if hasKey(68):
        moveVec.add(PVector( 1,  0,  0))
    
    moveVec = rot_XZ(rot_YZ(moveVec, -vp_ang.y), vp_ang.x)
    
    if hasKey(32):
        moveVec.add(PVector( 0,  1,  0))
    if hasKey(16):
        moveVec.add(PVector( 0, -1,  0))
    
    vp_loc.add(moveVec.setMag((25.0 if hasKey(17) else 5.0) / frameRate))

def keyPressed():
    global keys, canMoveCameraAngle
    keys[keyCode] = True
    if hasKey(82):
        canMoveCameraAngle = not canMoveCameraAngle

def keyReleased():
    global keys
    keys[keyCode] = False

def mouseClicked():
    global canMoveCameraAngle
    if mouseButton == CENTER:
        canMoveCameraAngle = not canMoveCameraAngle