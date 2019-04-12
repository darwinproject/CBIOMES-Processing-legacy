using Documenter
using CbiomesProcessing

makedocs(
    sitename = "CbiomesProcessing",
    format = :html,
    modules = [CbiomesProcessing]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
