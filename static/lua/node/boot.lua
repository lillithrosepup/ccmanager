local program = require('/lvn/core/program')

program.download('/lua/node/main.lua', '/run/main.lua', "node", false)

program.download('/lua/node/ws.lua', '/run/ws.lua', false, false)

program.download('/lua/shared/ws.lua', '/run/sharedWs.lua', false, false)

program.download('/lua/shared/rednet.lua', '/run/sharedRednet.lua', false, false)

if turtle ~= nil then

  lvn.config.define("turtle.defaultMode", {
    description = "The default mode to run",
    type = "string",
    default = "idle"
  })
  lvn.config.define("turtle.defaultModeArgs", {
    description = "The default mode arguments",
    type = "table",
    default = "{}"
  })
  lvn.config.define("turtle.sendChat", {
    description = "Wether to send chat messages when ores are found",
    type = "boolean",
    default = true
  })
  fs.makeDir("/lvn/config/turtle")
  fs.makeDir("/run/turtle")
  fs.makeDir("/run/turtle/modes")

  program.download('/lua/turtle/main.lua', '/run/turtle/main.lua', "turtle", false)
  program.download('/lua/turtle/ws.lua', '/run/turtle/ws.lua', false, false)
  program.download('/lua/turtle/pos.lua', '/run/turtle/pos.lua', false, false)
  program.download('/lua/turtle/setHome.lua', '/run/turtle/setHome.lua', "setHome", true)
  program.download('/lua/turtle/modes/idle.lua', '/run/turtle/modes/idle.lua', false, false)
  program.download('/lua/turtle/modes/spin.lua', '/run/turtle/modes/spin.lua', false, false)
  program.download('/lua/turtle/modes/goto.lua', '/run/turtle/modes/goto.lua', false, false)
  program.download('/lua/turtle/modes/mine.lua', '/run/turtle/modes/mine.lua', false, false)
  program.download('/lua/turtle/modes/mobgrinder.lua', '/run/turtle/modes/mobgrinder.lua', false, false)
end


lvn.config.define("sorter", {
  description = "Specify this node as a sorter node",
  type = boolean,
  default = false
})
if lvn.config.get("sorter") then
  fs.makeDir("/run/sorter")
  if not fs.exists('/lvn/sorter') then
    fs.makeDir('/lvn/sorter')
    program.download('/lua/sorter/defaultFilters.lua', '/lvn/sorter/filters.lua', false, false)
  end
  program.download('/lua/sorter/main.lua', '/run/sorter/main.lua', "sorter", false)
  program.download('/lua/sorter/filters.lua', '/run/sorter/filters.lua', false, false)

  os.loadAPI('/run/sorter/filters.lua')
  os.loadAPI('/lvn/sorter/filters.lua')
end

lvn.config.define("constellation", {
  description = "Specify this node as a constellation node",
  type = "boolean",
  default = false
})
lvn.config.define("constellation.x", {
  description = "The X coordinate of the constellation node",
  type = "number",
})
lvn.config.define("constellation.y", {
  description = "The Y coordinate of the constellation node",
  type = "number",
})
lvn.config.define("constellation.z", {
  description = "The Z coordinate of the constellation node",
  type = "number",
})

lvn.config.define("constellation.dimension", {
  description = "The dimension of the constellation node",
  type = "string",
})

if lvn.config.get("constellation") then
  fs.makeDir("/run/constellation")
  program.download('/lua/constellation/main.lua', '/run/constellation/main.lua', "constellation", false)
  program.download('/lua/constellation/ws.lua', '/run/constellation/ws.lua', false, false)
  program.download('/lua/constellation/rednet.lua', '/run/constellation/rednet.lua', false, false)
end

lvn.config.define("airship", {
  description = "If this node is an airship controller",
  type = "boolean"
})

if lvn.config.get("airship") then
  fs.makeDir("/run/airship")
  program.download('/lua/airship/main.lua', '/run/airship/main.lua', "constellation", false)
  -- program.download('/lua/airship/ws.lua', '/run/airship/ws.lua', false, false)
  -- program.download('/lua/airship/rednet.lua', '/run/airship/rednet.lua', false, false)
end

-- local topPeripheralMethods = peripheral.getMethods("top")
-- if topPeripheralMethods then
--   -- if lvn.utils.list.contains(topPeripheralMethods, "getDestinationDimension") then
--   --   fs.makeDir("/run/tardis")
--   --   program.download('/lua/tardis/main.lua', '/run/tardis/main.lua', "tardis", false)
--   -- end
-- end

os.loadAPI('/run/sharedWs.lua')
os.loadAPI('/run/sharedRednet.lua')

lvn.config.define("node.password", {
  description = "The node's password",
  type = "string",
})

local success = pcall(shell.run, '/run/main.lua')

if not success then
  lvn.chat.send('Failed to run main.lua')

  sleep(5)

  os.reboot()
end