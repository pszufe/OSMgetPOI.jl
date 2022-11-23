# OSMgetPOI

```@meta
CurrentModule = OSMgetPOI
DocTestSetup = quote
    using OSMgetPOI
end
```

Parsing .osm file
-----------------
```@docs
delete_version_tags!(dict::Dict{AbstractString, AbstractString})
dict_of_attributes(c::LightXML.XMLElement, name::String = LightXML.name(c))
process_attributes(dict::Dict{String, String})
assign_attr_to_poi_object!(poi::POIObject, attr::Dict{String, String})
generate_temporary_file(osm_filename::String, poitype::POITypes.POIType)
osm_to_dict(osm_filename::String, poitype::POITypes.POIType, excluded_keywords::Array{String} = ["text", "bounds"])
```


Vector of POIs
--------------
```@docs
get_coordinates_of_way(object_data::Dict{Int, POIObject}, way_id::Int)
get_coordinates(object_data::Dict{Int, POIObject}, poi_id::Int)
create_poi_dataset(object_data::Dict{POITypes.POIType, Dict{Int, POIObject}})
generate_poi_vectors(osm_filename::String, poitypes::POITypes.POIType...)
```


Creating dataframe of POIs (one POI type)
-----------------------------------------
```@docs
columns(processed_objects::Vector{ProcessedPOI})
create_df(processed_objects::Vector{ProcessedPOI}, df_columns::Vector{String} = String[])
```

Creating a dataframe of all POIs
--------------------------------
```@docs
columns_in_poi_vector(processed_objects_vector::Vector{Vector{ProcessedPOI}})
create_poi_df(processed_objects_vector::Vector{Vector{ProcessedPOI}}, threshold::Float64 = 0.3)
```

Creating a dataframe of all POIs from .osm file
-----------------------------------------------
```@docs
create_df_from_osm_file(osm_filename::String, threshold::Float64 = 0.3, poitypes::POITypes.POIType...)
```

Filtering dataframe columns
---------------------------
```@docs
filter_columns_by_threshold(dframe::DataFrame, threshold::Float64 = 0.5)
```