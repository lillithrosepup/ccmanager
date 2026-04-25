print("Downloading core files...")

-- if fs.exists("/lvn/core") then
--   fs.delete("/lvn/core")
-- end

print("Downloading core files...")
print("Downloading boot.lua...")
lvn.net.downloadFile("/lua/boot.lua", "/startup/boot.lua")

print("Downloading config.lua...")
lvn.net.downloadFile("/lua/core/config.lua", "/lil/core/config.lua")

print("Downloading net.lua...")
lvn.net.downloadFile("/lua/core/net.lua", "/lil/core/net.lua")

print("Downloading urls.lua...")
lvn.net.downloadFile("/lua/core/urls.lua", "/lil/core/urls.lua")

print("Downloading utils.lua...")
lvn.net.downloadFile("/lua/core/utils.lua", "/lil/core/utils.lua")

print("Downloading chat.lua...")
lvn.net.downloadFile("/lua/core/chat.lua", "/lil/core/chat.lua")

print("Downloading program.lua...")
lvn.net.downloadFile("/lua/core/program.lua", "/lil/core/program.lua")

print("Downloading completion.lua...")
lvn.net.downloadFile("/lua/core/completion.lua", "/lil/core/completion.lua")

print("Downloading lil.lua...")
lvn.net.downloadFile("/lua/core/lil.lua", "/lil/core/lil.lua")

local configStr = lvn.net.get("/api/config")
local config = textutils.unserializeJSON(configStr)
print("New migration level: " .. config.migrationLevel)
lvn.config.set("boot.migrationLevel", config.migrationLevel)
