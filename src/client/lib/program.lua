---@class CCMProgram
---@field download fun(url: string, path: string, alias?: string, completion?: boolean): boolean
---@field run fun(path: string, title?: string, focus?: boolean, ...: any): number

local function download(url, path, alias, compl)
  local success = ccmgr.net.downloadFile("/client" .. url, path)
  if not success then
    return false
  end

  if alias then
    shell.setAlias(alias, path)
  end

  if compl then
    shell.run(path .. " completion")
  end

  return true
end

local function run(path, title, focus, ...)
  local id = multishell.launch(getfenv(), path, ...)
  if title then
    multishell.setTitle(id, title)
  end
  if focus then
    multishell.setFocus(id)
  end
  return id
end

return {
  download = download,
  run = run
}