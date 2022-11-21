#########################################################
##Creating vector of processed POIs for a selected city##
#########################################################

"""
    get_coordinates_of_way(object_data::Dict{Int, POIObject}, way_id::Int)::Dict{String, Float64}

Auxilary function used inside `get_coordinates` function.
Arguments:
- `object_data` - a vector of POI objects in which an element is located
- `way` - a way for which one wants to find a lat-lon coordinates, represented by POIObject.
"""
function get_coordinates_of_way(object_data::Dict{Int, POIObject}, way_id::Int)::Dict{String, Float64}
    res = Dict{String, Float64}()
    way = get(object_data, way_id, missing)
    if !isempty(way.nodes)
        for node_id in way.nodes
            node = get(object_data, node_id, missing)
            res["lat"] = node.lat
            res["lon"] = node.lon
            return res
        end
    else
        res["lat"] = 0
        res["lon"] = 0
        return res
    end
end


"""
    get_coordinates(object_data::Dict{Int, POIObject}, poi_id::Int)::Dict{String, Float64}

Auxilary function - it returns lat and lon coordinates of a POI object. If not found, then they are 0.
Arguments: 
- `object_data` - a vector of POI objects in which an element is located
- `element` - a POI object for which the coordinates are to be found
"""
function get_coordinates(object_data::Dict{Int, POIObject}, poi_id::Int)::Dict{String, Float64}
    res = Dict{String, Float64}()
    object = get(object_data, poi_id, missing)
    
    if cmp(object.object_type, "node") == 0
        res["lat"] = object.lat
        res["lon"] = object.lon
        return res
    
    elseif cmp(object.object_type, "way") == 0
        res = get_coordinates_of_way(object_data, object.object_id)
        return res

    elseif cmp(object.object_type, "relation") == 0 
        if isempty(object.members)
            res["lat"] = 0
            res["lon"] = 0
            return res
        else
            for member in object.members
                member_id = parse(Int, get(member, "ref", missing))
                member_element = get(object_data, member_id, missing)
                if cmp(member_element.object_type, "node") == 0
                    res["lat"] = object.lat
                    res["lon"] = object.lon
                    return res
                elseif cmp(member_element.object_type, "way") == 0
                    res = get_coordinates_of_way(object_data, member_element.object_id)
                    return res
                end
            end
        end
    end
    return res
end


"""
    get_data_vector(metadata::Dict{String, Dict{String, String}})::Vector{Dict{String, Dict{Int, POIObject}}}
    
Auxilary function - it returns a vector of dictionaries - each of them being generated 
using `osm_to_dict` function from `src/osm_parser.jl`. The number of elements of dictionary depends on the metadata.
Arguments:
- `metadata` - metadata dictionary generated using function `create_poi_metadata` from `src/poi_metadata.jl`
"""
function get_data_vector(metadata::Dict{String, Dict{String, String}})::Vector{Dict{String, Dict{Int, POIObject}}}
    datasets = collect(keys(metadata))
    res = map(x -> osm_to_dict(x, metadata), datasets)
    return res
end


"""
    get_poi_types(metadata::Dict{String, Dict{String, String}})::Tuple{Vector{String}, Vector{String}}

Auxilary funtion - it returns a tuple of vectors - each vector representing primary_types or subtypes extrcted from a metadata dictionary.
Arguments:
- `metadata` - metadata dictionary generated using function create_poi_metadata from `src/poi_metadata.jl`
"""
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
    create_poi_dataset(object_data_vector::Dict{String, Dict{Int, POIObject}}, primary_type::String, subtype::String)::Vector{ProcessedPOI}

Auxilary function - it returns a processed dataset (vector of elements of type `ProcessedPOI`) 
with the POIs of one type (`primary_type` and `subtype`).
Arguments:
- `object_data` - it is a raw parsed set of POI objects (output of `osm_to_dict`)
- `primary_type` - this is a primary type that will be assigned to the processed POIs
- `subtype` - this is a subtype that will be assigned to the processed POIs

"""
function create_poi_dataset(object_data_vector::Dict{String, Dict{Int, POIObject}}, primary_type::String, subtype::String)::Vector{ProcessedPOI}

    #get the Dict{Int, Vector{POIObject}} generated from osm_to_dict
    data = get(object_data_vector, collect(keys(object_data_vector))[1], missing)
    
    res = Vector{ProcessedPOI}()
    for (poi_id, poi) in data

        #if the element (object) has tags 
        if poi.has_tags == true
            processed_poi = ProcessedPOI()
            processed_poi.object_id = poi.object_id
            processed_poi.tags = poi.tags
            processed_poi.primary_type = primary_type
            processed_poi.subtype = subtype
            coordinates = get_coordinates(data, poi_id)
            processed_poi.lat = get(coordinates, "lat", 0)
            processed_poi.lon = get(coordinates, "lon", 0)
            if processed_poi.lat != 0 && processed_poi.lon != 0
                push!(res, processed_poi)
            end
        end
    end
    return res
end


"""
    generate_poi_vectors(osm_filename::String; directory = "datasets", poi_config::String = "POI_config.json")::Vector{Vector{ProcessedPOI}}

High level function - returns the vector of processed poi datasets. 
Each dataset is from a different type and subtype and is represented by a vector of processed POIs.
Arguments:
- `osm_filename` - name of .osm file from which the POIs are processed and generated
- `directory` - directory where the .osm file is located
- `poi_config` - a JSON file with configuration of the POIs that are to be generated.

The function works in the following way step by step:
1. It creates the metadata for a desired .osm file, based on JSON dictionary with config.
2. It creates a vector of raw datasets for each of the files from metadata. The datasets are generated using the `osm_to_dict` function from `src/osm_parser.jl`.
3. It creates vectors of `primary_types` and `subtypes` based on the metadata.
4. It transforms each raw dataset (each element of the vector) to the processed dataset with POis using a function `generate_poi_dataset`.
"""
function generate_poi_vectors(osm_filename::String; directory = "datasets", poi_config::String = "POI_config.json")::Vector{Vector{ProcessedPOI}}

    metadata = create_poi_metadata(osm_filename, directory, poi_config)
    object_data_vector = get_data_vector(metadata)
    (primary_type_vector, subtype_vector) = get_poi_types(metadata)
    
    res = map(create_poi_dataset, object_data_vector, primary_type_vector, subtype_vector)
    return res
end