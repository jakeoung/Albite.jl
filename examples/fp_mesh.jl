using LinearAlgebra
using DDG
EPS = 5e-5

function fp_parallel_mesh_one_angle!(sinogram, idx, grid, Vectors, H, W, vv, ff)

    # global src_pos, ray_dir, faces_candidate
    MAX_DIST_ORIGIN = 10.0

    src_center = Vectors[idx, 1:3] * MAX_DIST_ORIGIN
    det_center = Vectors[idx, 4:6]
    
    detU = Vectors[idx, 7:9]
    detV = Vectors[idx, 10:12]
    
    detS = det_center - 0.5 * H * detV - 0.5 * W * detU
    srcS = src_center - 0.5 * H * detV - 0.5 * W * detU
    
    ray_dir_ = -src_center
    ray_dir = ray_dir_ ./ norm(ray_dir_)    

    cnt_bbox_mis = 0

    for v=0:H-1
        for u=0:W-1
            det_pos = detS + v * detV + u * detU
            src_pos = srcS + v * detV + u * detU
            
            # first test bounding box
            # @show src_pos, ray_dir
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
                    sinogram[idx, v+1, u+1] += norm(loc1-loc2)
                    new_src = loc2 + (EPS)*ray_dir

                    t, iface = cast_ray(grid, new_src, ray_dir)
                    t == Inf && break
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
    sinogram = zeros(nangles, H, W)
    
    grid = Grid(vv, ff)

    for idx=1:nangles
        fp_parallel_mesh_one_angle!(sinogram, idx, grid, Vectors, H, W, vv, ff)
    end
    return sinogram
end


