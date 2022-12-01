using Downloads
using TranscodingStreams
using CodecZlib 
using LightXML 
using CodecBzip2

function download_bbbike_file(url::String; directory = "datasets", filename::String = "file")
    
    #download file
    print("Downloading file... \n")
    filepath = directory * "/" * filename * ".osm.gz"
    Downloads.download(url, filepath)
    
    #unzip file
    print("File downloaded. Unzipping file...\n")
    target_filepath = directory * "/" * filename * ".osm"
    open(filepath, "r") do f
        s = TranscodingStream(GzipDecompressor(), f)
        open(target_filepath, "w") do out
            write(out, s)
        end
    end

    #delete zipped file
    rm(filepath)
    print("File saved at ", target_filepath)
end 


function download_geofabrik_file(url::String; directory = "datasets", filename::String = "file")

    #download file
    print("Downloading file... \n")
    filepath = directory * "/" * filename * ".osm.bz2"
    Downloads.download(url, filepath)
    
    #unzip file
    print("File downloaded. Unzipping file...\n")
    target_filepath = directory * "/" * filename * ".osm"
    open(filepath, "r") do f
        s = TranscodingStream(Bzip2Decompressor(), f)
        open(target_filepath, "w") do out
            write(out, s)
        end
    end

    #delete zipped file
    rm(filepath)
    print("File saved at ", target_filepath)
end 