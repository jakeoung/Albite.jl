using GeometryTypes
using LinearAlgebra

module Albite

include("meshing/subdivision.jl")
include("meshing/icosphere.jl")
export icosphere

include("IO/obj.jl")
export write_obj

include("ray/grid.jl")
export Grid, cast_ray

include("ray/camera_light.jl")
export Camera, Light
include("ray/render.jl")
export render, fill_bg!

end
