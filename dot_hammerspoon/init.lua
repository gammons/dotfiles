hs.hotkey.bind({"cmd"}, "u", function()
  local app = hs.appfinder.appFromName("Alacritty")

  if app then
    if app:isFrontmost() then
      app:hide()
      return
    else
      app:activate()
    end
  else
    hs.application.launchOrFocus("Alacritty")
    app = hs.application.get("Alacritty")
  end

  app:mainWindow():moveToUnit'[30,30,70,70]'
end)

hs.hotkey.bind({"cmd"}, "1", function()
  local app = hs.appfinder.appFromName("/Applications/Google Chrome.app")
  hs.application.launchOrFocus("/Applications/Google Chrome.app")
end)

hs.hotkey.bind({"cmd"}, "2", function()
  local app = hs.appfinder.appFromName("/Applications/Slack.app")
  hs.application.launchOrFocus("/Applications/Slack.app")
end)

hs.hotkey.bind({"cmd"}, "3", function()
  local app = hs.appfinder.appFromName("/Applications/Kitty.app")
  hs.application.launchOrFocus("/Applications/Kitty.app")
end)

hs.hotkey.bind({"cmd", "shift"}, "m", function()
  local app = hs.application.frontmostApplication()
  app:mainWindow():moveToUnit'[20,0,70,70]'
end)

hs.hotkey.bind({"cmd"}, "F4", function()
  hs.spotify.previous()
end)

hs.hotkey.bind({"cmd"}, "F5", function()
  hs.spotify.playpause()
end)

hs.hotkey.bind({"cmd"}, "F6", function()
  hs.spotify.next()
end)
