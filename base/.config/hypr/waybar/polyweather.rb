#!/usr/bin/env ruby

require 'net/http'
require 'uri'
require 'json'

class Polyweather
  def initialize(api_key, lat, long)
    @api_key = api_key
    @lat = lat
    @long = long
  end

  def fetch
    url = "https://api.weather.com/v3/wx/observations/current?apiKey=e1f10a1e78da46f5b10a1e78da96f525&geocode=40.07%2C-75.3&units=e&language=en-US&format=json"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    result = JSON.parse(response.body)
    @result = JSON.parse(response.body)
  end

  def currently
    raise RuntimeError("Call fetch before calling currently") if result.nil?
    result["currently"]
  end

  def to_s
    "#{temperature}\u{00B0}F / #{humidity}% - #{summary}"
  end

  def humidity
    result["relativeHumidity"]
  end

  def temperature
    result["temperature"]
  end

  def summary
    result["wxPhraseLong"]
  end

  private

  attr_reader :api_key, :lat, :long, :result
end

begin
  p = Polyweather.new("5b6b96cc1b7dbdd2db851d95f8f2d3e9", "40.0756496", "-75.299668")
  p.fetch
  puts p.to_s
rescue
  nil
end
