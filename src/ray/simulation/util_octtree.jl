# using RegionTrees # https://github.com/rdeits/RegionTrees.jl
using StaticArrays: SVector
#using GeometryTypes
using GeometricalPredicates
using OctTrees
#include("./raytracing.jl")

# struct MyRefinery <: AbstractRefinery
#     src_pos 
#     ray_dir
# end

# # These two methods are all we need to implement
# function needs_refinement(r::MyRefinery, cell)
#     maximum(cell.boundary.widths) > r.tolerance
# end
# function refine_data(r::MyRefinery, cell::Cell, indices)
#     boundary = child_boundary(cell, indices)
#     "child with widths: $(boundary.widths)"
# end

function get_face_candidate(src_pos, ray_dir, root)
    refinement_queue = (root)
    # face_candidate = Array{GeometryTypes.Face{3,GeometryTypes.OffsetInteger{-1,UInt32}},1}

    face_candidate = ()
    while !isempty(refinement_queue)
        cell = pop!(refinement_queue)
        if isleaf(cell) 
            if ray_bbox_intersect(src_pos, ray_dir, cell.boundary.origin, cell.boundary.origin + cell.boundary.widths)
            # println(typeof(cell.data))
                push!(face_candidate, cell.data)
            end
        else
            for child in cell.children
                ray_bbox_intersect(src_pos, ray_dir, child.boundary.origin, child.boundary.origin+child.boundary.widths)
                # split!(cell, refine_function)
                append!(refinement_queue, children(child))
            end
        end
    end
    return face_candidate
end

"Check if a mesh(vs,fs) is contained by HyperRectangle bbox"
function contained_by(vs, face, bbox)
    vertices3 = vs[face]
    barycenter =  sum(vertices3[1:3]) / 3
    # mean(vertices)
    # vertices3
    if barycenter >= bbox.origin && barycenter <= (bbox.origin + bbox.widths)
        return true
    else
        return false
    end
end

function build_octtree(root, vs, fs)
    # println(length(fs))
    # if length(fs) < 1
    #     root.data = fs[1]
    #     # println("return")
    #     return
    # end
    
    if root.boundary.widths[1] < 0.1 # resolution in the paper
        # leaft node
        # println(fs)
        root.data = fs
        return
    end

    # println("contained")
    cell = split!(root)
    for i=1:8
        # choose the triangles inside cell[i].widths
        # contained_by(fs, cell[i].boundary)
        ids_faces = map(f -> contained_by(vs, f, cell[i].boundary), fs)

        # println(ids_faces, fs[1], fs[ids_faces])
        # return;
        build_octtree(cell[i], vs, fs[ids_faces])
    end
end