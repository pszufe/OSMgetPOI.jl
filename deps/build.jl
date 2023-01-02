using HTTP

target_dir = pwd()
if basename(target_dir) != "deps"
    target_dir = joinpath(target_dir, "deps")
end

if Sys.iswindows()
    download("http://m.m.i24.cc/osmfilter.exe", joinpath(target_dir,"osmfilter.exe"))
    run(`$(joinpath(target_dir,"osmfilter.exe"))`)
end

if Sys.islinux()  # download 64 bit version
    download("http://m.m.i24.cc/osmfilter64", joinpath(target_dir,"osmfilter"))
    run(`chmod +x $(joinpath(target_dir,"osmfilter"))`)
    run(`$(joinpath(target_dir,"osmfilter"))`)
end

if Sys.isapple()
    try
        run(`which brew`)
        run(`brew install osmfilter`)
    catch e
        try
            #install brew
            run(`/usr/bin/env bash -c "curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | /usr/bin/env bash"`)
            run(`brew install osmfilter`)
        catch e2
            print("Please visit https://brew.sh/, install brew on your mac and try again building this Julia package.")
        end
    end
end
