print("Downloading core files...")

if fs.exists("/ccmgr/core") then
  fs.delete("/ccmgr/core")
end

print("Downloading core files...")
print("Downloading boot.lua...")
ccmgr.net.downloadFile("/client/boot.lua", "/startup/boot.lua")

print("Downloading config.lua...")
ccmgr.net.downloadFile("/client/core/config.lua", "/ccmgr/core/config.lua")

print("Downloading net.lua...")
ccmgr.net.downloadFile("/client/core/net.lua", "/ccmgr/core/net.lua")

print("Downloading urls.lua...")
ccmgr.net.downloadFile("/client/core/urls.lua", "/ccmgr/core/urls.lua")

print("Downloading utils.lua...")
ccmgr.net.downloadFile("/client/core/utils.lua", "/ccmgr/core/utils.lua")

print("Downloading program.lua...")
ccmgr.net.downloadFile("/client/core/program.lua", "/ccmgr/core/program.lua")

print("Downloading completion.lua...")
ccmgr.net.downloadFile("/client/core/completion.lua", "/ccmgr/core/completion.lua")

print("Downloading ccmgr.lua...")
ccmgr.net.downloadFile("/client/core/ccmgr.lua", "/ccmgr/core/ccmgr.lua")

local migLevel = ccmgr.net.get("/api/migration")
print("New migration level: " .. migLevel)
ccmgr.config.set("boot.migrationLevel", migLevel)
