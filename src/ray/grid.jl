using LinearAlgebra
include("intersect.jl")

using GeometryTypes

struct Cell
    flist::Array{Int, 1}
    # triangles::Array{Triangle}

    # Cell(fidx::Int) = Cell( [fidx] )
end

function insert!(c::Cell, fidx::Int)
    push!(c.flist, fidx)
end

function intersect(cell::Cell, orig, ray, vv, faces, thit)
    # tmin = Inf
    iface = -1
    for fid in cell.flist
        # todo: mailbox
        v1, v2, v3 = vv[faces[fid]]
        t = ray_triangle_intersect(orig, ray, v1, v2, v3)
        if (t < thit)
            # nearest triangle found
            thit = t
            iface = fid
        end
    end

    if iface == -1
        return false, thit, iface
    else
        return true, thit, iface
    end 
end

struct Grid
    cells::Array{Cell}
    bbox::HyperRectangle
    resolution
    cell_size
    vv
    ff

    # Grid() = Grid(Cell[])
end

"""
    cast_ray(grid::Grid, orig, ray)
    
# Return
- 
"""
function cast_ray(grid::Grid, orig, ray)
    thitbox = ray_bbox_intersect(orig, ray, grid.bbox.origin, grid.bbox.widths)
    if thitbox == Inf
        return Inf
    end

    invdir = 1.0 ./ (ray .+ eps(Float32) )

    # convert orig in cell coordinates (we start from inside the grid thitbox)
    orig_cell = (orig + thitbox*ray) - grid.bbox.origin
    cell = clamp.( Int.(floor.(orig_cell ./ grid.cell_size)), 0, grid.resolution .- 1)
    cell = Array(cell)

    deltaT = - [grid.cell_size...] .* invdir
    step = -ones(3)
    exit = -ones(3)
    nextCrossingT = zeros(3)

    for i=1:3
        if ray[i] > 0
            step[i] = 1
            exit[i] = grid.resolution[i]
            deltaT[i] *= -1.0
            nextCrossingT[i] = thitbox + (cell[i] * grid.cell_size[i] - orig_cell[i]) * invdir[i]
        else
            nextCrossingT[i] = thitbox + ((cell[i]+1.0) * grid.cell_size[i] - orig_cell[i]) * invdir[i]
        end
    end

    map_axis = (3, 2, 3, 2, 3, 3, 1, 1) 

    thit = Inf

    # loop over cells
    while true
        idx_cell = cell[3]*grid.resolution[1]*grid.resolution[2] + cell[2]*grid.resolution[1] + cell[1] + 1
        if isassigned(grid.cells, idx_cell)
            ishit, thit, iface = intersect(grid.cells[idx_cell], orig, ray, grid.vv, grid.ff, thit)
        end

        k = ((nextCrossingT[1] < nextCrossingT[2]) << 2) +
            ((nextCrossingT[1] < nextCrossingT[3]) << 1) +
            ((nextCrossingT[2] < nextCrossingT[3]))

        axis = map_axis[k+1]
        
        # @show thit, axis
        thit < nextCrossingT[axis] && break;
        cell[axis] += step[axis]

        cell[axis] == exit[axis] && break;
        nextCrossingT[axis] += deltaT[axis]
    end

    return thit
end

"""
    Grid(vv, ff, lambda=5)

Construct a grid adaptive to the input mesh (vv, ff)

# Args
- lambda::Int, between 3 and 5

"""
function Grid(vv, ff, lambda=5)
    ww = maximum(vv) - minimum(vv)
    bbox = AABB(minimum(vv)..., ww...)

    N = length(ff)
    nff = ( lambda * N / prod(ww) ) ^ (1 / 3.0)
    resolution = Int.(floor.(ww * nff))
    resolution = min.(resolution, 128)
    
    cell_size = ww ./ resolution

    cells = Array{Cell}(undef, prod(resolution))
    # sizehint!(cells, prod(resolution))

    # insert triangles in the cells
    for i=1:N
        # step1: compute the bounding box of the triangle
        v1, v2, v3 = vv[ff[i]]
        vmin = minimum([v1, v2, v3])
        vmax = maximum([v1, v2, v3])
        
        # step2: convert to cell coordinates.
        min_cell = (vmin - bbox.origin) ./ cell_size
        max_cell = (vmax - bbox.origin) ./ cell_size

        vmin_c = Int.(floor.(clamp.(min_cell, 0.0, resolution .- 1)))
        vmax_c = Int.(floor.(clamp.(max_cell, 0.0, resolution .- 1)))

        # step3: find the cells which overlaps BBOX
        for z=vmin_c[3]:vmax_c[3]
            for y=vmin_c[2]:vmax_c[2] 
                for x=vmin_c[1]:vmax_c[1]
                    idx_cell = z*resolution[1]*resolution[2] + y*resolution[1] + x + 1
                    # @show cells, idx_cell
                    if ~isassigned(cells, idx_cell)
                        cells[idx_cell] = Cell([i])
                    else
                        insert!(cells[idx_cell], i)
                    end
                end
            end
        end
    end

    return Grid(cells, bbox, resolution, cell_size, vv, ff)
end

# script
"""
using FileIO
mm = load("/Users/jakoo/Desktop/aaaa.obj")
vv, ff = mm.vertices, mm.faces

grid = Grid(vv, ff)
orig = Point(0.0, -10.0, 0.1)
ray = Point(0.0, 1.0, 0.0)
intersect(grid, orig, ray)
# idx_unassigned = filter( x -> ~isassigned(grid.cells, x) , 1:length(grid.cells))
"""