# CbiomesProcessing.jl documentation

The **CbiomesProcessing.jl** package implements a distributed workflow to post-process model output. For now, the driver function loop over files applies a pre-existent interpolation scheme. Additional functionalities (e.g., `OC-CCI` variable derivations) are expected to be added later and operated via the same workflow. Inter-operability with `MeshArrays.jl` is also a prospect.

## Contents

```@contents
```

## Main Features

Currently the reference implementation consists of
- [`cbioproc_distribute()`](@ref) (inside `examples.jl`) is the driver function
    - It calls `cbioproc_task1.(i)`
- [`cbioproc_task1()`](@ref) (inside `examples.jl`) loads `MTRX.jld`
    - It calls `loop_task1(indx,M["MTRX"],M["siz2d"],M["msk2d"])`
- [`loop_task1()`](@ref) (inside `fileloops.jl`) loops over file sets and variables
    - It calls `interp_SPM` and then writes the result to a `FortranFile`

#### More Notes

[API / Functions](@ref) further documents the `CbiomesProcessing` module functions that are included in:

- `examples.jl` includes simple top-level function examples (see [Examples](@ref))
- `fileloops.jl` includes loops over binary files (e.g., see [`loop_exampleB()`](@ref))
- `byproducts.jl` provides lower-level operations such as [`interp_SPM()`](@ref) and [`MetaFileRead()`](@ref).

## Examples

The real-life example is provided in the [`cbioproc_distribute`](@ref) documentation provided below. Examples that cover subsets of what `cbioproc_distribute` does are as follows.

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

## API / Functions

```@autodocs
Modules = [CbiomesProcessing]
Order   = [:function, :type]
```
