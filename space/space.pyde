import java.lang.RuntimeException
import time, os
from vectors import *
from quaternions import *
from keys import *

FPS = 120
upscale = 0.5
timeScale = 1
screenshotUpscale = 2.5
screenshotRes = (3840, 2160)
camera = Obj3d(v3(2, 1, 0), v2(0, 0))
player = Player3d(v3(0, 1, 0), quat(0, 1, 0))
mode = "camera"

if not os.path.isdir("gen"):
    os.mkdir("gen")

shaderReloadTime = 0
canMoveCameraAngle = True
shade = None

tmp_shader_name = str(sketchPath("gen/SHADER_COMPILED.glsl"))

def create_main_shader(file_name=tmp_shader_name, shader_list_file="file_list.txt"):
    with open(shader_list_file) as f:
        shader_list = ['./data/{}'.format(i.strip()) for i in f.readlines() if i.strip()]
    
    with open(file_name, 'w') as f:
        f.write("// This is an AUTOGENERATED file, do not edit!\n\n\n\n")
        for shade_name in shader_list:
            f.write("////////// {} //////////\n\n".format(shade_name))
            with open(shade_name, 'r') as part:
                f.write(part.read() + '\n\n')

def sendPara(shade):
    shade.set("u_resolution", float(width), float(height))
    shade.set("u_time", 0.001 * timeScale * millis())
    shade.set("vp_loc", *camera.loc)
    shade.set("vp_ang", *camera.ang)
    shade.set("play_loc", *player.loc)
    shade.set("play_quat", *player.ang)

def setup():
    global buffer, upscale, mouse_pos
    fullScreen(P2D)
    # size(1664, 936, P2D)
    
    textFont(createFont("Monospaced", 12))
    
    mouse_pos = v2(width / 2, height / 2)
    frameRate(FPS)
    buffer = createGraphics(int(width * upscale), int(height * upscale), P2D)

up = 0
def draw():
    global shade, vp_loc, vp_ang, shaderReloadTime, bruh, up
    m = millis()
    tick = m >= up
    if tick: up = m + 1000 / 75
    
    if millis() >= shaderReloadTime:
        shaderReloadTime = millis() + 1000
        try:
            create_main_shader()
            shade_temp = loadShader(tmp_shader_name)
            shade_temp.create()
            shade_temp.compile()
            if len(shade_temp.fragmentShaderSource) <= 12:
                raise java.lang.RuntimeException("Shader too short to compile.")
            shade = loadShader(tmp_shader_name)
            shade.set("u_resolution", float(width), float(height))
        except java.lang.RuntimeException as err:
            print("Error compiling shader! {}".format(err))
            return
        
        # print("Sucessfully compiled shader!")
    
    if not shade:
        return
    
    if canMoveCameraAngle:
        mouse_pos.add(v2(mouseX - pmouseX, mouseY - pmouseY))
        mouse_pos.y = constrain(mouse_pos.y, 0, height)
        camera.ang = v2(
            map(mouse_pos.x, 0, width , -PI, PI),
            map(mouse_pos.y, 0, height, -PI / 2.0, PI / 2.0))
    
    if mode == "camera":    
        moveVec = v3(0, 0, 0)
        if hasKey(Key.W):
            moveVec.add(v3( 0,  0, -1))
        if hasKey(Key.S):
            moveVec.add(v3( 0,  0,  1))
        if hasKey(Key.A):
            moveVec.add(v3(-1,  0,  0))
        if hasKey(Key.D):
            moveVec.add(v3( 1,  0,  0))
        moveVec = rot_XZ(rot_YZ(moveVec, -camera.ang.y), camera.ang.x)
        if hasKey(Key.SPACE):
            moveVec.add(v3( 0,  1,  0))
        if hasKey(Key.SHIFT):
            moveVec.add(v3( 0, -1,  0))
        camera.loc.add(moveVec.setMag((25.0 if hasKey(Key.CTRL) else 5.0) / frameRate))
    elif mode == "player" and tick:
        ang_speed = 0.01
        if hasKey(Key.D):
            player.ang_vel.x += ang_speed
        if hasKey(Key.A):
            player.ang_vel.x -= ang_speed
        if hasKey(Key.W):
            player.ang_vel.z -= ang_speed
        if hasKey(Key.S):
            player.ang_vel.z += ang_speed
        if hasKey(Key.RIGHT):
            player.ang_vel.y -= ang_speed
        if hasKey(Key.LEFT):
            player.ang_vel.y += ang_speed
        if hasKey(Key.UP):
            player.loc_vel += 0.02 * (quat_rot_axis(v3(1,0,0), HALF_PI) * player.ang).dir().norm()
    
    if tick:
        player.loc += player.loc_vel
        camera.loc = player.loc + v3(2.2, 2.2, 0)
        if player.loc.y < 0:
            player.loc_vel.y += 0.1 * min(1, -player.loc.y)
            player.loc.y *= 0.99
        else:
            player.loc_vel.y -= 0.012
        
        player.ang = quat_rot_axis(BASIS.x, player.ang_vel.x) * player.ang
        player.ang = quat_rot_axis(BASIS.y, player.ang_vel.y) * player.ang
        player.ang = quat_rot_axis(BASIS.z, player.ang_vel.z) * player.ang
        
        player.loc_vel.x *= 0.975
        player.loc_vel.z *= 0.975
        player.ang_vel = player.ang_vel * (v3(0.95 - hypot(*player.ang_vel)))
    
    sendPara(shade)
    buffer.filter(shade)
    
    image(buffer, 0, 0, width, height)
    fill(255, 0, 0)
    text("FPS: {}\nCamera: {}\nPlayer: {}".format(frameRate, camera, player), 0, 10)
    
def keyPressed():
    global keys, mode, camera
    keys[keyCode] = True
    if hasKey(Key.R):
        camera.loc = v3(0, 0, 0)
        player.loc = v3(0, 1, 0)
    elif hasKey(Key.Q):
        mode = ("camera", "player")[mode == "camera"]

bruh = 0
def keyReleased():
    global keys, vp_loc, bruh
    if hasKey(Key.P):
        newBuf = createGraphics(
            int(screenshotUpscale * screenshotRes[0]),
            int(screenshotUpscale * screenshotRes[0]),
            P2D)
        
        newBuf.beginDraw()
        newBuf.endDraw()
        sendPara(shade)
        newBuf.filter(shade)
        
        finalBuf = createGraphics(screenshotRes[0], screenshotRes[1], P2D)
        finalBuf.beginDraw()
        finalBuf.image(newBuf, 0, 0, screenshotRes[0], screenshotRes[1])
        finalBuf.save("gen/screenshot_{}.png".format(int(1000 * time.time())))
        finalBuf.endDraw()
        print("Screenshot saved!")
    if hasKey(Key.K):
        bruh = QUARTER_PI
    keys[keyCode] = False

def mouseClicked():
    global canMoveCameraAngle
    if mouseButton == CENTER:
        canMoveCameraAngle = not canMoveCameraAngle
        print("canMoveCameraAngle = " + str(canMoveCameraAngle))