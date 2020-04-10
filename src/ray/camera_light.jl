module CameraLight
using LinearAlgebra
using GeometryTypes

export Camera
export Light, PointLight, illuminate

"Make a lookat matrix (camera2world)"
function lookat(from, to; homogeneous=false)
    tmp = Vec3(0, 1.0, 0)
    forward = normalize(to - from)
    # forward = -normalize(from - to)
    right = normalize(cross(tmp, forward))
    up = cross(forward, right)
    
    if homogeneous == true
        return Mat4(
            right[1], up[1], forward[1], from[1],
            right[2], up[2], forward[2], from[2],
            right[3], up[3], forward[3], from[3],
            0, 0, 0, 1 )
    else
        return Mat3(
            right[1], up[1], forward[1],
            right[2], up[2], forward[2],
            right[3], up[3], forward[3] )
    end    
end

struct Camera
    H
    W
    aspect
    R
    T    
    fov
end

function Camera(H, W, from, to=Vec3(0.0,0,0), fov=90)
    R = lookat(from, to)
    T = from
    aspect = W / H
    return Camera(H, W, aspect, R, T, fov)
end



abstract type Light end

"""
    DistantLight
"""
struct DistantLight <: Light
    pos
    color
    intensity
    dir
end

"Construct PointLight with the position and color"
function Light(pos, color, dir)
    I = 1.0
    return PointLight(pos, color, I, dir)
end

"Illuminate distant light (second parameter is obsolote"
function illuminate(light::DistantLight, p)
    I = light.intensity * light.color / pi
    return light.dir, I, Inf
end


"""
    PointLight
"""
struct PointLight <: Light
    pos
    color
    intensity
end

"Construct PointLight with the position and color"
function Light(pos, color=Vec3(1.0, 1.0, 1.0))
    I = 1.0
    return PointLight(pos, color, I)
end

"Compute L, the light ray direction"
function illuminate(light::PointLight, p)
    dir_original = p - light.pos
    r2 = sum(dir_original .^ 2)
    r  = sqrt(r2)
    dir = dir_original / r
    I = light.intensity * light.color / ( 4 * pi * r2 )

    return dir, I, r
end

end