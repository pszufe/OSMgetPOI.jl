module POITypes
    
    struct POIType
        query::String
        name::String
    end
    
    #education
    const education_kindergarden = POIType("--keep= \" amenity=kindergarten \"", "education_kindergarden")
    const education_school = POIType("--keep= \" amenity=school =music_school =language_school \"", "education_school")
    const education_university = POIType("--keep= \" amenity=university =college \"", "education_university")
    const education_library = POIType("--keep= \" amenity=library \"", "education_library")
    
    #cuisine
    const cuisine_restaurant = POIType("--keep= \" amenity=restaurant =fast_food =food_court \"", "cuisine_restaurant")
    const cuisine_pub = POIType("--keep= \" amenity=pub =bar \"", "cuisine_pub")
    const cuisine_cafe = POIType("--keep= \" amenity=cafe =ice_cream \"", "cuisine_cafe")
    
    #finance
    const finance_bankoratm = POIType("--keep= \" amenity=bank =atm \"", "finance_bankoratm")
    
    #transport
    const transport_parking = POIType("--keep= \" amenity=parking parking=* \"", "transport_parking")
    const transport_gasstation = POIType("--keep= \" amenity=fuel \"", "transport_gasstation")
    const transport_busstop = POIType("--keep= \" amenity=bus_station public_transport=station \"", "transport_busstop")
    const transport_railwaystation = POIType("--keep= \" railway=station \"", "transport_railwaystation")
    const transport_airport = POIType("--keep= \" aeroway=aerodrome =terminal \"", "transport_airport")
    
    #healthcare
    const healthcare_doctor = POIType("--keep= \" amenity=clinic =doctors =dentist healthcare=* \"", "healthcare_doctor")
    const healthcare_pharmacy = POIType("--keep= \" amenity=pharmacy \"", "healthcare_pharmacy")
    const healthcare_hospital = POIType("--keep= \" amenity=hospital \"", "healthcare_hospital")
    
    #entertainment_cinemaandarts
    const entertainment_cinemaandarts = POIType("--keep= \" amenity=cinema =theatre =arts_centre \"", "entertainment_cinemaandarts")
    const entertainment_club = POIType("--keep= \" amenity=nightclub \"", "entertainment_club")
    
    #shopping
    const shopping_shop = POIType("--keep= \" shop=* \"", "shopping_shop")
    const shopping_marketplace = POIType("--keep= \" amenity=marketplace \"", "shopping_marketplace")
    
    #leisure
    const leisure_park = POIType("--keep= \" leisure=garden =park =dog_park \"", "leisure_park")
    const leisure_sportsground = POIType("--keep= \" leisure=sports_centre =sports_hall =stadium =track =pitch =horse_riding =swimming_pool =fitness_centre =fitness_station sport=fitness landuse=recreation_ground =winter_sports \"", "leisure_sportsground")
    const leisure_tourism = POIType("--keep= \" tourism=* \"", "leisure_tourism")
    
    #religion
    const religion_religion = POIType("--keep= \" amenity=place_of_worship \"", "religion_religion")
    
    #work
    const work_officeandindustry = POIType("--keep= \" office=* industrial=* landuse=industrial \"", "work_officeandindustry")

end 