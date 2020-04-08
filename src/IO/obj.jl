using GeometryTypes

function write_obj(fname::String, vv::Array, ff::Array)
   io = open(fname, "w")

   if length(size(vv)) == 2
       mapslices(v -> println(io, "v $(v[1]) $(v[2]) $(v[3])"), vv, dims=[2])
       mapslices(f -> println(io, "f $(f[1]) $(f[2]) $(f[3])"), ff, dims=[2])
   else
       map(v -> println(io, "v $(v[1]) $(v[2]) $(v[3])"), vv)
       map(f -> println(io, "f $(f[1]) $(f[2]) $(f[3])"), ff)    
   end
   close(io)
end

# read obj file with the support of multiple materials
# partiall ported from https://github.com/ericjang/WavefrontOBJs.jl/blob/master/src/obj.jl
function read_obj_ctdr(fname::String)
   io = open(fname, "r")

   vv = Point3{Float64}[]
   ff = Face{3,Int64}[]

   meshes = []

   v_now = 0

   for line in eachline(io)
      tokens = split(line)
      
      type = tokens[1]
      if type == "o"
         if length(vv) > 0
            push!(meshes, GLNormalMesh(vv, ff .- v_now))
            v_now += length(vv)
         end
         vv = Point3{Float64}[]
         ff = Face{3,Int64}[]
      
      elseif type == "v"
         push!(vv, Point3( [parse(Float64, tokens[i]) for i=2:4] ))

      elseif type == "f"
         push!(ff, Point3( [parse(Int, tokens[i]) for i=2:4] ))

      end
   end
   println(v_now)
   push!(meshes, GLNormalMesh(vv, ff .- v_now))
   return meshes
end

# test
"""
meshes = read_obj_ctdr("/Users/jakoo/work/ctdr/result/3nanoC/08-algo_ctdr_-b_0_-eta_0_-lr_0.0025_-niter_300_-niter0_50_-nmu0_1_-subdiv_3_-wedge_5.0_-wflat_0.0_-wlap_20.0_/0299.obj")

using CairoMakie, Makie, FileIO
CairoMakie.activate!()

mesh(meshes[2], color=:red, transparency=false)
mesh!(meshes[1], color=:lightgreen, alpha = 0.5, transparency=true)

# pos = map(meshes[1].vertices, meshes[1].normals) do p, n
#    p => p .+ (normalize(n) .* 0.05f0)
# end
# linesegments!(pos, color = :blue)

FileIO.save("/Users/jakoo/Desktop/agau_render.png")
#Makie.save("/Users/jakoo/Desktop/agau_render.pdf", scene)
"""