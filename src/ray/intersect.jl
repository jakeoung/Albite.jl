
"""
    function ray_triangle_intersect(src, ray, v1, v2, v3) 

Check the intersection of a ray and the triangle based on Möller-Trumbore algorithm. It reformulates the problem into 3x3 matrix form and uses Crammer's rule.

Möller, T., Trumbore, B., 1997. Fast, minimum storage ray-triangle intersection. Journal of graphics tools 2, 21–28.

See also https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle/moller-trumbore-ray-triangle-intersection
"""
function ray_triangle_intersect(src, ray, v1, v2, v3, culling=false; allow_negative=false)

    v12 = v2 - v1
    v13 = v3 - v1
    pvec = cross(ray, v13)
    det = dot(v12, pvec)

    culling && det < 0.0 && return Inf

    if abs(det) < eps(Float32) # parallel case
        # println("parallel")
        return Inf
    end

    inv_det = 1.0 / det
    tvec = src - v1
    u = dot(tvec, pvec) * inv_det
    if u < 0 || u > 1
        return Inf
    end

    q = cross(tvec, v12)
    v = dot(ray, q) * inv_det
    if v < 0 || (u+v) > 1
        return Inf
    end

    t = dot(v13, q) * inv_det
    if allow_negative == false && t < 0.0
        return Inf
    end
    return t
end

"check if a ray intersects with bbox. return (true/false, t)"
function ray_bbox_intersect(src, invray, bb_min, bb_widths)
    # bb_min = bbox.origin
    bb_max = bb_min + bb_widths
    # invray = 1.0 ./ (ray .+ (eps(Float32) .* sign.(ray)) )
    
    if invray[1] < 0.0
        tmin = (bb_max[1] - src[1]) * invray[1]
        tmax = (bb_min[1] - src[1]) * invray[1]
    else
        tmin = (bb_min[1] - src[1]) * invray[1]
        tmax = (bb_max[1] - src[1]) * invray[1]
    end

    if invray[2] < 0.0
        tymin = (bb_max[2] - src[2]) * invray[2]
        tymax = (bb_min[2] - src[2]) * invray[2]
    else
        tymin = (bb_min[2] - src[2]) * invray[2]
        tymax = (bb_max[2] - src[2]) * invray[2]
    end

    if ( (tmin > tymax) || (tymin > tmax))
        return Inf
    end
    if tymin > tmin
        tmin = tymin
    end
    if tymax < tmax
        tmax = tymax
    end
    
    if invray[3] < 0
        tzmin = (bb_max[3] - src[3]) * invray[3]
        tzmax = (bb_min[3] - src[3]) * invray[3]
    else
        tzmin = (bb_min[3] - src[3]) * invray[3]
        tzmax = (bb_max[3] - src[3]) * invray[3]
    end

    if (tmin > tzmax) || (tzmin > tmax)
        return Inf
    end
    if tzmin > tmin
        tmin = tzmin
    end
    if tzmax < tmax
        tmax = tzmax
    end

    return tmin
end