print("Downloading core files...")

if fs.exists("/lvn/core") then
  fs.delete("/lvn/core")
end

print("Downloading core files...")
print("Downloading boot.lua...")
lvn.net.downloadFile("/lua/boot.lua", "/startup/boot.lua")

print("Downloading config.lua...")
lvn.net.downloadFile("/lua/core/config.lua", "/lvn/core/config.lua")

print("Downloading net.lua...")
lvn.net.downloadFile("/lua/core/net.lua", "/lvn/core/net.lua")

print("Downloading urls.lua...")
lvn.net.downloadFile("/lua/core/urls.lua", "/lvn/core/urls.lua")

print("Downloading utils.lua...")
lvn.net.downloadFile("/lua/core/utils.lua", "/lvn/core/utils.lua")

print("Downloading chat.lua...")
lvn.net.downloadFile("/lua/core/chat.lua", "/lvn/core/chat.lua")

print("Downloading program.lua...")
lvn.net.downloadFile("/lua/core/program.lua", "/lvn/core/program.lua")

print("Downloading completion.lua...")
lvn.net.downloadFile("/lua/core/completion.lua", "/lvn/core/completion.lua")

print("Downloading lvn.lua...")
lvn.net.downloadFile("/lua/core/lvn.lua", "/lvn/core/lvn.lua")

local configStr = lvn.net.get("/api/config")
local config = textutils.unserializeJSON(configStr)
print("New migration level: " .. config.migrationLevel)
lvn.config.set("boot.migrationLevel", config.migrationLevel)
