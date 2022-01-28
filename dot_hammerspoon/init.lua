hs.hotkey.bind({"cmd"}, "u", function()
  local app = hs.appfinder.appFromName("Alacritty")
  local logger = hs.logger.new('i3','debug')
  logger.d("app is ", app)

  if app then
    logger.d("Found app")
    if app:isFrontmost() then
      logger.d("hiding app")
      app:hide()
      return
    else
      logger.d("activating app")
      app:activate()
    end
  else
    logger.d("launching or focusing app")
    hs.application.launchOrFocus("Alacritty")
    app = hs.application.get("Alacritty")
  end

  logger.d("resizing")
  app:mainWindow():moveToUnit'[70,70,30,30]'
  app:mainWindow().setShadows(false)
end)
