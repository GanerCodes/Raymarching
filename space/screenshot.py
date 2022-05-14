def screenshot(res, upscale):
    global sendPara
    
    newBuf = createGraphics(int(upscale * res[0]), int(upscale * res[1]), P2D)
    newBuf.beginDraw()
    newBuf.endDraw()
    sendPara(shade)
    newBuf.filter(shade)
            
    finalBuf = createGraphics(res[0], res[1], P2D)
    finalBuf.beginDraw()
    finalBuf.image(newBuf, 0, 0, res[0], res[1])
    finalBuf.save("gen/screenshot_{}.png".format(int(1000 * Time.time())))
    finalBuf.endDraw()
    print("Screenshot saved!")