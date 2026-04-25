local program = require("/ccmgr/lib/program")

program.download("/client/ws.lua", "/run/ws.lua", false, false)
os.loadAPI("/run/ws.lua")
program.run("/run/ws.lua", "Websocket Runner", true, "loop")
