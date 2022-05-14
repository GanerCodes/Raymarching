from quaternions import *
from vectors import *

def physics(dt, player, camera):
    player.loc += dt * player.loc_vel
    player.ang = quat_rot_axis(player.ang_vel, dt * hypot(*player.ang_vel)) * player.ang
    
    if player.loc.y < 0:
        player.loc.y *= exp(-4.0 * dt)
        player.loc_vel.y += dt * 60.0
    else:
        player.loc_vel.y -= 20.0 * dt
    
    av1, av2 = exp(-5.00 * dt), exp(-4.50 * dt)
    player.ang_vel *= v3(av1, av2, av1)
    lv1, lv2 = exp(-0.25 * dt), exp(-0.01 * dt)
    player.loc_vel *= v3(lv1, lv2, lv1)
    
    # camera.loc = player.loc + v3(-3.25, 2.5, 0)