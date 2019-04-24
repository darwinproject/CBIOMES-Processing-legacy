# CbiomesProcessing.jl documentation

**CbiomesProcessing.jl** provides a simple, distributed workflow to e.g. post-process binary model output. Inter-operability with `MeshArrays.jl` and `NCTiles.jl` is an important prospect of this package.

## Contents

```@contents
```

## Main Features

Currently the reference implementation consists of
- [`TaskDriver()`](@ref) (inside `utilities.jl`) is the driver function
    - It calls e.g. `loop_task1.(i)`
- [`CbiomesProcessing.loop_task1(indx::Int)`](@ref) (inside `fileloops.jl`) loads `M` from `MTRX.jld`
    - It calls `loop_task1(indx,M)`
- [`CbiomesProcessing.loop_task1(indx,M)`](@ref) (inside `fileloops.jl`) loops over files and variables
    - It calls `MatrixInterp(in,MTRX,siz) ` and writes result to a `FortranFile`

[API / Functions](@ref) further documents the `CbiomesProcessing` module functions that are included in:

- `examples.jl` includes simple examples without `TaskDriver`.
- `fileloops.jl` includes task loops such as `CbiomesProcessing.loop_task1()`](@ref). A real-life example is provided in the [`TaskDriver`](@ref) documentation reported below.
- `utilities.jl` provides low-level functions such as [`TaskDriver`](@ref), [`MatrixInterp()`](@ref), and [`MetaFileRead()`](@ref).

## Index

```@index
```

## API / Functions

```@autodocs
Modules = [CbiomesProcessing]
Order   = [:function, :type]
```
