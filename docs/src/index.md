# CbiomesProcessing.jl documentation

To be continued ...

## contents

```@contents
```

In an early implementation (see [dev1](@ref)), the `CbiomesProcessing` module included:

- `examples.jl` provides top-level driver examples (see [examples](@ref))
- `fileloops.jl` loops over binary files (e.g., see [`loop_exampleB()`](@ref))
- `byproducts.jl` low-level operations such as [`read_SPM()`](@ref), [`interp_SPM()`](@ref), and [`MetaFileRead()`](@ref).

## examples

```
shell> tar xf env.tar
shell> cd env
shell> mkdir devel/interp_output/
shell> cp -p devel/interp_precomputed.mat devel/interp_output/

julia> using CbiomesProcessing
julia> outLoop1,outName=cbioproc_example1()
julia> outLoop2,outMsk=cbioproc_example2()
```

## Index

```@index
```

## dev1

```@docs
cbioproc_example1()
cbioproc_example2()
```

```@docs
loop_exampleA(indx,SPM,siz)
loop_exampleB(indx,SPM,siz)
```

```@docs
read_SPM(dirIn::String)
interp_SPM(in::Array{T,N}) where {T,N}
interp_SPM(in::Array{T,N},SPM,siz) where {T,N}
MetaFileRead(filIn::String)
```
