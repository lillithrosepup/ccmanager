print("Downloading core files...")

if fs.exists("/ccmgr/core") then
  fs.delete("/ccmgr/core")
end

print("Downloading core files...")
print("Downloading boot.lua...")
ccmgr.net.downloadFile("/client/boot.lua", "/startup/boot.lua")

print("Downloading config.lua...")
ccmgr.net.downloadFile("/client/lib/config.lua", "/ccmgr/lib/config.lua")

print("Downloading net.lua...")
ccmgr.net.downloadFile("/client/lib/net.lua", "/ccmgr/lib/net.lua")

print("Downloading utils.lua...")
ccmgr.net.downloadFile("/client/lib/utils.lua", "/ccmgr/lib/utils.lua")

print("Downloading program.lua...")
ccmgr.net.downloadFile("/client/lib/program.lua", "/ccmgr/lib/program.lua")

print("Downloading completion.lua...")
ccmgr.net.downloadFile("/client/lib/completion.lua", "/ccmgr/lib/completion.lua")

print("Downloading ccmgr.lua...")
ccmgr.net.downloadFile("/client/lib/ccmgr.lua", "/ccmgr/lib/ccmgr.lua")

local migLevel = ccmgr.net.get("/api/migration")
print("New migration level: " .. migLevel)
ccmgr.config.set("boot.migrationLevel", migLevel)
