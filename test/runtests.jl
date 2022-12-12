using Test
include("../src/OSMgetPOI.jl")
using .OSMgetPOI

@testset "general" begin
    
    ##############################
    #TESTS FOR DOWNLOAD FUNCTIONS#
    ##############################

    #download datasets
    geofabrik_filepath = tempname()
    geofabrik_file = download_geofabrik_file("https://download.geofabrik.de/asia/bhutan-latest.osm.bz2"; target_filepath = geofabrik_filepath)
    bbike_file = download_bbbike_file("https://download.bbbike.org/osm/bbbike/UlanBator/UlanBator.osm.gz")

    #tests for file names of download functions
    @test cmp("datasets/file.osm", bbike_file) == 0
    @test cmp(geofabrik_file, geofabrik_filepath * ".osm") == 0

    #create the dataframes with extracted POIs
    bbike_dataframe = get_poi_df(bbike_file, OSMgetPOI.POITypes.education_school, OSMgetPOI.POITypes.transport_busstop, OSMgetPOI.POITypes.cuisine_restaurant; columns = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country", "amenity"])
    bbike_dataframe2 = get_poi_df("datasets/file.osm", OSMgetPOI.POITypes.education_school, OSMgetPOI.POITypes.transport_busstop, OSMgetPOI.POITypes.cuisine_restaurant; columns = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country", "amenity"])
    geofabrik_dataframe = get_poi_df(geofabrik_file, OSMgetPOI.POITypes.healthcare_doctor,  OSMgetPOI.POITypes.healthcare_pharmacy,  OSMgetPOI.POITypes.healthcare_hospital)

    #check that bbike_dataframe and bbike_dataframe2 are the same
    @test size(bbike_dataframe,1) == size(bbike_dataframe2,1)
    @test length(names(bbike_dataframe)) == length(names(bbike_dataframe2))
    @test bbike_dataframe[90,2] == bbike_dataframe2[90,2]

    #tests for bbike_dataframe
    @test !(0 in bbike_dataframe.lat)
    @test !(0 in bbike_dataframe.lon)
    @test size(bbike_dataframe,1) != 0
    @test length(collect(names(bbike_dataframe))) != 0
    @test ["poi_type", "lat", "lon", "amenity", "addr:street", "addr:housenumber", "addr:postcode", "addr:country"] == collect(names(bbike_dataframe2))

    #tests for geofabrik_dataframe
    @test !(0 in geofabrik_dataframe.lat)
    @test !(0 in geofabrik_dataframe.lon)
    @test size(geofabrik_dataframe,1) != 0
    @test length(collect(names(geofabrik_dataframe))) != 0
    @test ["poi_type", "lat", "lon", "addr:street", "addr:postcode", "addr:housenumber"] == collect(names(geofabrik_dataframe))


    ##################################
    #TESTS FOR CREATE POI DF FUNCTION#
    ##################################

    #create dataframes the attached UlanBator.osm test file
    df1 = get_poi_df("test/data/UlanBator.osm", OSMgetPOI.POITypes.healthcare_doctor,  OSMgetPOI.POITypes.healthcare_pharmacy,  OSMgetPOI.POITypes.healthcare_hospital, OSMgetPOI.POITypes.education_school, OSMgetPOI.POITypes.transport_busstop, OSMgetPOI.POITypes.cuisine_restaurant; columns = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country", "amenity"])
    df2 = get_poi_df("test/data/UlanBator.osm", OSMgetPOI.POITypes.healthcare_doctor,  OSMgetPOI.POITypes.healthcare_pharmacy,  OSMgetPOI.POITypes.healthcare_hospital, OSMgetPOI.POITypes.education_school, OSMgetPOI.POITypes.transport_busstop, OSMgetPOI.POITypes.cuisine_restaurant)
    df3 = get_poi_df("test/data/UlanBator.osm", OSMgetPOI.POITypes.healthcare_doctor,  OSMgetPOI.POITypes.healthcare_pharmacy,  OSMgetPOI.POITypes.healthcare_hospital, OSMgetPOI.POITypes.education_school, OSMgetPOI.POITypes.transport_busstop; threshold = 0.0)

    #tests for the main function
    
    #no zeros in lat and lon
    @test !(0 in df1.lat)
    @test !(0 in df2.lat)
    @test !(0 in df3.lat)
    @test !(0 in df1.lon)
    @test !(0 in df2.lon)
    @test !(0 in df3.lon)

    #column names
    @test length(names(df1)) == 8
    @test "amenity" in names(df1)
    @test length(names(df2)) == 7
    @test length(names(df3)) == 97

    #correct POI types
    @test length(collect(unique(df1.poi_type))) == 6
    @test length(collect(unique(df2.poi_type))) == 6
    @test length(collect(unique(df3.poi_type))) == 5

    @test unique(df1.poi_type) == unique(df2.poi_type)
    @test string.(unique(df3.poi_type)) == string.(["healthcare_doctor", "healthcare_pharmacy", "healthcare_hospital", "education_school", "transport_busstop"])
    @test ("cuisine_restaurant" in string.(unique(df1.poi_type)))
    @test ("cuisine_restaurant" in string.(unique(df2.poi_type)))
    @test !("cuisine_restaurant" in string.(unique(df3.poi_type)))

    #specific values in all dataframes
    @test ismissing(df1[6,6])
    @test df1[221,1] == "healthcare_doctor"
    @test df1[2021,2] == 47.9253187
    @test df1[1223,3] == 106.9376796
    @test df1[1201,4] == "school"

    @test ismissing(df2[6,6])
    @test df2[221,1] == "healthcare_doctor"
    @test df2[2021,2] == 47.9253187
    @test df2[1223,3] == 106.9376796
    @test ismissing(df2[1201,4])
    
    @test !ismissing(df3[6,6])
    @test df3[221,1] == "healthcare_doctor"
    @test df3[1360,2] == 47.9090121
    @test df3[1223,3] == 106.9376796
    @test ismissing(df3[1201,95])
    
    #dimensions of all dataframes
    @test size(df1) == (2084, 8)
    @test size(df2) == (2084,7)
    @test size(df3) == (1371, 97)

end
