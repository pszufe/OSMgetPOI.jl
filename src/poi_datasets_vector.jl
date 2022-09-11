include("osm_parser.jl")
include("poi_metadata.jl")


#########################################################
##Creating vector of processed POIs for a selected city##
#########################################################


function get_coordinates(object_data::Vector{Dict{String, Any}}, node_id::String)::Dict{String, Any}
    res = Dict{String, Any}()
    for node in object_data
        if cmp(get(node, "id", missing), node_id) == 0
            res["lat"] = get(node, "lat", missing)
            res["lon"] = get(node, "lon", missing)
            break
        else
            res["lat"] = "NA"
            res["lon"] = "NA"
        end
    end
    return res
end


function id_of_first_node(way::Dict{String, Any})::String
    if haskey(way, "nd")
        nodes = get(way, "nd", missing)
        node_id = nodes[1]
        return node_id
    else
        return "NA"
    end
end


function get_node_id(object_data::Vector{Dict{String, Any}}, element::Dict{String, Any})::String
    
    if cmp(get(element, "object", missing), "way") == 0 
        node_id = id_of_first_node(element)

    elseif cmp(get(element, "object", missing), "relation") == 0 
        if haskey(element, "members")
            members = get(element, "members", missing)
            member = members[1]
            way_id = get(member, "ref", missing)
            local node_id
            for way in object_data
                if cmp(get(way, "id", missing), way_id) == 0
                    node_id = id_of_first_node(way)
                    break
                end
            end
        end
    end
    return node_id
end


function get_data_vector(metadata::Dict{String, Dict{String, String}})::Vector{Dict{String, Vector{Dict{String, Any}}}}
    datasets = collect(keys(metadata))
    res = map(x -> osm_to_dict(x, metadata), datasets)
    return res
end


function get_poi_types(metadata::Dict{String, Dict{String, String}})::Tuple{Vector{String}, Vector{String}}
    
    primary_type_vector = String[]
    subtype_vector = String[]

    for (key, value) in metadata
        push!(primary_type_vector, get(value, "primary_type", missing))
        push!(subtype_vector, get(value, "subtype", missing))
    end
    
    return (primary_type_vector, subtype_vector)
end


###One should think if they want to take the first node to obrain lat-lon (current solution) or maybe calculate an average

"""
    create_poi_dataset(object_data::Dict{String, Vector{Dict{String, Any}}}, primary_type::String, subtype::String)::Vector{Dict{String, Any}}

Auxilary function - it takes one raw dataset (output of osm_to_dict) as an argument and returns a processed dataset with the POIs.
The processed dataset is a vector of POIs. Each POI is represented by a dictionary with the following keys:
* primaty_type - extracted from using a function get_poi_types
* subtype - extracted from using a function get_poi_types
* object_id - id of an object
* node_id - it is an id of the node, for which lat-lon coordinates are taken
* tags - additional tags that describe the POI
* lat - latitude
* lon - longitude

"""


function create_poi_dataset(object_data::Dict{String, Vector{Dict{String, Any}}}, primary_type::String, subtype::String)::Vector{Dict{String, Any}}
    
    data = get(object_data, collect(keys(object_data))[1], missing)
    
    res = Dict{String, Any}[]
    for element in data
        #if the element (object) has tags and it is either a way or a relation
        if haskey(element, "tags") && (cmp(get(element, "object", missing), "way") == 0 || cmp(get(element, "object", missing), "relation") == 0)
            
            object_id = get(element, "id", missing)
            tags = get(element, "tags", missing)
            node_id = get_node_id(data, element)
            object = Dict{String, Any}("primary_type" => primary_type, "subtype" => subtype, "object_id" => object_id, "node_id" => node_id, "tags" => tags)
            coordinates = get_coordinates(data, node_id)
            merge!(object, coordinates)
            push!(res, object)
            
        end
    end
    return res
end


"""
    generate_poi_vectors(city::String, metadata::Dict{String, Dict{String, String}} = poidict)::Vector{Vector{Dict{String, Any}}}

High level function - it takes a city as an argument and returns the vector of processed poi datasets
(each dataset is a separate element of the vector). The function works in the following way step by step:
1. It creates the metadata for a desired .osm file, based on JSON dictionary with config.
2. It creates a vector of raw datasets for each of the files from metadata. 
The datasets are generated using the osm_to_dict function from `src/osm_parser.jl`.
3. It transforms each raw dataset (each element of the vector) to the processed dataset with POis using a function generate_poi_dataset.

"""


function generate_poi_vectors(osm_filename::String, poi_config::String = "POI_config.json")::Vector{Vector{Dict{String, Any}}}

    metadata = create_poi_metadata(osm_filename, poi_config)
    object_data_vector = get_data_vector(metadata)
    (primary_type_vector, subtype_vector) = get_poi_types(metadata)
    
    res = map(create_poi_dataset, object_data_vector, primary_type_vector, subtype_vector)
    return res
end