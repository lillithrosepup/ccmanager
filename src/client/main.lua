if fs.exists("/ccmgr/programs") then
  fs.delete("/ccmgr/programs")
end
fs.makeDir("/ccmgr")
fs.makeDir("/ccmgr/programs")

if fs.exists("/run") then
  fs.delete("/run")
end
fs.makeDir("/run")

ccmgr.program.download("/ws.lua", "/run/ws.lua", nil, false)
os.loadAPI("/run/ws.lua")

ccmgr.program.download("/wsPackets.lua", "/run/wsPackets.lua", nil, false)
require("/run/wsPackets")

ccmgr.program.run("/run/ws.lua", "Websocket Runner", false, "loop")

ccmgr.program.download("/programs/reboot.lua", "/ccmgr/programs/reboot.lua", "reboot", true)
ccmgr.program.download("/programs/keyfwd.lua", "/ccmgr/programs/keyfwd.lua", "keyfwd", true)
ccmgr.program.download("/programs/airship.lua", "/ccmgr/programs/airship.lua", "airship", true)

ccmgr.config.define(
  "feat.airship",
  {
    description = "Wether the node is an airship",
    type = "boolean",
    default = false
  }
)
if ccmgr.config.get("feat.airship") then
  ccmgr.program.download("/features/airship.lua", "/run/airship.lua", nil, false)
  ccmgr.program.run("/run/airship.lua", "Airship", true, false)
end
