module OSMgetPOI

    include("POITypes.jl")
    include("types.jl")
    include("osm_parser.jl")
    include("poi_datasets_vector.jl")
    include("dataframe.jl")
    include("download.jl")


    using .POITypes
    using DataFrames
    using LightXML
    using JSON3
    using Downloads
    using TranscodingStreams
    using CodecZlib 
    using LightXML 
    using CodecBzip2
    export get_poi_df, download_bbbike_file, download_geofabrik_file #functions

end # module