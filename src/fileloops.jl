
"""
    loop_task1(indx::Int)

Interpolate all variables for one record
"""
function loop_task1(indx::Int)
    task=YAML.load(open("task.yml"))
    M=load(task["Specs"]["file"])
    MetaFile=loop_task1(indx,M)
end

"""
    loop_task1(indx,M)

Loop over a subset of model output files (`filList[indx]`), apply
`MatrixInterp` (`M`) as a postprocessing step, and write the result
to file (one subfolder for each variable)
"""
function loop_task1(indx,M)
   task=YAML.load(open("task.yml"))
   dirIn=task["InputDir"][1]
   filIn=task["InputFile"][1]
   dirOut=task["OutputDir"]
   !isdir(dirOut) ? mkdir(dirOut) : nothing
   MTRX=M["MTRX"]
   msk=M[task["Specs"]["mask"]]
   siz=Tuple(task["OutputSize"])

   tmp1=readdir(dirIn)
   tmp1=filter(x -> occursin(filIn,x),tmp1)
   filList=filter(x -> occursin(".data",x),tmp1)
   maximum(indx)>length(filList) ? error("missing files: "*filIn*"*") : nothing
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
         nd==3 ? tmp=Array{Float32,3}(undef,(90,1170,50)) : nothing
         read!(fid,tmp)
         tmp = hton.(tmp)
         !ismissing(msk) ? tmp=tmp.*msk : nothing
         tmp=MatrixInterp(tmp,MTRX,siz)
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
    loop_task2(indx)

Loop over a subset of model output files (`filList[indx]`), convert Rirr*
to Satellite Chl as a postprocessing step, and write the result
to file (one subfolder for each variable)
"""
function loop_task2(indx)

   task=YAML.load(open("task.yml"))

   dirIn=task["InputDir"][1]
   filIn=task["InputFile"][1]
   dirOut=task["OutputDir"]
   filOut=task["OutputFile"]
   !isdir(dirOut) ? mkdir(dirOut) : nothing

   siz=Tuple(task["OutputSize"])
   prec=Float32

   C=task["Specs"]["PolyCoeffs"]
   a0=C[1]; a1=C[2]; a2=C[3]; a3=C[4]; a4=C[5];

   tmp1=readdir(dirIn*filIn)
   tmp1=filter(x -> occursin(filIn,x),tmp1)
   filList=filter(x -> occursin(".data",x),tmp1)
   maximum(indx)>length(filList) ? error("missing files: "*filIn*"*") : nothing
   filList=filList[indx]

   !isa(filList,Array) ? filList=[filList] : nothing
   nf=length(filList)

   wv_cci=[412, 443, 490, 510, 555, 670];
   wv_drwn3=[400,425,450,475,500,525,550,575,600,625,650,675,700];
   jj=Array{Int64,1}(undef,6)
   ww=Array{Float64,1}(undef,6)
   for ii=1:6
      tmp=wv_cci[ii].-wv_drwn3
      kk=maximum(findall(tmp.>=0))
      jj[ii]=kk
      ww[ii]=tmp[kk]/(wv_drwn3[kk+1]-wv_drwn3[kk])
   end

   #C=[0.2424    -2.7423 +1.8017 +0.0015 -1.2280] #OC3M-547 (MODIS)
   #C=[0.3272    -2.9940 +2.7218 -1.2259 -0.5683] #OC4 (SeaWifs, CCI)
   #a0=C[1]; a1=C[2]; a2=C[3]; a3=C[4]; a4=C[5];

   for ff=1:nf
      fil=dirIn*filIn*"/"*filList[ff]

      #1) read Rirr
      Rirr=Array{Float32,3}(undef,(siz[1],siz[2],13))
      for vv=1:13
         fil0=replace(fil,task["InputFile"][1] => task["InputFile"][vv])
         tmp=Array{Float32,2}(undef,siz)
         fid = open(fil0)
         read!(fid,tmp)
         Rirr[:,:,vv] = hton.(tmp)
         close(fid)
      end

      #2) convert to Rrs & interpolate in frequency space
      tmp=Rirr/3
      Rrs0=(0.52*tmp)./(1.0 .-1.7*tmp)
      Rrs=Array{Float32,3}(undef,(siz[1],siz[2],6))
      for vv=1:6
         tmp0=Rrs0[:,:,jj[vv]]
         tmp1=Rrs0[:,:,jj[vv]+1]
         Rrs[:,:,vv]=tmp0.*(1-ww[vv])+tmp1.*ww[vv]
      end

      #3) compute "satellite Chl" in model
      RRSB=max.(Rrs[:,:,2],Rrs[:,:,3])
      RRSG=Rrs[:,:,5]
      X = log10.(RRSB./RRSG) #ratio of blue to green
      chld=exp10.(a0.+a1*X+a2*X.^2+a3*X.^3+a4*X.^4);

      #println(fil)
      recl=720*360*4
      filOut=dirOut*"chld/"
      !isdir(filOut) ? mkdir(filOut) : nothing
      filOut=filOut*replace(filList[ff],task["InputFile"][1] => task["OutputFile"])
      f =  FortranFile(filOut,"w",access="direct",recl=recl,convert="big-endian")
      write(f,rec=1,Float32.(chld))
      close(f)
      #to re-read file:
      #f =  FortranFile(filOut,"r",access="direct",recl=recl,convert="big-endian");
      #tmp1=read(f,rec=1,(Float32,(720,360))); close(f);
   end

   return filList
end

"""
    loop_task3(indx)

