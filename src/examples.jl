
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
k=1
recl=720*360*4
fil="diags_interp/ETAN/ETAN.0000000732.data"
#fil="diags_interp/THETA/TETA.0000000024.data"
f =  FortranFile(fil,"r",access="direct",recl=recl,convert="big-endian")
tmp=read(f,rec=k,(Float32,(720,360))); close(f)
heatmap(tmp)
```
"""
function cbioproc_distribute(indx::Union{UnitRange{Int},Array{Int,1},Int})
    i=collect(indx)
    length(i)>1 ? i=distribute(i) : nothing
    isa(i,DArray) ? println(i.indices) : nothing
    #MetaFile=cbioproc_task1.(i)
    #loop_task2.(i)
    loop_task4.(i)
end

"""
    cbioproc_task1(indx::Int)

Interpolate all variables for one record
"""
function cbioproc_task1(indx::Int)
    task=YAML.load(open("task.yml"))
    M=load(task["Specs"]["file"])
    MetaFile=loop_task1(indx,M)
end

"""
    cbioproc_example1()

A 3D example without land mask or MeshArrays.
"""
function cbioproc_example1()
    cbioproc_example1("")
end

function cbioproc_example1(dirIn::String)
    in=fill(1.,(90,1170,50))
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    out=InterpMatrix(in,SPM,siz)
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
    dirIn=""
    cbioproc_example2(dirIn)
end

function cbioproc_example2(dirIn::String)
    #
    GCMGridSpec()
    GCMGridLoad()
    msk2d=mask(view(MeshArrays.hFacC,:,:,1),NaN,0)
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    #
    in=read_bin(dirIn*"diags/state_2d_set1.0000000732.data",Float32)
    in=convert2gcmfaces(in[:,:,1].*msk2d);
    outMsk=InterpMatrix(in,SPM,siz)
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outMsk))
    #
    outLoop=loop_exampleA(1:13,SPM,siz);
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outLoop[1]))
    #
    return outLoop,outMsk
end
