
function write_obj(fname::String, vv, ff)
   io = open(fname, "w")
   mapslices(v -> println(io, "v $(v[1]) $(v[2]) $(v[3])"), vv, dims=[2])
   mapslices(f -> println(io, "f $(f[1]) $(f[2]) $(f[3])"), ff, dims=[2])
   close(io)
end
