using LightXML


function delete_version_tags!(dict::Dict{AbstractString, AbstractString})::Dict{String, Any}
    if haskey(dict, "version") delete!(dict, "version") end
    return dict
end

function dict_of_attributes(c::LightXML.XMLElement, name::String = LightXML.name(c))::Dict{String, Any}
    attr = LightXML.attributes_dict(c)
    delete_version_tags!(attr)
    attr["object"] = name
    return attr
end

function process_attributes(dict::Dict{String, Any})::Dict{String, Any}
    if cmp(get(dict, "object", missing), "tag") == 0
        key = get(dict, "k", missing)
        value = get(dict, "v", missing)
        res = Dict(key => value)
    
    elseif cmp(get(dict, "object", missing), "nd") == 0
        key = "ref"
        value = get(dict, "ref", missing)
        res = Dict(key => value)

    elseif cmp(get(dict, "object", missing), "member") == 0
        res = delete!(dict, "object")
    end

    return res
end

function generate_temporary_file(filename::String, metadata::Dict{String, Dict{String, String}})
    file_metadata = get(metadata, filename, missing)
    osm_query = get(file_metadata, "osm_query", missing)
    output_filepath = get(file_metadata, "output_filepath", missing)
    input_filepath = get(file_metadata, "input_filepath", missing)
    generate_file = pipeline(`osmfilter $input_filepath $osm_query`, stdout = output_filepath)
    print(osm_query)
    print("\n")
    run(generate_file)
    return output_filepath
end

"""
    osm_to_dict(filename::String, metadata::Dict{String, Dict{String, String}}, excluded_keywords::Array{String} = ["text", "bounds"])::Dict{String, Vector{Dict{String, Any}}}

High level function - parses .osm file and into a dictionary where the dictionary key is a name of a temporary file,
and dictionary value is a vector of all osm objects from the file. A single object is represented as a dictionary with following keys:
* lat - latitude
* lon - longitude
* object_id - object type (node / way / relation)
* id - object id from osm file
* [optional] tags - osm tags describing the object (type of this k-v pair is Dict{String, Dict{String, String}})
* [optional] nodes - vector of nodes included in the way 
* [optional] members - vector of members of the relation (type of this k-v pair is Dict{String, Vector{Dict{String, String}}})
"""


function osm_to_dict(filename::String, metadata::Dict{String, Dict{String, String}},
                    excluded_keywords::Array{String} = ["text", "bounds"])::Dict{String, Vector{Dict{String, Any}}}
    
    #generate temporary file
    output_filepath = generate_temporary_file(filename, metadata)

    #processing of .osm file
    osm = LightXML.parse_file(output_filepath)
    rootnode = LightXML.root(osm)
    res = Vector{Dict{String, Any}}()
    for c in child_elements(rootnode)
        name = LightXML.name(c)
        attr = dict_of_attributes(c)
        
        if name ∉ excluded_keywords && !has_children(c)
            push!(res, attr)

        elseif name ∉ excluded_keywords && has_children(c)
            
            for c2 in child_elements(c)
                raw_attributes = dict_of_attributes(c2)
                attributes = process_attributes(raw_attributes)

                if cmp(LightXML.name(c2), "tag") == 0
                    if !(haskey(attr, "tags"))
                        attr["tags"] = Dict{String, Any}()
                    end
                    merge!(attr["tags"], attributes)

                elseif cmp(LightXML.name(c2), "nd") == 0
                    if !(haskey(attr, "nd"))
                        attr["nd"] = Vector{String}()
                    end
                    push!(attr["nd"], attributes["ref"])

                elseif cmp(LightXML.name(c2), "member") == 0
                    if !(haskey(attr, "members"))
                        attr["members"] = Vector{Dict{String, Any}}()
                    end
                    push!(attr["members"], attributes)
                end
            end
            push!(res, attr)
            
        end
    end
    
    #deleting the temporary file
    run(`rm -f $output_filepath`) 
    
    return Dict{String, Vector{Dict{String, Any}}}(filename => res)
    
end
