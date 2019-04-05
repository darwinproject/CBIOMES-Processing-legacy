# byproducts.jl

#Example:
#
if false
    using CbiomesProcessing, MAT
    in1=fill(1.,(90,1170))
    in2=fill(1.,(90,1170,50))
    out=interp2d(in2)
end

AverageYear() = print("To be continued...")

function interp2d(in::Array{T,N}) where {T,N}
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
    l=size(in,1)*size(in,2);
    m=size(in,3);
    tmp1=reshape(in,l,m)
    tmp0=Float64.(.!(isnan.(tmp1)))
    tmp1[isnan.(tmp1)].=0.
    siz=size(lon,1),size(lon,2),m
    #println(typeof(interp["SPM"]))
    tmp0=interp["SPM"]*tmp0
    tmp1=interp["SPM"]*tmp1
    out=reshape(tmp1./tmp0,siz)
    m==1 ? out=dropdims(out,dims=3) : nothing
    #
    return out
end
