using LightXML

########################
###Parsing .osm file ###
########################

"""
    delete_version_tags!(dict::Dict{AbstractString, AbstractString})::Dict{String, String}

Auxilary function used in `osm_to_dict` to parse .osm file.
"""
function delete_version_tags!(dict::Dict{AbstractString, AbstractString})::Dict{String, String}
    if haskey(dict, "version") delete!(dict, "version") end
    return dict
end


"""
    dict_of_attributes(c::LightXML.XMLElement, name::String = LightXML.name(c))::Dict{String, String}

Auxilary function used in `osm_to_dict` to parse .osm file.
"""
function dict_of_attributes(c::LightXML.XMLElement, name::String = LightXML.name(c))::Dict{String, String}
    attr = LightXML.attributes_dict(c)
    delete_version_tags!(attr)
    attr["object"] = name
    return attr
end


"""
    process_attributes(dict::Dict{String, String})::Dict{String, Union{Int, String}}

Auxilary function used in `osm_to_dict` to parse .osm file.
"""
function process_attributes(dict::Dict{String, String})::Dict{String, Union{Int, String}}
    if cmp(get(dict, "object", missing), "tag") == 0
        key = get(dict, "k", missing)
        value = get(dict, "v", missing)
        res = Dict(key => value)
    
    elseif cmp(get(dict, "object", missing), "nd") == 0
        key = "ref"
        value = parse(Int, get(dict, "ref", missing))
        res = Dict(key => value)

    elseif cmp(get(dict, "object", missing), "member") == 0
        res = delete!(dict, "object")
    end
    
    return res
end


"""
    assign_attr_to_poi_object!(poi::POIObject, attr::Dict{String, String})

Auxilary function used in `osm_to_dict` to parse .osm file.
"""
function assign_attr_to_poi_object!(poi::POIObject, attr::Dict{String, String})
    poi.object_id = parse(Int, get(attr, "id", missing))
    poi.object_type = get(attr, "object", missing)
    if cmp(poi.object_type, "node") == 0
        poi.lat = parse(Float64, get(attr, "lat", 0))
        poi.lon = parse(Float64, get(attr, "lon", 0))
    end
    return poi
end


"""
    generate_temporary_file(osm_filename::String, poi_type::POITypes.POIType)

Auxilary function - it generates a temporary file for further processing and returns a filepath of this file
Arguments:
- `osm_filename` - name of the temporary file thich is to be generated
- `poi_type` - POIType for which the temporary file is to be genarated
"""
function generate_temporary_file(osm_filename::String, poi_type::POITypes.POIType)
    osm_query = poi_type.query
    output_filepath = tempname(pwd()) * ".osm"
    input_filepath = osm_filename
    if Sys.isapple() 
        generate_file = pipeline(`osmfilter $input_filepath $osm_query`, stdout = output_filepath)
    elseif Sys.iswindows() || Sys.islinux()
        osmfiler_path = joinpath(pathof(OSMgetPOI),"..","..","deps","osmfilter")
        generate_file = pipeline(`$osmfiler_path $input_filepath $osm_query`, stdout = output_filepath)
    end
    process_time = @elapsed run(generate_file) #checking how long it takes to run this function
    #print("OSM filter process time: ", process_time, "\n")
    return output_filepath
end


"""
    osm_to_dict(osm_filename::String, poi_type::POITypes.POIType, excluded_keywords::Array{String} = ["text", "bounds"])::Dict{POITypes.POIType, Dict{Int, POIObject}}

Auxilary function - parses .osm file and returns a dictionary whose key is a ::POIType
and value is a vector of parsed POIs. A single POI is represented as a `POIObject` type which is a mutable struct
with fields defined in `src/types.jl`.
Arguments:
- `osm_filename` - the name of the .osm file that the function parses (e.g. beijing.osm)
- `poi_type` - a POIType for which the file is parsed
- `excluded_keywords` - keywords in .osm file excluded from parsing. Suggested to use the default.
"""
function osm_to_dict(osm_filename::String, poi_type::POITypes.POIType, excluded_keywords::Array{String} = ["text", "bounds"])::Dict{POITypes.POIType, Dict{Int, POIObject}}
    
    #generate temporary file
    output_filepath = generate_temporary_file(osm_filename, poi_type)

    #processing of .osm file
    osm = LightXML.parse_file(output_filepath)
    rootnode = LightXML.root(osm)
    res = Dict{Int, POIObject}()

    for c in child_elements(rootnode)
        name = LightXML.name(c)
        attr = dict_of_attributes(c)
        poi = POIObject()

        if name ∉ excluded_keywords && !has_children(c)
            assign_attr_to_poi_object!(poi, attr)
            res[poi.object_id] = poi

        elseif name ∉ excluded_keywords && has_children(c)
            assign_attr_to_poi_object!(poi, attr)
            
            for c2 in child_elements(c)
                raw_attributes = dict_of_attributes(c2)
                attributes = process_attributes(raw_attributes)

                if cmp(LightXML.name(c2), "tag") == 0
                    poi.has_tags = true
                    merge!(poi.tags, attributes)

                elseif cmp(LightXML.name(c2), "nd") == 0
                    push!(poi.nodes, get(attributes, "ref", missing))

                elseif cmp(LightXML.name(c2), "member") == 0
                    push!(poi.members, attributes)
                end
            end
            res[poi.object_id] = poi
            
        end
    end
    
    #deleting the temporary file
    run(`rm -f $output_filepath`)
    
    return Dict{POITypes.POIType, Dict{Int, POIObject}}(poi_type => res)

end