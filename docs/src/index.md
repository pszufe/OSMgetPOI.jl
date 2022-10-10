```@meta
CurrentModule = POIs
DocTestSetup = quote
    using POIs
end
```

Creating a metadata dictionary for other functions
--------------------------------------------------
```@docs
create_poi_metadata(osm_filename::String, json_filename::String, dir::String = "datasets")
```

Parsing .osm file
-----------------
```@docs
generate_temporary_file(filename::String, metadata::Dict{String, Dict{String, String}})
osm_to_dict(filename::String, metadata::Dict{String, Dict{String, String}}, excluded_keywords::Array{String} = ["text", "bounds"])
delete_version_tags!(dict::Dict{AbstractString, AbstractString})
dict_of_attributes(c::LightXML.XMLElement, name::String = LightXML.name(c))
process_attributes(dict::Dict{String, String})
assign_attr_to_poi_object!(poi::POIObject, attr::Dict{String, String})
```


Creating a vector of POIs for a selected city
-----------------------------------------------
```@docs
get_coordinates_of_way(object_data::Vector{POIObject}, way::POIObject)
get_coordinates(object_data::Vector{POIObject}, element::POIObject)
get_data_vector(metadata::Dict{String, Dict{String, String}})
get_poi_types(metadata::Dict{String, Dict{String, String}})
create_poi_dataset(object_data::Dict{String, Vector{POIObject}}, primary_type::String, subtype::String)
generate_poi_vectors(osm_filename::String, poi_config::String = "POI_config.json")
```


Creating dataframe from one vector of processed POIs (only one POI type)
------------------------------------------------------------------------
```@docs
columns(processed_objects::Vector{ProcessedPOI})
create_df(processed_objects::Vector{ProcessedPOI}, df_columns::Vector{String} = String[])
```

Creating a dataframe from all vectors of POIs (output of generate_poi_vectors function)
---------------------------------------------------------------------------------------
```@docs
columns_in_poi_vector(processed_objects_vector::Vector{Vector{ProcessedPOI}})
create_poi_df(processed_objects_vector::Vector{Vector{ProcessedPOI}})
```

Filtering dataframe columns
---------------------------
```@docs
filter_columns(dframe::DataFrame, threshold::Float64 = 0.5)
```