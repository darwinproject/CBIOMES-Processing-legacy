module CbiomesProcessing

using JLD, MAT, YAML, SparseArrays, MeshArrays, Plots, Dates
using Distributed, DistributedArrays, FortranFiles

include("byproducts.jl")
include("fileloops.jl")
include("examples.jl")

export StartWorkers, TaskDriver, MetaFileRead, MatrixInterp
export cbioproc_example1, cbioproc_example2

#export AverageYear

end # module
