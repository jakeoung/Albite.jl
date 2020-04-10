using LinearAlgebra

# include("./camera_light.jl")
using .CameraLight

function get_barycentric(p, v1, v2, v3)
    area = norm(cross(v3-v1, v3-v2))
    w1 = norm(cross(v3-p, v2-p)) / area
    w2 = norm(cross(v1-p, v3-p)) / area
    return w1, w2, 1.0 - w1-w2
end

function render(mesh, camera, light::T, albedo=0.18) where T <: Light
    vv, ff, nn = mesh.vertices, mesh.faces, mesh.normals
    grid = Grid(vv, ff)

    ray_origin = Vec3(0.0, 0, 0.0)
    orig = camera.R * ray_origin + camera.T

    scale = tan(deg2rad(camera.fov*0.5))

    buffer = zeros(3, camera.H, camera.W)
    for w=1:camera.W
        Threads.@threads for h=1:camera.H
            # generate primary ray direction
            x = (2.0*(w - 0.5) / camera.W - 1.0) * camera.aspect * scale
            y = (1.0 - 2.0*(h - 0.5) / camera.H) * scale

            ray = normalize(camera.R * Vec3(x, y, -1))
            t, iface = cast_ray(grid, orig, ray, culling=true)

            # @show ray_origin_world, ray_world
            if t < Inf
                # compute normal
                ndot = 1.0

                p = orig + t*ray
                v1, v2, v3 = vv[ff[iface]]
                w1, w2, w3 = get_barycentric(p, v1, v2, v3)
                n1, n2, n3 = nn[ff[iface]]
                nhit = w1*n1 + w2*n2 + w3*n3

                L, I, dist = illuminate(light, p) 
                
                buffer[1:3, h, w] .= albedo * I * max(0.0, dot(nhit, -L))

                # ndot = max(dot(nhit, -ray), 0.0)
                # buffer[1:3, h, w] .= 1.0 * ndot
            end
        end
    end
    return buffer
end

"Fill the background of the image [3 x H x W]"
function fill_bg!(img, bg, normalize=true)
    scale = 1.0
    if normalize
        scale = maximum(img)
    end
    for w=1:size(img, 3)
        for h=1:size(img, 2)
            if sum(img[:,h,w]) == 0
                img[:,h,w] .= bg * scale
            end
        end
    end    
end

"""
using FileIO
using MeshIO
using GeometryTypes

H, W = 200, 200
# mesh = load("/Users/jakoo/Desktop/blender_files/simulate_xray/bunny.obj")
mesh = load("/Users/jakoo/Desktop/0199.obj")

fov = 40
from = Vec3(3, 0.0, 0.0)
to = Vec3(0.0)
camera = Camera( H, W, from, to, fov)

light = Light(from) # PointLight

img = render(mesh, camera, light, bg)

bg = Vec3([0.3, 0.3, 0.5])
fill_bg!(img, bg)

using PyPlot
@show maximum(img)

img_normalized = img / maximum(img)
# img_normalized[img .== 0.0] .= 1.0
imshow(permutedims(img_normalized, [2,3,1]))
"""