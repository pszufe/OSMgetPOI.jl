using JSON3

######################################################
######Creating a metadata dictionary##################
######################################################

"""
    create_poi_metadata(osm_filename::String, json_filename::String, dir::String = "datasets")

Auxilary function - it returns a dictionary of metadata which is used as an argument in several other functions.
Arguments:
- json_filename - a JSON file where the types and subtypes of POIs are configured (check datasets/POI_config.json as an example)
- dir - a directory where the the JSON file is located and where the .osm files are located.

Description of returned metadata dictionary:
The keys of the dictionary are the names of temporary files which are used to obtain POIs using function osm_to_dict from src/osm_parser.
The values are dictionaries of metadata for each of the temporary files, in the following form:
Dict("primary_type" => primary_type, "subtype" => subtype, "city" => city, "input_filepath" => input_filepath, "osm_query" => osm_query, "output_filepath" => output_filepath)
The dictionary keys have the following meanings:
- primary_type - primary_type taken from the JSON file
- subrype - subtype taken from the JSON file
- city - city name extracted from the name of the .osm file located in the 'dir' directory (e.g. if the file name is 'Beijing.osm', then the city is 'beijing')
- input_filepath - it is used in osm_to_dict to locate the .osm file, which is processed with osm_filter
- osm_query - this is a query to obtain the temporary file (e.g. --keep=amenity=school) from which POIs are extracted using function osm_to_dict from src/osm_parser.
- output_filepath - this is the path to the temporary file which is created to extract the POIs from .osm file
"""
function create_poi_metadata(osm_filename::String, json_filename::String, dir::String = "datasets")::Dict{String, Dict{String, String}}

    city = lowercase(chop(osm_filename, tail = 4))
    input_file = osm_filename
    input_filepath = dir * "/" * input_file

    json = JSON3.read(read(dir * "/" * json_filename))
    res = Dict{String, Dict{String, String}}()
    for dictionary in json
        primary_type = dictionary["primary_type"]
        subtypes_vector = dictionary["subtypes"]
        
        for element in subtypes_vector
            subtype = element["subtype"]
            osm_query = element["query"]
            output_file = primary_type * "_" * subtype * "_" * lowercase(osm_filename)
            output_filepath = dir * "/" * output_file

            dict_entry = Dict("primary_type" => primary_type, "subtype" => subtype, "city" => city, "input_filepath" => input_filepath, "osm_query" => osm_query, "output_filepath" => output_filepath)
            res[output_file] = dict_entry
        end
    end
    
    return res
end