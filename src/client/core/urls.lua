ccmgr.urls = {
  httpBase = "http" ..
    (ccmgr.config.get("boot.ssl") and "s" or "") ..
      "://" .. ccmgr.config.get("boot.host") .. ":" .. ccmgr.config.get("boot.port"),
  ws = "ws" ..
    (ccmgr.config.get("boot.ssl") and "s" or "") ..
      "://" .. ccmgr.config.get("boot.host") .. ":" .. ccmgr.config.get("boot.port") .. "/ws"
}
