## Documentation
To run Documenter.jl documentation locally, please open the OSMgetPOI directory and run the following shell commands:
```
cd docs
julia make.jl
julia -e 'using LiveServer; serve(dir="build")'
```
To use the package you will need to install OSM Filter: https://wiki.openstreetmap.org/wiki/Osmfilter

## Basic description of the repository
The project consists of 2 main parts:
- `/src` directory where the source code is located. The source code contains the following key functions:
    - `download_bbbike_file` and `download_geofabrik_file` - to download and unzip .osm files
    - `get_poi_df` - it parses the .osm file from function argument and returns a Julia DataFrame with all the processed POIs. The dataframe may be used for further analysis or easily exported into CSV file.
    - other main functions - described in the documentation
 - `demo.ipynb` - jupyter notebooks which show how the package works.

#### Proposed POI types and osmfilter queries:

The package supports the POI Types shown the table below. To add your own POITypes, go to `src/POITypes`.

| primary_type 	| subtype 	| query 	|
|---	|---	|---	|
| education 	| kindergarden 	| "--keep= \" amenity=kindergarten \"" 	|
| education 	| school 	| "--keep= \" amenity=school =music_school =language_school \"" 	|
| education 	| university 	| "--keep= \" amenity=university =college \"" 	|
| education 	| library 	| "--keep= \" amenity=library \"" 	|
| cuisine 	| restaurant 	| "--keep= \" amenity=restaurant =fast_food =food_court \"" 	|
| cuisine 	| pub 	| "--keep= \" amenity=pub =bar \"" 	|
| cuisine 	| cafe 	| "--keep= \" amenity=cafe =ice_cream \"" 	|
| finance 	| finance 	| "--keep= \" amenity=bank =atm \"" 	|
| transport 	| parking 	| "--keep= \" amenity=parking parking=* \"" 	|
| transport 	| gas_station 	| "--keep= \" amenity=fuel \"" 	|
| transport 	| bus_stop 	| "--keep= \" amenity=bus_station public_transport=station \"" 	|
| transport 	| railway_station 	| "--keep= \" railway=station \"" 	|
| transport 	| airport 	| "--keep= \" aeroway=aerodrome =terminal \"" 	|
| healthcare 	| doctor 	| "--keep= \" amenity=clinic =doctors =dentist healthcare=* \"" 	|
| healthcare 	| pharmacy 	| "--keep= \" amenity=pharmacy \"" 	|
| healthcare 	| hospital 	| "--keep= \" amenity=hospital \"" 	|
| entertainment 	| culture 	| "--keep= \" amenity=cinema =theatre =arts_centre \"" 	|
| entertainment 	| club 	| "--keep= \" amenity=nightclub \"" 	|
| shopping 	| shop 	| "--keep= \" shop=* \"" 	|
| shopping 	| marketplace 	| "--keep= \" amenity=marketplace \"" 	|
| leisure 	| park 	| "--keep= \" leisure=garden =park =dog_park \"" 	|
| leisure 	| sports_ground 	| "--keep= \" leisure=sports_centre =sports_hall =stadium =track =pitch =horse_riding =swimming_pool =fitness_centre =fitness_station sport=fitness landuse=recreation_ground =winter_sports \"" 	|
| leisure 	| tourism 	| "--keep= \" tourism=* \"" 	|
| religion 	| religion 	| "--keep= \" amenity=place_of_worship \"" 	|
| work 	| work 	| "--keep= \" office=* industrial=* landuse=industrial \"" 	|

## Remarks
This research was funded in whole or in part by [National Science Centre,  Poland][2021/41/B/HS4/03349]. For the software’s  documentation for the purpose of Open Access, the author has applied a CC-BY public copyright licence to any Author Accepted Manuscript (AAM) version arising from this submission.
