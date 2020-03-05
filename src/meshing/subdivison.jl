"Codes from https://github.com/akels/SurfaceGeometry.jl/blob/4acfa393bea6a38403ff820d8ad2ca098d5fb53b/src/Utils.jl"

"Subdivison faces"
function subdivision(faces::AbstractArray{T, 2}) where T <: Integer
    edges = Tuple{T, T}[]

    for ti in 1:size(faces,2)
        v1,v2,v3 = faces[:,ti]

        push!(edges, v2 > v1 ? (v1, v2) : (v2, v1))
        push!(edges, v3 > v2 ? (v2, v3) : (v3, v2))
        push!(edges, v1 > v3 ? (v3, v1) : (v1, v3))
    end
    sort!(edges)
    unique!(edges)

    rfaces = Array{T}(undef,3,size(faces,2)*4)
    N = maximum(faces) # number of vertices

    for ti in 1:size(faces,2)

        v1,v2,v3 = faces[:,ti]
        e3 = findfirst(isequal(v2 > v1 ? (v1, v2) : (v2, v1)), edges) + N
        e1 = findfirst(isequal(v3 > v2 ? (v2, v3) : (v3, v2)), edges) + N
        e2 = findfirst(isequal(v1 > v3 ? (v3, v1) : (v1, v3)), edges) + N

        rfaces[:,4*ti - 3] .= [v1,e3,e2]
        rfaces[:,4*ti - 2] .= [v2,e1,e3]
        rfaces[:,4*ti - 1] .= [v3,e2,e1]
        rfaces[:,4*ti] .= [e1,e2,e3]
    end

    return rfaces
end

"Subdivision by linear method"
function subdivision(points, faces)
    rfaces = subdivision(faces)
    rpoints = Array{Float64}(undef,3,maximum(rfaces))

    for ti in 1:size(faces,2)

        v1,v2,v3 = faces[:,ti]
        e1,e2,e3 = rfaces[:,4*ti]

        rpoints[:,v1] = points[:,v1]
        rpoints[:,v2] = points[:,v2]
        rpoints[:,v3] = points[:,v3]
        rpoints[:,e1] = (points[:,v2] + points[:,v3])/2
        rpoints[:,e2] = (points[:,v1] + points[:,v3])/2
        rpoints[:,e3] = (points[:,v1] + points[:,v2])/2
    end

    return rpoints,rfaces
end
