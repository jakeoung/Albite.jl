using DDG
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

img = render(mesh, camera, light)

bg = Vec3([0.3, 0.3, 0.5])
fill_bg!(img, bg)

using PyPlot
@show maximum(img)

img_normalized = img / maximum(img)
# img_normalized[img .== 0.0] .= 1.0
imshow(permutedims(img_normalized, [2,3,1]))
