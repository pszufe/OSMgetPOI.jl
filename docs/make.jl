push!(LOAD_PATH,"../src/")
using Documenter, POIs

makedocs(sitename="My Documentation", modules = [POIs])