using GeometryTypes

function get_edges_id(ff)
    eids = []
    for (i, f) in enumerate(ff)
        f1, f2, f3 = (sort(Int.([f[1], f[2], f[3]])))
        ~in((f1, f2), eids) && push!(eids, (f1, f2))
        ~in((f1, f3), eids) && push!(eids, (f1, f3))
        ~in((f2, f3), eids) && push!(eids, (f2, f3))
    end
    return eids
end

function construct_A0()
end

function construct_A1()
end

using Meshing
using FileIO # MeshIO should also be installed

gyroid(v) = cos(v[1])*sin(v[2])+cos(v[2])*sin(v[3])+cos(v[3])*sin(v[1])
gyroid_shell(v) = max(gyroid(v)-0.4,-gyroid(v)-0.4)

# gyroid_shell(v) = sum(v .^ 2) .- 4.0

# generate directly using GeometryTypes API, normals are computed by GeometryTypes
trimesh = GLNormalMesh(gyroid_shell, HyperRectangle(Vec(0,0,0),Vec(pi*4,pi*4,pi*4)),
                       MarchingCubes(), samples=(10,10,10))

eids = get_edges_id(trimesh.faces)