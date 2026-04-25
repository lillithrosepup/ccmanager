local function downloadFile(url, path)
    local fileContents = ccmgr.net.get(url, true, true)
    if fileContents == false then
        return false
    end
    local file = fs.open(path, "w")
    file.write(fileContents)
    file.close()
    return true
end

local function get(url, nocreds, nolog)
    local url = url
    if url:find("^/") then
        url =
            "http" ..
            (ccmgr.config.get("boot.ssl") and "s" or "") ..
                "://" .. ccmgr.config.get("boot.host") .. ":" .. ccmgr.config.get("boot.port") .. url
    end
    if ccmgr.config.get("debug") and not nolog then
        print("GET: " .. url)
    end
    local file, e =
        http.get(
        url,
        not nocreds and
            {
                ["Authorization"] = ccmgr.config.get("password")
            } or
            {}
    )
    if not file then
        if nolog then
            print("GET: " .. url)
        end
        printError("GET failed: ", e)
        return false
    end
    local fileContents = file.readAll()
    file.close()
    if ccmgr.config.get("debug") and not nolog then
        print("GET success: ", fileContents, url)
    end
    return fileContents
end

local function post(url, data)
    local url = url
    if url:find("^/") then
        url =
            "http" ..
            (ccmgr.config.get("boot.ssl") and "s" or "") ..
                "://" .. ccmgr.config.get("boot.host") .. ":" .. ccmgr.config.get("boot.port") .. url
    end
    if ccmgr.config.get("debug") then
        print("POST: " .. url)
    end
    local file, e =
        http.post(
        url,
        data,
        {
            ["Authorization"] = ccmgr.config.get("password")
        }
    )
    if not file then
        printError("POST failed: ", e)
        return false
    end
    local fileContents = file.readAll()
    file.close()
    if ccmgr.config.get("debug") then
        print("POST success: ", fileContents, url)
    end
    return fileContents
end

ccmgr.net = {
    downloadFile = downloadFile,
    get = get,
    post = post
}
