FPS = 60

def setup():
    global shade, buffer
    size(750, 750, P2D)
    frameRate(FPS)
    buffer = createGraphics(int(width * 1.5), int(height * 1.5), P2D)
    shade = None

def draw():
    global shade
    if shade is None or frameCount % FPS == 0:
        try:
            shade = loadShader("shader.glsl")
        except:
            return
    shade.set("u_resolution", float(width), float(height))
    shade.set("u_mouse", float(mouseX), float(mouseY))
    shade.set("u_time", millis() / 1000.0)
    buffer.filter(shade)
    image(buffer, 0, 0, width, height)
    fill(255, 0, 0)
    text(frameRate, 0, 10)