Loop over a subset of model output files (`filList[indx]`), compute
export as a postprocessing step, and write the result
to file (one subfolder for each variable)
"""
function loop_task3(indx)

   task=YAML.load(open("task.yml"))

   dirIn=task["InputDir"][1]
   filIn=task["InputFile"][1]
   dirOut=task["OutputDir"]
   filOut=task["OutputFile"]
   !isdir(dirOut) ? mkdir(dirOut) : nothing

   siz=Tuple(task["InputSize"])
   prec=Float32
   recl=prod(siz)*4

   tmp1=readdir(dirIn*filIn)
   tmp1=filter(x -> occursin(filIn,x),tmp1)
   filList=filter(x -> occursin(".data",x),tmp1)
   maximum(indx)>length(filList) ? error("missing files: "*filIn*"*") : nothing
   filList=filList[indx]

   !isa(filList,Array) ? filList=[filList] : nothing
   nf=length(filList)

   Wsink=task["Specs"]["Wsink"]
   #convert from m/s to m/day
   Wsink=86400.0*Wsink

   for ff=1:nf
      #1) read biomass
      fil=dirIn*filIn*"/"*filList[ff]
      tmp=Array{Float32,3}(undef,siz)
      fid = open(fil)
      read!(fid,tmp)
      tmp = hton.(tmp)
      close(fid)

      #2) compute export rate
      xprt=similar(tmp);
      for kk=1:siz[3]-1
         tmp0=Wsink*max.(tmp[:,:,kk],0.0)
         tmp1=Wsink*max.(tmp[:,:,kk],0.0)
         tmp2=isfinite.(tmp[:,:,kk+1])
         tmp1[.!tmp2].=NaN
         xprt[:,:,kk]=tmp1
      end
      xprt[:,:,siz[3]].=NaN

      #println(fil)
      filOut=dirOut*task["OutputFile"]*"/"
      !isdir(filOut) ? mkdir(filOut) : nothing
      filOut=filOut*replace(filList[ff],task["InputFile"][1] => task["OutputFile"])
      f =  FortranFile(filOut,"w",access="direct",recl=recl,convert="big-endian")
      write(f,rec=1,Float32.(xprt))
      close(f)
      #to re-read file:
      #f =  FortranFile(filOut,"r",access="direct",recl=recl,convert="big-endian");
      #tmp1=read(f,rec=1,(Float32,(720,360,50))); close(f);
   end

   return filList
end

"""
    loop_task4(indx)

Loop over model output files and time average them
as a postprocessing step, and write the result
to file (one subfolder for each variable)
"""
function loop_task4(indx)

   task=YAML.load(open("task.yml"))

   dirIn=task["InputDir"]
   filIn=task["InputFile"][1]
   dirOut=task["OutputDir"]
   !isdir(dirOut) ? mkdir(dirOut) : nothing

   siz=Tuple(task["InputSize"])
   prec=Float32

   tmp1=readdir(dirIn*filIn)
   tmp1=filter(x -> occursin(filIn,x),tmp1)
   filList=filter(x -> occursin(".data",x),tmp1)

   #maximum(indx)>length(filList) ? error("missing files: "*filIn*"*") : nothing
   #filList=filList[indx]

   !isa(filList,Array) ? filList=[filList] : nothing
   nf=length(filList)

   YearStart=task["Specs"]["YearStart"]
   YearEnd=task["Specs"]["YearEnd"]
   AverageType=task["Specs"]["AverageType"]

   nrec=missing
   AverageType=="daily" ? nrec=366 : nothing
   AverageType=="monthly" ? nrec=12 : nothing

   dayList=collect(1:nrec)
   dayList=dayList[indx]
   tmpList=Array{Array,1}(undef,nrec)

   for ff=dayList

      #identify all relevant records
      tmp=fill(false,length(filList))
      for ii=1:length(filList)
         if AverageType=="daily"
            tt=DateTime(1992,1,1,12)+Dates.Day(ii-1)
            dd=Day(Dates.Day(1)+tt-DateTime(year(tt),1,1,12))
            year(tt)>=YearStart && year(tt)<=YearEnd && dd.value==ff ? tmp[ii]=true : nothing
         end
         if AverageType=="monthly"
            tt=DateTime(1992,1,15)+Dates.Month(ii-1)
            year(tt)>=YearStart && year(tt)<=YearEnd && Month(tt).value==ff ? tmp[ii]=true : nothing
         end
      end
      recList=findall(tmp)
      tmpList[ff]=recList
      isempty(recList) ? error("no record found to average") : nothing

      println(length(recList))

      #compute time average
      ave = fill(0.0,siz)
      fac = inv(length(recList))
      for ii=recList
         fil=dirIn*filIn*"/"*filList[ii]
         #println(fil)
         tmp=Array{prec,length(siz)}(undef,siz)
         fid = open(fil)
         read!(fid,tmp)
         tmp = hton.(tmp)
         close(fid)
         ave=ave+fac*tmp
      end

      #output to file
      recl=prod(siz)*4
      filOut=dirOut*filIn*"Clim/"
      !isdir(filOut) ? mkdir(filOut) : nothing
      gg=recList[1]
      filOut=filOut*replace(filList[gg],filIn => filIn*"Clim")
      #println(filOut)
      f =  FortranFile(filOut,"w",access="direct",recl=recl,convert="big-endian")
      write(f,rec=1,prec.(ave))
      close(f)
      #to re-read file:
      #f =  FortranFile(filOut,"r",access="direct",recl=recl,convert="big-endian");
      #tmp1=read(f,rec=1,(Float32,(720,360,50))); close(f);

   end

   return tmpList
end
