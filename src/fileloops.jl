
"""
loop_exampleA(indx,SPM,siz)

Calls `read!` and `interp_SPM` in a loop that corresponds to a subset of
binary model output files (`filList[indx]`)
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
      out[ff]=interp_SPM(fld,SPM,siz)
   end

   return out
end

"""
loop_exampleB(indx,SPM,siz)

Calls `read!` and `interp_SPM` in a loop that corresponds to a subset of
binary model output files (`filList[indx]`)
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
   #show(MetaFile)

   #f = open(MetaFile)
   #lines = readlines(f)
   #close(f)
   #println(typeof(lines))
   #println(size(lines))
   #show(lines[1])

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
         out[ff,vv]=interp_SPM(tmp,SPM,siz)
      end
   end

   return out,MetaFile["fldList"]
end
