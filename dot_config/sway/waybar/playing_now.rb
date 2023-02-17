artist = `playerctl metadata xesam:artist`.strip
title = `playerctl metadata xesam:title`
puts "#{artist} - #{title}"
