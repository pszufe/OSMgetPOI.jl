include("poi_datasets_vector.jl")
using DataFrames


#################################################################################
#Creating dataframe from one vector of processed POIs (only one type)############
#################################################################################


"""
    columns(processed_objects::Vector{Dict{String, Any}})::Vector{String}

Auxilary function - it takes the vector of processed pois of one type (output of create_poi_dataset)
and searches all distinct osm tag keys. The function returns a vector of all distinct osm tag keys which
are used as colnames of the df.
"""

function columns(processed_objects::Vector{Dict{String, Any}})::Vector{String}
    column_list = String[]
    for element in processed_objects
        tags = get(element, "tags", 0)
        for (key, value) in tags
            if !(key in column_list)
                push!(column_list, key)
            end
        end
    end
    column_list = append!(["primary_type", "subtype", "lat", "lon"], column_list)
    return column_list
end


"""
    create_df(processed_objects::Vector{Dict{String, Any}}, df_columns::Vector{String} = String[])::DataFrame

Auxilary function - it takes the vector of processed pois of one type (output of create_poi_dataset)
and returns the dataframe with POIs.
"""

function create_df(processed_objects::Vector{Dict{String, Any}}, df_columns::Vector{String} = String[])::DataFrame
    if length(df_columns) == 0
        column_list = columns(processed_objects)
    else
        column_list = df_columns
    end
    matrix = Vector{Any}(missing, length(column_list))
    for element in processed_objects
        vector = Vector{Any}(missing, length(column_list))
        vector[1] = get(element, "primary_type", missing)
        vector[2] = get(element, "subtype", missing)
        vector[3] = get(element, "lat", missing)
        vector[4] = get(element, "lon", missing)
        tags = get(element, "tags", missing)
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
columns_in_poi_vector(processed_objects_vector::Vector{Vector{Dict{String, Any}}})::Vector{String}

Auxilary function - it takes the vector of processed pois of all types (output of generate_poi_vectors)
and searches all distinct osm tag keys. The function returns a vector of all distinct osm tag keys which
are used as colnames of the df.
"""

function columns_in_poi_vector(processed_objects_vector::Vector{Vector{Dict{String, Any}}})::Vector{String}
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
    create_poi_df(processed_objects_vector::Vector{Vector{Dict{String, Any}}})::DataFrame

Main function - it takes the vector of processed pois of all types (output of generate_poi_vectors)
and returns the dataframe of all POIs.
"""

function create_poi_df(processed_objects_vector::Vector{Vector{Dict{String, Any}}})::DataFrame
    res_df = DataFrame()
    for element in processed_objects_vector
        all_columns = columns_in_poi_vector(processed_objects_vector)
        df = create_df(element, all_columns)
        append!(res_df, df)
    end
    return res_df
end


############################################################################################
#Mutation of a dataframe to only include columns that have little missing values############
############################################################################################

"""
    filter_columns(dframe::DataFrame, threshold::Float64 = 0.5)::DataFrame

Main function - it takes the final poi dataframe and a threshold value as an argument.
The function filters columns of the poi dataframe and returns a dataframe with those columns,
whose fraction of non-missing values exceeds the threshold value.
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
