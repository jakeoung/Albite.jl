using GeometryTypes
using LinearAlgebra

module Albite

include("meshing/subdivision.jl")
include("meshing/icosphere.jl")
export icosphere

include("exchange/obj.jl")
include("exchange/voxel2mesh.jl")
export write_obj, voxel2quad, quad2trimesh

include("ray/grid.jl")
export Grid, cast_ray

include("ray/scene.jl")
export Camera, Light
include("ray/render.jl")
export render, fill_bg!

end
