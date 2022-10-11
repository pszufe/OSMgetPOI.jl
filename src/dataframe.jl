using DataFrames

#################################################################################
#Creating dataframe from one vector of processed POIs (only one type)############
#################################################################################

"""
    columns(processed_objects::Vector{ProcessedPOI})::Vector{String}

Auxilary function - it returns a vector of all distinct osm tag keys which are used as colnames of the df.
Arguments:
- `processed_objects` - vector of processed POIs of one type (output of `create_poi_dataset` function)
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
    column_list = append!(["primary_type", "subtype", "lat", "lon"], column_list)
    return column_list
end


"""
    create_df(processed_objects::Vector{ProcessedPOI}, df_columns::Vector{String} = String[])::DataFrame

Auxilary function - it returns the dataframe with processed POIs of one `primary_type` and one `subtype`
Arguments:
- `processed_objects` - vector of processed pois of one type (output of `create_poi_dataset`)
- `df_columns` - vector of column names for the dataframe (output of `columns` function) 
"""
function create_df(processed_objects::Vector{ProcessedPOI}, df_columns::Vector{String} = String[])::DataFrame
    if length(df_columns) == 0
        column_list = columns(processed_objects)
    else
        column_list = df_columns
    end
    matrix = Vector{Any}(missing, length(column_list))
    for element in processed_objects
        vector = Vector{Any}(missing, length(column_list))
        vector[1] = element.primary_type
        vector[2] = element.subtype
        vector[3] = element.lat
        vector[4] = element.lon
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


###########################################################################################
#Creating a dataframe from all vectors of POIs (output of generate_poi_vectors function)###
###########################################################################################

"""
    columns_in_poi_vector(processed_objects_vector::Vector{Vector{ProcessedPOI}})::Vector{String}

Auxilary function - it returns a vector of all distinct osm tag keys which are used as column names of the df.
Arguments:
- `processed_objects_vector` - vector of processed pois of all types (output of generate_poi_vectors)
"""
function columns_in_poi_vector(processed_objects_vector::Vector{Vector{ProcessedPOI}})::Vector{String}
    all_columns = String[]
    for element in processed_objects_vector
        columns_of_df = columns(element)
        if length(all_columns) == 0
            append!(all_columns, columns_of_df)
        else
            for column in columns_of_df
                if column ∉ all_columns
                    push!(all_columns, column)
                end
            end
        end
    end
    return all_columns
end


"""
    create_poi_df(processed_objects_vector::Vector{Vector{ProcessedPOI}})::DataFrame

Main function - it returns the dataframe of all POIs of all configured `primary_types` and `subtypes`
Arguments:
- `processed_objects_vector` - the vector of processed pois of all types (output of `generate_poi_vectors`)
"""
function create_poi_df(processed_objects_vector::Vector{Vector{ProcessedPOI}})::DataFrame
    res_df = DataFrame()
    all_columns = columns_in_poi_vector(processed_objects_vector)
    for element in processed_objects_vector
        df = create_df(element, all_columns)
        append!(res_df, df)
    end
    return res_df
end


#######################################################################################################
#Filtering dataframe columns to only include columns that have low number of missing values############
#######################################################################################################

"""
    filter_columns(dframe::DataFrame, threshold::Float64 = 0.5)::DataFrame

Main function - it filters columns of the poi dataframe and returns a dataframe with those columns,
whose fraction of non-missing values exceeds the threshold value
Arguments:
- `dframe` - a DataFrame with POIs
- `threshold` - a minimum fraction of non-missing values in a column 
"""
function filter_columns(dframe::DataFrame, threshold::Float64 = 0.5)
    df = dframe
    for n in names(df)
        count_of_non_missing = length(collect(dropmissing(df, n)[!, n]))
        if count_of_non_missing < threshold*nrow(df)
            df = select(df, Not(n))
        end
    end
    return df
end
