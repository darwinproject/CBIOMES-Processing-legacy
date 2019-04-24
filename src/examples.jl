
#Examples:

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
    out=MatrixInterp(in,SPM,siz)
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
    outMsk=MatrixInterp(in,SPM,siz)
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outMsk))
    #
    outLoop=loop_exampleA(1:13,SPM,siz);
    heatmap(vec(lon[:,1]),vec(lat[1,:]),transpose(outLoop[1]))
    #
    return outLoop,outMsk
end

"""
    loop_exampleA(indx,SPM,siz)

Applies `MatrixInterp` in a loop over a subset of model output files (`filList[indx]`)
"""
function loop_exampleA(indx,SPM,siz)
   dirIn="diags/"
   filIn="state_2d_set1"
   tmp1=readdir(dirIn)
   tmp1=filter(x -> occursin(filIn,x),tmp1)
   filList=filter(x -> occursin(".data",x),tmp1)
   filList=filList[indx]
   nf=length(filList)
   #show(filList)

   out=Array{Any,1}(undef,nf)
   for ff=1:nf
      fil=dirIn*filList[ff]
      fid = open(fil);
      #println(fil)
      fld = Array{Float32,2}(undef,(90,1170));
      #fld = Array{prec,1}(undef,(n1*n2*n3));
      read!(fid,fld);
      fld = hton.(fld);
      #println(size(fld))
      out[ff]=MatrixInterp(fld,SPM,siz)
   end

   return out
end

"""
    loop_exampleB(indx,SPM,siz)

Applies `MatrixInterp` in a loop over a subset of model output files (`filList[indx]`)
"""
function loop_exampleB(indx,SPM,siz)
   dirIn="diags/"
   filIn="state_2d_set1"
   tmp1=readdir(dirIn)
   tmp1=filter(x -> occursin(filIn,x),tmp1)
   filList=filter(x -> occursin(".data",x),tmp1)
   filList=filList[indx]
   nf=length(filList)
   #show(filList)

   MetaFile=dirIn*filList[1]
   MetaFile=MetaFile[1:end-5]*".meta"
   MetaFile=MetaFileRead(MetaFile)
   nv=length(MetaFile["fldList"])
   nd=MetaFile["nDims"]
   dims=Int.(MetaFile["dimList"][:,1])
   prec=MetaFile["dataprec"]

   out=Array{Any,2}(undef,(nf,nv))
   tmp = Array{prec,nd}(undef,Tuple(dims));
   for ff=1:nf
      fil=dirIn*filList[ff]
      fid = open(fil);
      #println(fil)
      #tmp = Array{prec,1}(undef,(n1*n2*n3));
      for vv=1:nv
         read!(fid,tmp);
         tmp = hton.(tmp);
         out[ff,vv]=MatrixInterp(tmp,SPM,siz)
      end
   end

   return out,MetaFile["fldList"]
end

"""
    prep_MTRX()

Repackage interpolation matrix, mask, etc to `.jld` file.
"""
function prep_MTRX()
    GCMGridSpec()
    GCMGridLoad()
    msk2d=mask(view(MeshArrays.hFacC,:,:,1),NaN,0)
    msk3d=mask(MeshArrays.hFacC,NaN,0)
    msk2d=convert2gcmfaces(msk2d)
    msk3d=convert2gcmfaces(msk3d)

    dirIn=""
    MTRX,lon,lat=read_SPM(dirIn)
    lon=vec(lon[:,1])
    lat=vec(lat[1,:])

    fid = open("GRID_LLC90/RC.data")
    dep=Array{Float64,1}(undef,50)
    read!(fid,dep)
    close(fid)
    dep = -hton.(dep)

    siz2d=(length(lon),length(lat))
    siz3d=(length(lon),length(lat),50)

    save(dirIn*"MTRX.jld", "MTRX", MTRX, "lon", lon, "lat", lat, "dep", dep,
    "msk2d", msk2d, "msk3d", msk3d, "siz2d", siz2d, "siz3d", siz3d)
end

"""
    read_SPM(dirIn::String)

Reads pre-computed interpolation (sparse matrix) from
`dirIn*"interp_precomputed.mat"`.
"""
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
