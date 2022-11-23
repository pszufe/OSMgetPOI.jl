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
    delete_duplicated_elements!(processed_poi_dict::Dict{Int, {ProcessedPOI}}, poi::POIObject, data::Dict{Int, POIObject})

Auxilary function - it mutates processed_poi_dict. Previously, the poi of type POIObject was transformed into 
ProcessedPOI and added to the processed_poi_dict. If the processed_poi_dict already has elements that are child nodes
of poi, then these child elements are deleted from processed_poi_dict.
Arguments: 
- `processed_poi_dict` - a vector of ProcessedPOIs
- `poi` - a POIObject which we are transorming into ProcessedPOI. 
- `data` - a POIobject dataset
"""
function delete_duplicated_elements!(processed_poi_dict::Dict{Int, ProcessedPOI}, poi::POIObject, data::Dict{Int, POIObject})
    if cmp(poi.object_type, "way") == 0
        for node in poi.nodes
            if node in keys(processed_poi_dict)
                delete!(processed_poi_dict, node)
                return processed_poi_dict
            end
        end
    elseif cmp(poi.object_type, "relation") == 0
        for member in poi.members
            if cmp(get(member, "type", missing), "node") == 0
                node = parse(Int, get(member, "ref", 0))
                if node in keys(processed_poi_dict)
                    delete!(processed_poi_dict, node)
                    return processed_poi_dict
                end
            elseif cmp(get(member, "type", missing), "way") == 0
                way_id = parse(Int, get(member, "ref", 0))
                way = get(data, way_id, missing)
                for node in way.nodes
                    if node in keys(processed_poi_dict)
                        delete!(processed_poi_dict, node)
                        return processed_poi_dict
                    end
                end
            end
        end
    end
    return processed_poi_dict
end

###One should think if they want to take the first node to obrain lat-lon (current solution) or maybe calculate an average
"""
    create_poi_dataset(object_data::Dict{POITypes.POIType, Dict{Int, POIObject}})::Vector{ProcessedPOI}

Auxilary function - it returns a processed dataset (vector of elements of type `ProcessedPOI`) 
with the POIs of one POItype.
Arguments:
- `object_data` - it is a raw parsed set of POIObjects (output of `osm_to_dict`)
"""
function create_poi_dataset(object_data::Dict{POITypes.POIType, Dict{Int, POIObject}})::Vector{ProcessedPOI}

    #get the Dict{Int, Vector{POIObject}} generated from osm_to_dict
    poitype = collect(keys(object_data))[1]
    data = get(object_data, poitype, missing)
    
    res = Dict{Int, ProcessedPOI}()
    for (poi_id, poi) in data

        #if the element (object) has tags 
        if poi.has_tags == true
            processed_poi = ProcessedPOI()
            processed_poi.object_id = poi.object_id
            processed_poi.tags = poi.tags
            processed_poi.type = poitype.name
            coordinates = get_coordinates(data, poi_id)
            processed_poi.lat = get(coordinates, "lat", 0)
            processed_poi.lon = get(coordinates, "lon", 0)
            if processed_poi.lat != 0 && processed_poi.lon != 0
                res[processed_poi.object_id] = processed_poi
            end
            
            delete_duplicated_elements!(res, poi, data) #delete duplicated POIs

        end
    end
    res = collect(values(res))
    return res
end


"""
    generate_poi_vectors(osm_filename::String, poitypes::POITypes.POIType...)::Vector{Vector{ProcessedPOI}}

High level function - returns the vector of processed poi datasets.
Each dataset is of a different POIType defined in the function arguments and is represented by a vector of ProcessedPOIs.
Arguments:
- `osm_filename` - name of .osm file from which the POIs are processed and generated
- `poitypes` - all POITypes, for which the dataframe should be generated
"""
function generate_poi_vectors(osm_filename::String, poitypes::POITypes.POIType...)::Vector{Vector{ProcessedPOI}}

    object_data_tuple = map(poitype -> osm_to_dict(osm_filename, poitype), poitypes)    #returns ::NTuple{N, Dict{POITypes.POIType, Dict{Int, POIObject}}} where N is number of poitypes
    processed_poi_tuple = map(create_poi_dataset, object_data_tuple)                    #returns ::NTuple{N, Vector{ProcessedPOI}} where N is number of poitypes
    res = collect(processed_poi_tuple)
    
    return res
end