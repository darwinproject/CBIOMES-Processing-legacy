# byproducts.jl

AverageYear() = print("Hello World!")

#interp2d() = print("Hello World!")

function interp2d(inFLD::Any)
    #read interpolation parameters
    dirIn="devel/interp_output/"
    #vars = matread(dirIn*"interp_precomputed.mat")
    file = matopen(dirIn*"interp_precomputed.mat")
    lon=read(file, "lon")
    lat=read(file, "lat")
    interp=read(file, "interp")
    vars=keys(interp)
    close(file)
    #devel stuf
    println(vars)
    if false
        println(size(lon))
        println(size(lat))
        println(typeof(interp))
        println(size(interp["point"]))
    end
    #apply interpolation to fldIn
    1+1
    #the following is a place holder
    dFLDdx=missing
    dFLDdy=missing
    return dFLDdx, dFLDdy
end
