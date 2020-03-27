# struct TriangleDesc
#     mesh
#     fidx::Int
# end

struct Cell
    flist::Array{Int}

    # function Cell(args...)
    #     new(flist)
    # end
end

function insert!(c::Cell, fidx::Int)
    push!(c.flist, fidx)
end

struct Grid
    Cell[]
end