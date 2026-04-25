local program = require("/ccmgr/lib/program")

if fs.exists("/ccmgr/programs") then
  fs.delete("/ccmgr/programs")
end
fs.makeDir("/ccmgr")
fs.makeDir("/ccmgr/programs")

if fs.exists("/run") then
  fs.delete("/run")
end
fs.makeDir("/run")

program.download("/ws.lua", "/run/ws.lua", false, false)
os.loadAPI("/run/ws.lua")

program.download("/wsPackets.lua", "/run/wsPackets.lua", false, false)
require("/run/wsPackets")

program.run("/run/ws.lua", "Websocket Runner", false, "loop")

program.download("/programs/reboot.lua", "/ccmgr/programs/reboot.lua", "reboot", true)
