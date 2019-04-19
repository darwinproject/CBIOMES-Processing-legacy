"""
    start_workers(nwrkrs::Int)

Start workers if needed.
"""
function start_workers(nwrkrs::Int)
   set_workers = nwrkrs
   nworkers() < set_workers ? addprocs(set_workers) : nothing
   nworkers()
end

"""
    loop_task1(indx,SPM,siz,msk)

Loop over a subset of model output files (`filList[indx]`), apply
`InterpMatrix` as a postprocessing step, and write the result to
file (one subfolder for each variable)
"""
function loop_task1(indx,SPM,siz)
   msk=missing
   MetaFile=loop_task1(indx,SPM,siz,msk)
end

function loop_task1(indx,SPM,siz,msk)
   dirIn="devel/diags/"
   filIn="state_2d_set1"
   dirOut="devel/diags_interp/"
   !isdir(dirOut) ? mkdir(dirOut) : nothing

   tmp1=readdir(dirIn)
   tmp1=filter(x -> occursin(filIn,x),tmp1)
   filList=filter(x -> occursin(".data",x),tmp1)
   filList=filList[indx]

   !isa(filList,Array) ? filList=[filList] : nothing
   nf=length(filList)
   MetaFile=filList[1]
   MetaFile=dirIn*MetaFile[1:end-5]*".meta"
   MetaFile=MetaFileRead(MetaFile)

   nv=length(MetaFile["fldList"])
   nd=MetaFile["nDims"]
   dims=Int.(MetaFile["dimList"][:,1])
   prec=MetaFile["dataprec"]

   for ff=1:nf
      fil=dirIn*filList[ff]
      #println(fil)
      fid = open(fil)
      for vv=1:nv
         tmp=Array{Float32,2}(undef,(90,1170))
         nd==3 ? tmp=Array{Float32,2}(undef,(90,1170,50)) : nothing
         read!(fid,tmp)
         tmp = hton.(tmp)
         !ismissing(msk) ? tmp=tmp.*msk : nothing
         tmp=InterpMatrix(tmp,SPM,siz)
         tmp=Float32.(tmp)
         #
         filOut=dirOut*strip(MetaFile["fldList"][vv])*"/"
         !isdir(filOut) ? mkdir(filOut) : nothing
         filOut=filOut*strip(MetaFile["fldList"][vv])
         filOut=filOut*fil[length(dirIn*filIn)+1:end]
         #println(filOut)
         #
         nd==3 ? recl=720*360*50*4 : recl=720*360*4
         f =  FortranFile(filOut,"w",access="direct",recl=recl,convert="big-endian")
         write(f,rec=1,tmp)
         close(f)
         #to re-read file:
         #f =  FortranFile(filOut,"r",access="direct",recl=recl,convert="big-endian");
         #tmp1=read(f,rec=1,(Float32,(720,360))); close(f);
      end
      close(fid)
   end

   return MetaFile
end

"""
    loop_exampleA(indx,SPM,siz)

Applies `InterpMatrix` in a loop over a subset of model output files (`filList[indx]`)
"""
function loop_exampleA(indx,SPM,siz)
   dirIn="devel/diags/"
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
      out[ff]=InterpMatrix(fld,SPM,siz)
   end

   return out
end

"""
    loop_exampleB(indx,SPM,siz)

Applies `InterpMatrix` in a loop over a subset of model output files (`filList[indx]`)
"""
function loop_exampleB(indx,SPM,siz)
   dirIn="devel/diags/"
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
         out[ff,vv]=InterpMatrix(tmp,SPM,siz)
      end
   end

   return out,MetaFile["fldList"]
end
