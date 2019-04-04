# byproducts.jl

#Example:
#
if false
    using CbiomesProcessing, MAT
    inFLD=fill(1.,(90,1170))
    (tmp1,tmp2)=interp2d(inFLD)
end

AverageYear() = print("To be continued...")

function interp2d(inFLD::Array{T,N}) where {T,N}
    #read interpolation parameters
    dirIn="devel/interp_output/"
    #vars = matread(dirIn*"interp_precomputed.mat")
    file = matopen(dirIn*"interp_precomputed.mat")
    lon=read(file, "lon")
    lat=read(file, "lat")
    interp=read(file, "interp")
    #println(keys(interp))
    close(file)
    #apply interpolation to fldIn
    l=prod(size(inFLD))
    tmp1=reshape(inFLD,l,1)
    tmp0=Float64.(.!(isnan.(tmp1)))
    tmp1[isnan.(tmp1)].=0.
    siz=size(lon,1),size(lon,2),1
    #println(typeof(interp["SPM"]))
    tmp0=interp["SPM"]*tmp0
    tmp1=interp["SPM"]*tmp1
    outFLD=reshape(tmp1./tmp0,siz)
    #
    return outFLD
end
