push!(LOAD_PATH,"../src/")
using Documenter, OSMgetPOI

makedocs(sitename="My Documentation", modules = [OSMgetPOI])