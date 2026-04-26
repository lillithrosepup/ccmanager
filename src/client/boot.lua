local monitor = peripheral.find("monitor")
if monitor then
  monitor.clear()
end
print("BL: Stage 1")

if shell then
  shell.setAlias("boot", "/startup/boot.lua")

  local completion = require("cc.shell.completion")

  local complete = completion.build({completion.choice, {"update"}})

  shell.setCompletionFunction(shell.getRunningProgram(), complete)
end

os.loadAPI("/ccmgr/lib/ccmgr.lua")
os.loadAPI("/ccmgr/lib/config.lua")
os.loadAPI("/ccmgr/lib/state.lua")
os.loadAPI("/ccmgr/lib/utils.lua")
os.loadAPI("/ccmgr/lib/net.lua")
ccmgr.program = require("/ccmgr/lib/program")
ccmgr.completion = require("/ccmgr/lib/completion")

local tArgs = {...}

if fs.exists("/run") then
  fs.delete("/run")
end
fs.makeDir("/run")

ccmgr.config.define(
  "boot.migrationLevel",
  {
    description = "If this does not match server, it will autoupdate the bootloader.",
    type = "string"
  }
)

local migLevel = ccmgr.net.get("/api/migration")
if tArgs[1] == "update" or migLevel ~= ccmgr.config.get("boot.migrationLevel") then
  print("Updating bootloader...")
  ccmgr.net.downloadFile("/client/update.lua", "/run/update.lua")
  os.run({}, "/run/update.lua")

  return os.reboot()
end

local success

ccmgr.config.define(
  "boot.customBootUrl",
  {
    description = "The url to download the boot file from",
    type = "string"
  }
)

if ccmgr.config.get("boot.customBootUrl") then
  success = ccmgr.net.downloadFile(ccmgr.config.get("boot.customBootUrl"), "/run/main.lua")
else
  success = ccmgr.net.downloadFile("/client/main.lua", "/run/main.lua")
end

if not success then
  sleep(5)

  os.reboot()
end

print("BL: Stage 2")

local success = pcall(shell.run, "/run/main.lua")
if not success then
  sleep(5)

  os.reboot()
end
