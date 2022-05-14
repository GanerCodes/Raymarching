import java.lang.RuntimeException

refresh_shader_prompt = True
shaderReloadTime = 0
shade = None
tmp_shader_name = str(sketchPath("gen/SHADER_COMPILED.glsl"))

def create_main_shader(file_name=tmp_shader_name, shader_list_file="file_list.txt"):
    try:
        with open(shader_list_file) as f:
            shader_list = ['./data/{}'.format(i.strip()) for i in f.readlines() if i.strip()]
    except Exception as e:
        print("Error reading shader list! {}".format(e))
    
    try:
        with open(file_name, 'w') as f:
            f.write("// This is an AUTOGENERATED file, do not edit!\n\n\n\n")
            for shade_name in shader_list:
                f.write("////////// {} //////////\n\n".format(shade_name))
                try:
                    with open(shade_name, 'r') as part:
                        f.write(part.read() + '\n\n')
                except Exception as e:
                    print('Error reading from "{}"! {}'.format(shade_name, e))
    except Exception as e:
        print("Error reading shader list! {}".format(e))
    

def sendPara(shade):
    shade.set("u_resolution", float(width), float(height))
    shade.set("u_time", 0.001 * timeScale * millis())
    shade.set("vp_loc", *camera.loc)
    shade.set("vp_ang", *camera.ang)
    shade.set("play_loc", *player.loc)
    shade.set("play_quat", *player.ang)

def check_shader():
    global refresh_shader_prompt, shaderReloadTime, tmp_shader_name, shade
    if millis() >= shaderReloadTime:
        shaderReloadTime = millis() + 1000
        try:
            create_main_shader(tmp_shader_name)
            shade_temp = loadShader(tmp_shader_name)
            shade_temp.create()
            shade_temp.compile()
            if len(shade_temp.fragmentShaderSource) <= 12:
                raise java.lang.RuntimeException("Shader too short to compile.")
            shade = loadShader(tmp_shader_name)
            shade.set("u_resolution", float(width), float(height))
        except java.lang.RuntimeException as err:
            print("Error compiling shader! {}".format(err))
            refresh_shader_prompt = True
            shade = None
            return
    if not shade:
        return
    
    if refresh_shader_prompt:
        print("Sucessfully compiled shader!")
        refresh_shader_prompt = False
    return shade