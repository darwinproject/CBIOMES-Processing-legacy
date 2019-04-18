
#Examples:

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
    SPM,lon,lat=read_SPM(dirIn)
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
    cbioproc_example3()

Example that uses DistributedArrays to broacast over file indices as follows

```
using CbiomesProcessing, Distributed
start_workers(3)
@everywhere using CbiomesProcessing
MetaFile=cbioproc_example3()
```
"""
function cbioproc_example3()
    indx=distribute(collect(1:12))
    indx.indices
    indx.localpart

    MetaFile=cbioproc_ex3dist1.(indx)
end

"""
    cbioproc_ex3dist1(indx::Int)

Example that uses DistributedArrays to broacast over file indices
"""
function cbioproc_ex3dist1(indx::Int)
    dirIn="devel/interp_output/"
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    MetaFile=loop_exampleC(indx,SPM,siz)
    return MetaFile
end
