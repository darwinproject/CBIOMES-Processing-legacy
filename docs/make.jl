using Documenter
using CbiomesProcessing

makedocs(
    sitename = "CbiomesProcessing",
    format = :html,
    modules = [CbiomesProcessing]
    pages = Any[
    "Home" => "index.md",
    "Codes" => "sepdev1.md"
    ]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/gaelforget/CBIOMES-Processing.jl.git",
)
