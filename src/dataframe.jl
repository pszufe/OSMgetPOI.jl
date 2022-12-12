using DataFrames

#################################################################################
#Creating dataframe from one vector of processed POIs (only one poi_type)############
#################################################################################

"""
    columns(processed_objects::Vector{ProcessedPOI})::Vector{String}

Auxilary function - it returns a vector of all distinct osm tag keys which are used as colnames of the dataframe.
Arguments:
- `processed_objects` - vector of processed POIs of one poi_type (output of `create_poi_dataset` function)
"""
function columns(processed_objects::Vector{ProcessedPOI})::Vector{String}
    column_list = String[]
    for element in processed_objects
        for (key, value) in element.tags
            if !(key in column_list)
                push!(column_list, key)
            end
        end
    end
    column_list = append!(["poi_type", "lat", "lon"], column_list)
    return column_list
end


"""
    create_df(processed_objects::Vector{ProcessedPOI}, df_columns::Vector{String} = String[])::DataFrame

Auxilary function - it returns the dataframe with processed POIs of one POIType
Arguments:
- `processed_objects` - vector of processed pois of one poi_type 
- `df_columns` - vector of column names for the dataframe (output of `columns` function) 
"""
function create_df(processed_objects::Vector{ProcessedPOI}, df_columns::Vector{String} = String[])::DataFrame
    if length(df_columns) == 0
        column_list = columns(processed_objects)
    else
        column_list = df_columns
    end
    matrix = Vector{Union{String, Int, Float64, Missing}}(missing, length(column_list))
    for element in processed_objects
        vector = Vector{Union{String, Int, Float64, Missing}}(missing, length(column_list))
        vector[1] = element.poi_type
        vector[2] = element.lat
        vector[3] = element.lon
        tags = element.tags
        for (key, value) in tags
            if key in column_list
                index = findall(x -> x == key, column_list)[1]
            end
            vector[index] = value
        end
        matrix = hcat(matrix, vector)
    end
    matrix = permutedims(matrix)[Not(1), :]
    df = DataFrame(matrix, column_list, makeunique = true)
    return df
end


#######################################################################################################
#Filtering dataframe columns to only include columns that have low number of missing values############
#######################################################################################################

"""
    filter_columns(dframe::DataFrame, threshold::Float64 = 1.0, columns::Vector{String} = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country"])

Main function - it filters columns of the poi dataframe and returns a dataframe with those columns,
whose fraction of non-missing values exceeds the threshold value
Arguments:
- `dframe` - a DataFrame with POIs
- `threshold` - a minimum fraction of non-missing values in a column 
- `columns` - vector of columns that are to be included in the returned dataframe, regardless of the threshold value
"""
function filter_columns(dframe::DataFrame, threshold::Float64 = 1.0, columns::Vector{String} = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country"])
    df = dframe
    for n in names(df)
        count_of_non_missing = length(collect(dropmissing(df, n)[!, n]))
        if count_of_non_missing < threshold * size(df,1) && !(n in columns)
            df = select(df, Not(n))
        end
    end
    return df
end


###########################################################################################
#Creating a dataframe from all vectors of POIs (output of generate_poi_vectors function)###
###########################################################################################

"""
    columns_in_poi_vector(processed_objects_vector::Vector{Vector{ProcessedPOI}})::Vector{String}

Auxilary function - it returns a vector of all distinct osm tag keys which are used as column names of the df.
Arguments:
- `processed_objects_vector` - vector of processed pois of all poi_types (output of generate_poi_vectors)
"""
function columns_in_poi_vector(processed_objects_vector::Vector{Vector{ProcessedPOI}})::Vector{String}
    vector_of_columns = map(columns, processed_objects_vector)
    all_columns = unique(vcat(vector_of_columns...))
    return all_columns
end


"""
    create_poi_df(processed_objects_vector::Vector{Vector{ProcessedPOI}}, threshold::Float64 = 1.0, columns::Vector{String} = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country"])::DataFrame

Auxilary function - it returns the dataframe of all POIs of all configured POITypes
Arguments:
- `processed_objects_vector` - the vector of processed pois of all POITypes
- `threshold` - a minimum fraction of non-missing values in a column
- `columns` - vector of columns that are to be included in the returned dataframe, regardless of the threshold value
"""
function create_poi_df(processed_objects_vector::Vector{Vector{ProcessedPOI}}, threshold::Float64 = 1.0, columns::Vector{String} = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country"])::DataFrame
    all_columns = columns_in_poi_vector(processed_objects_vector)
    dataframes = map(processed_objects -> create_df(processed_objects, all_columns), processed_objects_vector)
    res_df = vcat(dataframes...)
    filtered_df = filter_columns(res_df, threshold, columns)
    return filtered_df
end


#####################################################################
#Creating a dataframe from directly from the .osm file###############
#####################################################################

"""
    get_poi_df(osm_filename::String, poi_types::POITypes.POIType ...; columns::Vector{String} = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country"], threshold::Float64 = 1.0)

Main function - it returns the dataframe of all POIs of all configured POITypes from the .osm file.

Arguments:
- `osm_filename` - path to .osm file from which the POIs are processed and generated
- `threshold` - a minimum fraction of non-missing values in a column 
- `poi_types` - all POITypes, for which the dataframe should be generated
- `columns` - vector of columns that are to be included in the returned dataframe, regardless of the threshold value
"""
function get_poi_df(osm_filename::String, poi_types::POITypes.POIType ...; columns::Vector{String} = ["addr:housenumber", "addr:street", "addr:postcode", "addr:country"], threshold::Float64 = 1.0)::DataFrame
    processed_poi_vectors = generate_poi_vectors(osm_filename, poi_types...)
    poi_df = create_poi_df(processed_poi_vectors, threshold, columns)
    return poi_df
end