module CbiomesProcessing

using JLD, MAT, SparseArrays, Plots, MeshArrays
using Distributed, DistributedArrays, FortranFiles

include("byproducts.jl")
include("fileloops.jl")
include("examples.jl")

export cbioproc_distribute, cbioproc_task1, loop_task1
export prep_interp_jld, MetaFileRead, start_workers

export interp_SPM, read_SPM
export loop_exampleA, loop_exampleB
export cbioproc_example1, cbioproc_example2, cbioproc_example3

#export AverageYear

end # module
