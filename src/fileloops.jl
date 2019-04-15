
"""
    loop_example1(indx,SPM,siz)

Calls `read!` and `interp_SPM` in a loop that corresponds to a subset of
binary model output files (`filList[indx]`)
"""
function loop_example1(indx,SPM,siz)
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
