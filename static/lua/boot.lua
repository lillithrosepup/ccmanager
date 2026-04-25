local monitor = peripheral.find("monitor")
if monitor then
  monitor.clear()
end

if shell then
  shell.setAlias("boot", "/startup/boot.lua")

  local completion = require("cc.shell.completion")

  local complete = completion.build({completion.choice, {"update", "boot"}}, {completion.choice, {"node", "admin"}})

  shell.setCompletionFunction(shell.getRunningProgram(), complete)
end

os.loadAPI("/lvn/core/lvn.lua")
os.loadAPI("/lvn/core/config.lua")
os.loadAPI("/lvn/core/net.lua")
os.loadAPI("/lvn/core/urls.lua")
os.loadAPI("/lvn/core/utils.lua")
os.loadAPI("/lvn/core/chat.lua")

lvn.config.define(
  "debug",
  {
    description = "Log websocket and http messages",
    type = boolean,
    default = false
  }
)

lvn.config.define(
  "boot.type",
  {
    description = "The type of boot to run",
    type = "string"
  }
)

lvn.config.define(
  "boot.customBootUrl",
  {
    description = "The url to download the boot file from",
    type = "string"
  }
)

local tArgs = {...}

if fs.exists("/run") then
  fs.delete("/run")
end
fs.makeDir("/run")

lvn.config.define(
  "boot.migrationLevel",
  {
    description = "if this does not match server, it will autoupdate the bootloader.",
    type = "number"
  }
)

local configStr = lvn.net.get("/api/config")
local config = textutils.unserializeJSON(configStr)
if tArgs[1] == "update" or config.migrationLevel ~= lvn.config.get("boot.migrationLevel") then
  print("Updating bootloader...")
  lvn.net.downloadFile("/lua/update.lua", "/run/update.lua")
  os.run({}, "/run/update.lua")

  return os.reboot()
end

if tArgs[1] == "boot" and tArgs[2] then
  print("Booting into " .. tArgs[2] .. " mode")
  lvn.config.set("boot.type", tArgs[2])
else
  print("booting...")
end

if fs.exists("/run") then
  fs.delete("/run")
end
fs.makeDir("/run")

local success

if lvn.config.get("boot.customBootUrl") then
  success = lvn.net.downloadFile(lvn.config.get("boot.customBootUrl"), "/run/boot.lua")
else
  success = lvn.net.downloadFile("/lua/" .. lvn.config.get("boot.type") .. "/boot.lua", "/run/boot.lua")
end

if not success then
  lvn.chat.send("Failed to download boot.lua")

  sleep(5)

  os.reboot()
end

print("Running boot.lua")

local success = pcall(shell.run, "/run/boot.lua")
if not success then
  lvn.chat.send("Failed to run boot.lua")

  sleep(5)

  os.reboot()
end
