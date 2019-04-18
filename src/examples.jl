
#Examples:

"""
    cbioproc_distribute()

Use DistributedArrays to broacast over file indices in parallel

For example:

```
using CbiomesProcessing, Distributed, SparseArrays
start_workers(3)
@everywhere using CbiomesProcessing, SparseArrays
cbioproc_distribute(1:12)
```

And to visualize results, for example:

```
using FortranFiles, Plots
recl=720*360*4
fil="devel/diags_interp/ETAN/ETAN.0000000732.data"
f =  FortranFile(fil,"r",access="direct",recl=recl,convert="big-endian")
tmp=read(f,rec=1,(Float32,(720,360))); close(f)
heatmap(tmp1)
```
"""
function cbioproc_distribute(indx::Union{UnitRange{Int},Array{Int,1},Int})
    i=collect(indx)
    length(i)>1 ? i=distribute(i) : nothing
    isa(i,DArray) ? println(i.indices) : nothing
    MetaFile=cbioproc_task1.(i)
    #MetaFile=cbioproc_ex3dist1.(i)
    #return "ok"
end

"""
    cbioproc_task1(indx::Int)

Interpolate all variables for one record
"""
function cbioproc_task1(indx::Int)
    dirIn="devel/interp_output/"
    M=load(dirIn*"MTRX.jld")
    MetaFile=loop_task1(indx,M["MTRX"],M["siz2d"],M["msk2d"])
end

"""
    cbioproc_example1()

A 3D example without land mask or MeshArrays.
"""
function cbioproc_example1()
    cbioproc_example1("devel/interp_output/")
end

function cbioproc_example1(dirIn::String)
    in=fill(1.,(90,1170,50))
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    out=interp_SPM(in,SPM,siz)
    #
    outLoop,outName=loop_exampleB(1:13,SPM,siz)
    tmp=transpose(outLoop[1,1])
    heatmap(vec(lon[:,1]),vec(lat[1,:]),tmp)
    return outLoop,outName
end

"""
    cbioproc_example2()

A 2D example with MeshArrays + mask or loop.
"""
function cbioproc_example2()
    dirIn="devel/"
    cbioproc_example2(dirIn)
end

function cbioproc_example2(dirIn::String)
    #
    GCMGridSpec()
    GCMGridLoad()
    msk2d=mask(view(MeshArrays.hFacC,:,:,1),NaN,0)
    SPM,lon,lat=read_SPM(dirIn*"interp_output/")
    siz=size(lon)
    #
    in=read_bin(dirIn*"diags/state_2d_set1.0000000732.data",Float32)
    in=convert2gcmfaces(in[:,:,1].*msk2d);
    outMsk=interp_SPM(in,SPM,siz)
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outMsk))
    #
    outLoop=loop_exampleA(1:13,SPM,siz);
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outLoop[1]))
    #
    return outLoop,outMsk
end

"""
    cbioproc_ex3dist1(indx::Int)

Example that uses DistributedArrays to broacast over file indices
"""
function cbioproc_ex3dist1(indx::Int)
    dirIn="devel/interp_output/"
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    MetaFile=loop_task1(indx,SPM,siz)
    return MetaFile
end
