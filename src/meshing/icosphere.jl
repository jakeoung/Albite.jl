# using GeometryTypes
# using LinearAlgebra

"refine sphere for vertices [N x 3]"
function refine_sphere!(vv, r=1.0)
    scalars = sum(vv .^ 2, dims=2) .^ 0.5
    unit = vv ./ reshape(scalars, :, 1)
    offset = r .- scalars
    vv .+= unit .* reshape(offset, :, 1)
    return vv
end

"Generate icosphere(subdiv,r,center) with subdivision1: 80 faces, subd2: 320 ..."
function icosphere(subdiv=3, r=1.0, center=[0.0,0.0,0.0])
    vv, ff = icosahedron()

    for i=1:subdiv
        v_, f_ = subdivision(vv', ff')
        ff = Array(f_')
        vv = Array(v_')
        vv = refine_sphere!(vv)
    end

    vv .*= r
    vv .+= reshape(center, 1, 3) # note that +
    return vv, ff
end

function icosahedron()
    t = (1+sqrt(5)) / 2;
    v = [-1  t  0;      1  t  0;
     -1 -t  0;      1 -t  0;
      0 -1  t;      0  1  t;
      0 -1 -t;      0  1 -t;
      t  0 -1;      t  0  1;
     -t  0 -1;     -t  0  1]
    v = v / norm(v[1,:]);

    f = [ 1 12 6;       1 6 2;
      1 2 8;      1 8 11;
      1 11 12;      2  6 10;
      6 12 5;     12 11 3;
     11 8 7;      8 2 9;
      4 10 5;      4 5 3;
      4 3 7;      4 7 9;
      4 9 10;      5 10 6;
      3 5 12;      7 3 11;
      9 7 8;     10 9 2]
    return v, f
end
