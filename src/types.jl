###################################
###Define type for handling POIs###
###################################

mutable struct POIObject
    object_id::Int
    object_type::String
    lat::Float64
    lon::Float64
    has_tags::Bool
    tags::Dict{String, String}
    nodes::Vector{Int}
    members::Vector{Dict{String, Union{String, Int}}}
    POIObject() = new(0, "", 0, 0, false, Dict{String, String}(), Vector{Int}(), Vector{Dict{String, Union{String, Int}}}())
end


mutable struct ProcessedPOI
    primary_type::String
    subtype::String
    object_id::Int
    tags::Dict{String, String}
    lat::Float64
    lon::Float64
    ProcessedPOI() = new()
end