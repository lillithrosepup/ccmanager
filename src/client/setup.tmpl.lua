function setConfig(name, val)
  settings.set("ccmgr." .. name, val)
end

settings.set("motd.enable", false)
settings.save()

io.write("What would you like this to be named? ")
local name = io.read("*l")

os.setComputerLabel(name)

setConfig("boot.ssl", "{isSSL}")
setConfig("boot.host", "{connectHost}")
setConfig("boot.port", "{connectPort}")

settings.save()

if not fs.isDir("/ccmgr") then
  fs.makeDir("/ccmgr")
end

if not fs.isDir("/ccmgr/lib") then
  fs.makeDir("/ccmgr/lib")
end

local luaBase = "http" .. ({isSSL} and "s" or "") .. "://{connectHost}:{connectPort}/client"

function downloadFile(url, path)
  local file = http.get(luaBase .. url)
  if not file then
    print("Failed to download " .. url)
    return false
  end
  local fileContents = file.readAll()
  file.close()
  local file = fs.open(path, "w")
  file.write(fileContents)
  file.close()
  return true
end

downloadFile("/boot.lua", "/startup/boot.lua")

downloadFile("/lib/config.lua", "/ccmgr/lib/config.lua")

downloadFile("/lib/net.lua", "/ccmgr/lib/net.lua")

downloadFile("/lib/utils.lua", "/ccmgr/lib/utils.lua")

downloadFile("/lib/program.lua", "/ccmgr/lib/program.lua")

downloadFile("/lib/completion.lua", "/ccmgr/lib/completion.lua")

downloadFile("/lib/state.lua", "/ccmgr/lib/state.lua")

downloadFile("/lib/ccmgr.lua", "/ccmgr/lib/ccmgr.lua")

print("Setup complete")

os.reboot()
