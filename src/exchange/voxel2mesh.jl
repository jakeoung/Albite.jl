using GeometryTypes

function _add_face!(vv, ff, vert_set, location, v_cnt)
    
    face = [0, 1, 2, 3] .+ v_cnt
    update = 4

    @inbounds for (e, vs) in enumerate(vert_set)
        new_position = vs .+ location
        
        if in(new_position, vv)
            index = findfirst(x -> x == new_position, vv)
            face[e] = index
            
            # decrement other vert indicies
            face[(e+1):4] .-= 1            
            update -= 1
        else
            push!(vv, new_position)
        end
    end

    push!(ff, face)
    v_cnt += update

    return v_cnt
end

"""
    voxel2quad

Convert voxel grid to quad mesh

# Examples
```
voxel = zeros(220,220,220)
voxel[20:150,20:150,20:150] .= 1.0
vv, ff = voxel2quad(voxel, 0.5)
vv = Array{Point{3, Float64}}(vv)
ff = Array{Face{4, Int}}(ff)
ff = quad2trimesh(ff)
# write_obj_quadmesh("1.obj", vv, ff)
# mm = GLNormalMesh(vv, ff)
# Makie.mesh(mm)
```
"""
function voxel2quad(voxel, thresh=0.5, normalize=false)
    voxel_bit_ = voxel .>= thresh
    voxel_bit = zeros(Bool, size(voxel_bit_) .+ 2 )
    voxel_bit[2:end-1, 2:end-1, 2:end-1] .= voxel_bit_
    
    top_verts = ((0, 0, 1), (1, 0, 1), (1, 1, 1), (0, 1, 1))
    bottom_verts = ((0, 0, 0), (0, 1, 0), (1, 1, 0), (1, 0, 0))
    left_verts = ((0, 0, 0), (0, 0, 1), (0, 1, 1), (0, 1, 0))
    right_verts = ((1, 0, 0), (1, 1, 0), (1, 1, 1), (1, 0, 1))
    front_verts = ((0, 0, 0), (1, 0, 0), (1, 0, 1), (0, 0, 1))
    back_verts = ((0, 1, 0), (0, 1, 1), (1, 1, 1), (1, 1, 0))
    vert_sets = (top_verts, bottom_verts, left_verts,
                 right_verts, front_verts, back_verts)

    
    v_cnt = 1
    cartesian_idxs = findall(voxel_bit .== 1)
    @show length(cartesian_idxs)

    vv = Point3{Int32}[]
    ff = Face{4,Int32}[]
    sizehint!(vv, length(cartesian_idxs)*300)
    sizehint!(ff, length(cartesian_idxs)*300)

    @inbounds for (cnt,idx) in enumerate(cartesian_idxs)
        i, j, k = idx.I
        #cnt % 10000 == 0 && println("$cnt")
        
        voxel_bit[i,j,k+1] != 1 && (v_cnt = _add_face!(vv, ff, vert_sets[1], idx.I, v_cnt))
        voxel_bit[i,j,k-1] != 1 && (v_cnt = _add_face!(vv, ff, vert_sets[2], idx.I, v_cnt))
        voxel_bit[i-1,j,k] != 1 && (v_cnt = _add_face!(vv, ff, vert_sets[3], idx.I, v_cnt))
        voxel_bit[i+1,j,k] != 1 && (v_cnt = _add_face!(vv, ff, vert_sets[4], idx.I, v_cnt))
        voxel_bit[i,j-1,k] != 1 && (v_cnt = _add_face!(vv, ff, vert_sets[5], idx.I, v_cnt))
        voxel_bit[i,j+1,k] != 1 && (v_cnt = _add_face!(vv, ff, vert_sets[6], idx.I, v_cnt))
    end

    # if normalize
    #     vv = (vv .- maximum(vv)) ./ (maximum(vv) - minimum(vv))
    # end
    return vv, ff
end

"Convert quad mesh faces to triangular mesh faces"
function quad2trimesh(ff)
    ff_new = Face{3,Int}[]
    sizehint!(ff_new, length(ff)*2)
    for f in ff
        push!(ff_new, [f[1], f[2], f[3]])
        push!(ff_new, [f[1], f[3], f[4]])
    end
    return ff_new
end