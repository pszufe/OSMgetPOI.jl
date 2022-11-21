using Test
include("../src/OSMgetPOI.jl")
using .OSMgetPOI

@testset "general" begin
    #get variables
    poi_vector = generate_poi_vectors("UlanBator.osm", directory = "data", poi_config = "POI_config.json")
    df = create_poi_df(poi_vector, 0.0)
    df_filtered_by_threshold = filter_columns_by_threshold(df, 0.1)
    
    #tests for generate_poi_vectors
    @test length(poi_vector) == 25
    @test length(poi_vector[2]) == 873
    @test poi_vector[2][400].tags == Dict{String, String}("amenity" => "parking")
    @test typeof(poi_vector[4][170].object_id) == Int64
    @test poi_vector[1][2].lat != poi_vector[1][2].lon

    #tests for create_poi_df
    @test !(0 in df.lat)
    @test ndims(names(df)) == 1
    @test length(names(df)) == 256
    @test df[6, 6] == "arts_centre"
    @test size(df) == (8025, 256)
    @test length(collect(skipmissing(df.name))) == 6232

    #tests for df_filtered_by_threshold
    @test size(df_filtered_by_threshold)[2] == 21
    @test length(names(filter_columns_by_threshold(df, 0.2))) <= length(names(filter_columns_by_threshold(df, 0.1)))
end