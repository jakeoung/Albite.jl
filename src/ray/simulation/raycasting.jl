"""
For better understanding ray tracing methods
"""

# module raycasting
export ray_triangle_intersect, ray_bbox_intersect, cast_ray
using LinearAlgebra

"""
    function ray_triangle_intersect(src, ray, v1, v2, v3) 

Check the intersection of a ray and the triangle based on Möller-Trumbore algorithm. It reformulates the problem into 3x3 matrix form and uses Crammer's rule.

Möller, T., Trumbore, B., 1997. Fast, minimum storage ray-triangle intersection. Journal of graphics tools 2, 21–28.

See also https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle/moller-trumbore-ray-triangle-intersection
"""
function ray_triangle_intersect(src, ray, v1, v2, v3)

    v12 = v2 - v1
    v13 = v3 - v1
    pvec = cross(ray, v13)
    det = dot(v12, pvec)

    if abs(det) < 1e-8 # note that for back-facing culling, we omit abs
        return false, -1.0
    end

    inv_det = 1.0 / det
    tvec = src - v1
    u = dot(tvec, pvec) * inv_det
    if u < 0 || u > 1
        return false, -1.0
    end

    q = cross(tvec, v12)
    v = dot(ray, q) * inv_det
    if v < 0 || (u+v) > 1
        return false, -1.0
    end

    t = dot(v13, q) * inv_det
    if t < 0.0
        return false, -1.0
    end
    return true, t
end

function ray_bbox_intersect(src, ray, bb_min, bb_max)
    # bb_min = bbox.origin
    # bb_max = bbox.origin + bbox.widths
    invray = 1.0 ./ (ray .+ eps())
    if ray[1] < 0
        tmin = (bb_max[1] - src[1]) * invray[1]
        tmax = (bb_min[1] - src[1]) * invray[1]
    else
        tmin = (bb_min[1] - src[1]) * invray[1]
        tmax = (bb_max[1] - src[1]) * invray[1]
    end

    if ray[2] < 0
        tymin = (bb_max[2] - src[2]) * invray[2]
        tymax = (bb_min[2] - src[2]) * invray[2]
    else
        tymin = (bb_min[2] - src[2]) * invray[2]
        tymax = (bb_max[2] - src[2]) * invray[2]
    end

    if tmin > tymax || tymin > tmax
        return false
    end
    if tymin > tmin
        tmin = tymin
    end
    if tymax < tmax
        tmax = tymax
    end
    
    if ray[3] < 0
        tzmin = (bb_max[3] - src[3]) * invray[3]
        tzmax = (bb_min[3] - src[3]) * invray[3]
    else
        tzmin = (bb_min[3] - src[3]) * invray[3]
        tzmax = (bb_max[3] - src[3]) * invray[3]
    end

    if tmin > tzmax || tzmin > tmax
        return false
    end
 
    return true; 
end

function cast_ray(src, ray, vertices, faces_list::Array{Any,1})
    t_near = 1e8

    for faces in faces_list
        for f in faces
            v1 = vertices[f[1]]
            v2 = vertices[f[2]]
            v3 = vertices[f[3]]

            
            is_hit, t = ray_triangle_intersect(src, ray, v1, v2, v3)

            # println(is_hit, t)
            if is_hit == true && t < t_near
                t_near = t
                # println(src, ray, v1, v2, v3)

            end
        end
    end
    if t_near < 1e8-2*eps()
        return true, t_near
    else
        return false, -1.0
    end

end

function cast_ray(src, ray, vertices, faces)
    
    t_near = 1e8

    for f in faces
        v1 = vertices[f[1]]
        v2 = vertices[f[2]]
        v3 = vertices[f[3]]

        
        is_hit, t = ray_triangle_intersect(src, ray, v1, v2, v3)

        # println(is_hit, t)
        if is_hit == true && t < t_near
            t_near = t
            println(src, ray, v1, v2, v3)

        end
    end

    if t_near < 1e8-2*eps()
        return true, t_near
    else
        return false, -1.0
    end
end

# end