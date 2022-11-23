module OSMgetPOI

    include("POITypes.jl")
    include("types.jl")
    include("osm_parser.jl")
    include("poi_datasets_vector.jl")
    include("dataframe.jl")


    using .POITypes
    using DataFrames
    using LightXML
    using JSON3
    export filter_columns_by_threshold, create_poi_df, create_df_from_osm_file #functions

end # module