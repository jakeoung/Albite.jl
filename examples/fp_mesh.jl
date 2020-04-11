using LinearAlgebra
using DDG
EPS = 5e-6

function fp_parallel_mesh_one_angle!(sinogram, grid, vector, H, W, vv, ff)
    global ray_dir, src_center
    # global src_pos, ray_dir, faces_candidate
    MAX_DIST_ORIGIN = 10.0

    src_center = vector[1:3] * MAX_DIST_ORIGIN
    det_center = vector[4:6]
    
    detU = vector[7:9]
    detV = vector[10:12]
    
    detS = det_center - 0.5 * H * detV - 0.5 * W * detU
    srcS = src_center - 0.5 * H * detV - 0.5 * W * detU
    
    ray_dir = -src_center
    ray_dir[abs.(ray_dir) .<= eps(Float32)] .= eps()

    # ray_dir = ray_dir_ ./ norm(ray_dir_)    

    
    # ray_dir[2] = eps()
    
    # ray_dir[1] = eps()
    # ray_dir[3] = eps()

    cnt_bbox_mis = 0

    for u=0:W-1
        for v=0:H-1
            # det_pos = detS + v * detV + u * detU
            src_pos = srcS + v * detV + u * detU
            
            # first test bounding box
            t, iface = cast_ray(grid, src_pos, ray_dir)
            if t == Inf
                continue
            end
            
            loc1 = src_pos + (t)*ray_dir

            cnt = 0
            while t < Inf
                cnt += 1
                if (cnt > 10)
                    cnt_bbox_mis += 1
                    # println("! Critical error 10")
                    break
                end

                new_src = loc1 + (EPS)*ray_dir
                t, iface = cast_ray(grid, new_src, ray_dir)
                
                if t == Inf
                    # println("! Something wrong, cnt: $cnt")
                    cnt_bbox_mis += 1
                    break
                else
                    loc2 = new_src + t*ray_dir
                    sinogram[v+1, u+1] += norm(loc1-loc2)
                    new_src = loc2 + (EPS)*ray_dir

                    t, iface = cast_ray(grid, new_src, ray_dir)
                    loc1 = new_src + t*ray_dir
                end
            end
        end
    end

    println("@ cnt_bbox_mis: $cnt_bbox_mis")

end

"Generate sinogram from a triangular mesh (from MeshIO) for a closed object"
function fp_mesh(proj_geom, vv, ff)
    Vectors = proj_geom.Vectors
    H = proj_geom.DetectorRowCount
    W = proj_geom.DetectorColCount
    
    nangles = size(Vectors, 1)
    sinogram = zeros(H, W, nangles)
    
    grid = Grid(vv, ff)

    for idx=1:nangles
        sino_view = view(sinogram, :, :, idx)
        vec_view = view(Vectors, idx, :)
        fp_parallel_mesh_one_angle!(sino_view, grid, vec_view, H, W, vv, ff)
    end
    return permutedims(sinogram, [3,1,2])
end


