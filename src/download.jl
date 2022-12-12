using TranscodingStreams
using CodecZlib 
using LightXML 
using CodecBzip2
using Downloads


"""
    download_bbbike_file(url::String; target_filepath::String = "datasets/file")

Main function - it downloads a .gz file from bbbike and unzips it. Returns a name for the unzipped file.
Arguments:
- `url` - url link to the .gz file on bbbike website
- `target_filepath` - the target path for the downloaded and unzipped file. If default, the file will be called file.osm and save in datasets directory.
"""
function download_bbbike_file(url::String; target_filepath::String = "datasets/file")
    
    #download file
    print("Downloading file... \n")
    filepath = target_filepath * ".osm.gz"
    Downloads.download(url, filepath)
    
    #unzip file
    print("File downloaded. Unzipping file...\n")
    target_filepath = target_filepath * ".osm"
    open(filepath, "r") do f
        s = TranscodingStream(GzipDecompressor(), f)
        open(target_filepath, "w") do out
            write(out, s)
        end
    end

    #delete zipped file
    rm(filepath)
    print("File saved at ", target_filepath)
    return target_filepath
end 


"""
    download_geofabrik_file(url::String; target_filepath::String = "datasets/file")

Main function - it downloads a .bz2 file from geofabrik and unzips it. Returns a name for the unzipped file.
Arguments:
- `url` - url link to the .bz2 file on geofabrik website
- `target_filepath` - the target path for the downloaded and unzipped file. If default, the file will be called file.osm and save in datasets directory.
"""
function download_geofabrik_file(url::String; target_filepath::String = "datasets/file")

    #download file
    print("Downloading file... \n")
    filepath = target_filepath * ".osm.bz2"
    Downloads.download(url, filepath)
    
    #unzip file
    print("File downloaded. Unzipping file...\n")
    target_filepath = target_filepath * ".osm"
    open(filepath, "r") do f
        s = TranscodingStream(Bzip2Decompressor(), f)
        open(target_filepath, "w") do out
            write(out, s)
        end
    end

    #delete zipped file
    rm(filepath)
    print("File saved at ", target_filepath)
    return target_filepath
end 