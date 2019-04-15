module CbiomesProcessing

using MAT, SparseArrays, Plots, MeshArrays

#greet() = print("Hello World! [2]")

include("byproducts.jl")
include("fileloops.jl")
include("examples.jl")

export AverageYear, interp_SPM, read_SPM, loop_example1
export cbioproc_example1, cbioproc_example2

end # module
