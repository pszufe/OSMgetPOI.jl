### Documentation
To run Documenter.jl documentation locally, please open the POIs directory and run the following shell commands:
```
cd docs
julia make.jl
julia -e 'using LiveServer; serve(dir="build")'
```

### Basic description of the repository
The project consists of 3 main parts:
- `/datasets` directory:
    - you can download and save there .osm files from https://download.bbbike.org/osm/bbbike/ for further processing
    - there is a file `POI_config.json` which you can edit to generate the types of POIs that you're interested in
- `/src` directory where the source code is located. The source code contains the following key functions:
    - `generate_poi_vectors` - it parses the .osm file from function argument and creates a vector of processed POI objects for each POI category (type and subtype) specified in `POI_config.json`. The functions returns a vector of datasets - each dataset representing POIs of different category.
    - `create_poi_df` - it takes an output of `generate_poi_vectors` as an argument and returns a Julia DataFrame with all the processed POIs. The dataframe may be used for further analysis or easily exported into CSV file.
    - `filter_columns_by_colnames` and `filter_columns_by_threshold` - it filters the columns of a dataframe and returns a dataframe with those columns, whose fraction of non-missing values exceeds a certain threshold (50% by default).
 - `tutorial.ipynb` - a jupyter notebook which executes these function and saves CSV files with POIs in `/output.csv` directory.


### Generating .csv with POIs for Beijing and for Warsaw
1. Download .osm files for Warsaw and Beijing from https://download.bbbike.org/osm/bbbike/ and save into `/datasets`.
2. Open jupyter notebook `tutorial.ipynb` and run all of the cells.
3. The .csv with POIs will be generated in `/output_csv` directory.


### Generating POIs for cities other than Beijing and Warsaw
1. Download .osm file for a selected city from https://download.bbbike.org/osm/bbbike/ and save in `/datasets` directory.
2. Go to `tutorial.ipynb` and run function `generate_poi_vectors("city_name.osm")` where city_name.osm is the name of your .osm file.
3. Run the rest of cells from Jupyter Notebook (change variable names). The POIs will be generated in `/output_csv` directory.

### Adding new types and subtypes of POIs for a selected city (e.g. Beijing)
1. Update the file `POI_config.json` with new POI types. 
4. Run jupyter notebook `tutorial.ipynb.`


## Remarks
This research was funded in whole or in part by [National Science Centre,  Poland][2021/41/B/HS4/03349]. For the software’s  documentation for the purpose of Open Access, the author has applied a CC-BY public copyright licence to any Author Accepted Manuscript (AAM) version arising from this submission.
