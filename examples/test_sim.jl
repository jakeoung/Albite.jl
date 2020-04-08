using DDG
import TomoForward

include("./fp_mesh.jl")

using FileIO
using MeshIO
using GeometryTypes


mesh = load("/Users/jakoo/Desktop/blender_files/simulate_xray/bunny.obj")
# mesh = load("/Users/jakoo/Desktop/blender_files/simulate_xray/bob.obj")

# decompose(Point3{Float64}, mesh)
vs_ = decompose(Point3{Float64}, mesh)
min_ = minimum(vs_)
max_ = maximum(vs_)
vv = Base.map(x -> (x - min_) ./ (max_ - min_) .* 2 .- 1 , vs_)

# H, W = 10, 10
H, W = 100, 100 # detector size
nangles = 5
angles = LinRange(0, pi, nangles+1)[1:end-1]
proj_geom = TomoForward.ProjGeom(2.5/W, 2.5/H, H, W, angles)

sinogram = fp_mesh(proj_geom, vv, mesh.faces)

# faces_candidate = get_face_candidate(src_pos, ray_dir, root)
using PyPlot
idx=5
imshow(sinogram[idx,:,:])
show()