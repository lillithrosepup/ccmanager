if not lvn.config.get("boot.skipWait") then
  print("Waiting for all nodes to boot")
  os.sleep(2)
end

lvn.config.define("boot.skipWait", {
  description = "If defined, skips the 2s wait on boot",
  type = "string",
})

local program = require('/lvn/core/program')

program.download('/lua/admin/toggle.lua', '/run/toggle.lua', 'toggle', true)

program.download('/lua/admin/eval.lua', '/run/eval.lua', 'eval', true)

program.download('/lua/admin/turtle.lua', '/run/turtle.lua', 'turtle', true)

program.download('/lua/admin/debug.lua', '/run/debug.lua', 'debug', true)

program.download('/lua/admin/packet.lua', '/run/packet.lua', 'packet', true)

program.download('/lua/admin/reboot.lua', '/run/reboot.lua', 'reboot', true)

program.download('/lua/admin/redremote.lua', '/run/redremote.lua', 'redremote', true)


fs.makeDir("/run/win")
program.download('/lua/admin/win/main.lua', '/run/win/main.lua', 'win', false)

program.download('/lua/admin/update.lua', '/run/update.lua', 'update', false)

program.download('/lua/shared/ws.lua', '/run/sharedWs.lua', false, false)

program.download('/lua/shared/rednet.lua', '/run/sharedRednet.lua', false, false)

program.download('/lua/shared/term.lua', '/run/term.lua', false, false)

os.loadAPI('/run/sharedWs.lua')
os.loadAPI('/run/sharedRednet.lua')

program.run('/run/sharedWs.lua', 'Websocket Runner', false, "loop")
program.run('/run/sharedRednet.lua', 'Rednet Runner', false, "loop")

lvn.config.define("admin.password", {
  description = "The password to access the admin interface",
  type = "string",
})


if not lvn.config.get("admin.password") then
  print("You do not have a password set.")
  io.write("Please enter a password: ")
  local password = io.read("*l")

  lvn.config.set("admin.password", password)
end

-- if peripheral.find("monitor") then
--   shell.run("/run/win/main.lua")
-- end