# byproducts.jl

AverageYear() = print("To be continued...")

function interp_SPM(in::Array{T,N}) where {T,N}
    dirIn="devel/interp_output/"
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    out=interp_SPM(in,SPM,siz)
end

function read_SPM(dirIn::String)
    #vars = matread(dirIn*"interp_precomputed.mat")
    file = matopen(dirIn*"interp_precomputed.mat")
    interp=read(file, "interp")
    lon=read(file, "lon")
    lat=read(file, "lat")
    SPM=interp["SPM"]
    #println(keys(interp))
    close(file)
    return SPM,lon,lat
end

function interp_SPM(in::Array{T,N},SPM,siz) where {T,N}
    #input
    l=size(in,1)*size(in,2);
    m=size(in,3);
    tmp1=reshape(in,l,m)
    tmp0=Float64.(.!(isnan.(tmp1)))
    tmp1[isnan.(tmp1)].=0.
    siz=siz[1],siz[2],m
    #matrix product
    tmp0=SPM*tmp0
    tmp1=SPM*tmp1
    tmp1=tmp1./tmp0
    #this may be redundant:
    tmp1[tmp0 .== 0.] .= NaN
    #output
    out=reshape(tmp1,siz)
    m==1 ? out=dropdims(out,dims=3) : nothing
    return out
end
