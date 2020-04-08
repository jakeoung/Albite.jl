using GeometryTypes
using LinearAlgebra

module DDG

include("meshing/subdivision.jl")
include("meshing/icosphere.jl")
export icosphere

include("IO/obj.jl")
export write_obj

include("ray/grid.jl")
export Grid, cast_ray

end
