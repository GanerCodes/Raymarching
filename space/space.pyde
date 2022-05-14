import time as Time, os
from vectors import *
from quaternions import *
from keys import *
from physics import *
for filename in ('shader.py', 'screenshot.py'):
    exec(open(filename).read())

FPS = 90
timeScale = 1
upscale = 0.5
screenshotUpscale = 2.5
screenshotRes = (3840, 2160)
mode = "camera"
props = {'c_l': v3(0, 0, 0),
         'c_a': v2(0, 0),
         'p_l': v3(2, 1, 0),
         'p_a': quat(0, -1, 0)}

camera = Obj3d   (props['c_l'], props['c_a'])
player = Player3d(props['p_l'], props['p_a'])
canMoveCameraAngle = True
time = 0

if not os.path.isdir("gen"):
    os.mkdir("gen")

def BAZ(a, b=1):
    return b if a else 0

def set_FPS(fps):
    global FPS
    if FPS != fps:
        FPS = fps
        frameRate(FPS)

def setup():
    global buffer, upscale, mouse_pos, time
    # fullScreen(P2D)
    size(1664, 936, P2D)
    set_FPS(FPS)
    
    textFont(createFont("Monospaced", 12))
    
    mouse_pos = v2(mouseX, mouseY)
    buffer = createGraphics(int(width * upscale), int(height * upscale), P2D)
    time = Time.time()

def draw():
    global time
    
    _time = Time.time()
    dt = _time - time
    time = _time
    
    shade = check_shader()
    if not shade: return
    
    if canMoveCameraAngle:
        mouse_pos.add(v2(mouseX - pmouseX, mouseY - pmouseY))
        mouse_pos.y = constrain(mouse_pos.y, 0, height)
        camera.ang = v2(
            map(mouse_pos.x, 0, width , -PI, PI),
            map(mouse_pos.y, 0, height, -PI / 2.0, PI / 2.0))
    
    if mode == "camera":    
        camera.loc.add((rot_XZ(rot_YZ(v3(keys.D - keys.A, 0.0, keys.S - keys.W), -camera.ang.y), camera.ang.x) + BASIS.y * (keys.SPACE - keys.SHIFT)).setMag(dt * (25.0 if keys.CTRL else 5.0)))
    elif mode == "player":
        ang_speed = 30.00 * dt
        vel_speed = 25.00 * dt
        
        player.ang_vel += v3(keys.D - keys.A,
                             keys.LEFT - keys.RIGHT,
                             keys.S - keys.W).setMag(ang_speed)
        
        if keys.UP:
            player.loc_vel += vel_speed * (quat_rot_axis(v3(1,0,0), HALF_PI) * player.ang).dirn()
    
    physics(dt, player=player, camera=camera)
    
    sendPara(shade)
    buffer.filter(shade)
    
    image(buffer, 0, 0, width, height)
    fill(255, 0, 0)
    text("FPS: {} (dt: {})\nCamera: {}\nPlayer: {}\nUpscale: {}".format(frameRate, dt, camera, player, upscale), 0, 10)
    
def keyPressed():
    global upscale, keys, buffer, mode
    setKey(keyCode, True)
    
    if keyCode == KEY.R:
        camera.loc, camera.ang = props['c_l'], props['c_a']
        player.loc, player.ang = props['p_l'], props['p_a']
        return
    if keyCode == KEY.Q:
        mode = ("camera", "player")[mode == "camera"]
        return
    if keyCode == KEY.P:
        screenshot(screenshotRes, screenshotUpscale)
        return
    
    if keyCode == KEY._1:
        set_FPS(30)
        return
    if keyCode == KEY._2:
        set_FPS(90)
        return
    if keyCode == KEY._3:
        set_FPS(240)
        return
    if keyCode == KEY._0:
        set_FPS(1000)
        return
    
    if keyCode in (93, 91):
        buffer = createGraphics(int(width * upscale), int(height * upscale), P2D)
        if keyCode == 93:
            upscale *= 2
            return
        if keyCode == 91:
            upscale /= 2
            return
    
def keyReleased():
    global keys
    setKey(keyCode, False)

def mouseClicked():
    global canMoveCameraAngle
    if mouseButton == CENTER:
        canMoveCameraAngle = not canMoveCameraAngle
        print("canMoveCameraAngle = " + str(canMoveCameraAngle))