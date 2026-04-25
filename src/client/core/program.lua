local program = {
  download = function(url, path, alias, completion)
    local success = ccmgr.net.downloadFile(url, path)
    if not success then
      ccmgr.chat.send("Failed to download " .. url)
      return false
    end

    if alias then
      shell.setAlias(alias, path)
    end

    if completion then
      shell.run(path .. " completion")
    end

    return true
  end,
  run = function(path, title, focus, ...)
    local id = multishell.launch(getfenv(), path, ...)
    if title then
      multishell.setTitle(id, title)
    end
    if focus then
      multishell.setFocus(id)
    end
    return id
  end
}

return program
