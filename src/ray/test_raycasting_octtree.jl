import TomoForward

include("simulation/util_octtree_old.jl")
include("simulation/raycasting.jl")
include("simulation/fp_mesh.jl")

using FileIO
using MeshIO

mesh = load("/Users/jakoo/Desktop/blender_files/star_shaped.obj")

vs_ = decompose(Point3{Float64}, mesh)
min_ = minimum(vs_)
max_ = maximum(vs_)
max_width = 1.0
vv = Base.map(x -> (x - min_) ./ (max_ - min_) .* max_width .- max_width/2.0 , vs_)

# global root
orig = SVector(1.0, 1.0, 1.0) * -1.0
root = Cell(orig, SVector(2.0, 2, 2), [])
# root = OctTree(100)
build_octtree(root, vv, mesh.faces)
println("done building oct tree.")

H, W = 100, 100
# H, W = 10, 10 # detector size
nangles = 1
angles = LinRange(0, pi, nangles+1)[1:end-1]
proj_geom = TomoForward.ProjGeom(2.0/W, 2.0/H, H, W, angles)

sinogram = fp_mesh(proj_geom, root, vv, mesh.faces)

# faces_candidate = get_face_candidate(src_pos, ray_dir, root)
using PyPlot
idx=1
imshow(sinogram[idx,:,:])
show()