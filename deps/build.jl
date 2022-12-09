using HTTP

if Sys.iswindows()
    download("http://m.m.i24.cc/osmfilter.exe", "deps/osmfilter.exe")
    run(`chmod +x deps/osmfilter.exe`)
    run(`deps/osmfilter.exe`)
end

if Sys.islinux()
    download("http://m.m.i24.cc/osmfilter32", "deps/osmfilter32")
    run(`chmod +x deps/osmfilter32`)
    run(`deps/osmfilter32`)
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
            print("Please install brew on your mac to build this Julia package")
        end
    end
end