using .raytracing

include("./build_octtree.jl")

using LinearAlgebra
using RegionTrees

EPS = 1e-6

function fp_parallel_mesh_naive!(sinogram, idx, Vectors, H, W, vv, ff)

    # aabb = AABB(vv)
    bb_min, bb_max = minimum(vv), maximum(vv)

    MAX_DIST_ORIGIN = 10.0

    src_center = Vectors[idx, 1:3] * MAX_DIST_ORIGIN
    det_center = Vectors[idx, 4:6]
    
    detU = Vectors[idx, 7:9]
    detV = Vectors[idx, 10:12]
    
    detS = det_center - 0.5 * H * detV - 0.5 * W * detU
    srcS = src_center - 0.5 * H * detV - 0.5 * W * detU
    
    ray_dir_ = -Vectors[idx, 1:3]
    ray_dir = ray_dir_ ./ norm(ray_dir_)    

    cnt_bbox_mis = 0

    for v=0:H-1
        for u=0:W-1
            det_pos = detS + v * detV + u * detU
            src_pos = srcS + v * detV + u * detU
            
            # first test bounding box
            if ray_bbox_intersect(src_pos, ray_dir, bb_min, bb_max) == false
                cnt_bbox_mis += 1
                continue
            end

            ishit, t = cast_ray(src_pos, ray_dir, vv, ff)
            if ishit == false continue; end
            loc1 = src_pos + (t)*ray_dir

            cnt = 0
            while ishit
                cnt += 1
                
                new_src = loc1 + (EPS)*ray_dir
                ishit, t = cast_ray(new_src, ray_dir, vv, ff)

                if (cnt > 10)
                    print("! Critical error")
                    break
                end
                
                if ishit == false
                    if cnt == 1
                        println("! Sometihng wrong")
                    end
                else
                    loc2 = new_src + t*ray_dir
                    sinogram[idx, v+1, u+1] += norm(loc1-loc2)
                    new_src = loc2 + (EPS)*ray_dir
                    ishit, t = cast_ray(new_src, ray_dir, vv, ff)
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
    
    Threads.@threads for idx=1:nangles
        fp_parallel_mesh_naive!(sinogram, idx, Vectors, H, W, vv, ff)
    end
    return sinogram
end