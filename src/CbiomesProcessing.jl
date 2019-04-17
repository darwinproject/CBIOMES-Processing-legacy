module CbiomesProcessing

using MAT, SparseArrays, Plots, MeshArrays
using Distributed, DistributedArrays, FortranFiles

include("byproducts.jl")
include("fileloops.jl")
include("examples.jl")

export AverageYear, interp_SPM, read_SPM, MetaFileRead, start_workers
export loop_exampleA, loop_exampleB, loop_exampleC
export cbioproc_example1, cbioproc_example2, cbioproc_example3

"""
    greet()

Just say Hi.
"""
greet() = print("Hi There!")

end # module
