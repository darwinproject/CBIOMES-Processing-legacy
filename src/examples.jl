
#Examples:

function cbioproc_example1()
    #a 3D example without land mask or MeshArrays
    in=fill(1.,(90,1170,50))
    dirIn="devel/interp_output/"
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    out=interp_SPM(in,SPM,siz)
    out=loop_example1(1:13,SPM,siz);
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(out[1]))
end

function cbioproc_example2()
    #a 2D example with MeshArrays + mask or loop
    GCMGridSpec()
    GCMGridLoad()
    msk2d=mask(view(MeshArrays.hFacC,:,:,1),NaN,0)
    dirIn="devel/interp_output/"
    SPM,lon,lat=read_SPM(dirIn)
    siz=size(lon)
    #
    in=read_bin("devel/diags/state_2d_set1.0000000732.data",Float32)
    in=convert2gcmfaces(in[:,:,1].*msk2d);
    outMsk=interp_SPM(in,SPM,siz)
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outMsk))
    #
    outLoop=loop_example1(1:13,SPM,siz);
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outLoop[1]))
    #
    return outMsk, outLoop
end
