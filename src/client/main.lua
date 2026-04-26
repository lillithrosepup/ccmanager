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
program.download("/programs/keyfwd.lua", "/ccmgr/programs/keyfwd.lua", "keyfwd", true)
program.download("/programs/airship.lua", "/ccmgr/programs/airship.lua", "airship", true)

ccmgr.config.define(
  "feat.airship",
  {
    description = "Wether the node is an airship",
    type = "boolean",
    default = false
  }
)
if ccmgr.config.get("feat.airship") then
  program.download("/features/airship.lua", "/run/airship.lua", false, false)
  program.run("/run/airship.lua", "Airship", true, false)
end
