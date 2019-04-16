module CbiomesProcessing

using MAT, SparseArrays, Plots, MeshArrays

include("byproducts.jl")
include("fileloops.jl")
include("examples.jl")

export AverageYear, interp_SPM, read_SPM, MetaFileRead
export loop_exampleA, loop_exampleB
export cbioproc_example1, cbioproc_example2

"""
    greet()

Just say Hi.
"""
greet() = print("Hi There!")

end # module
