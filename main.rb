require 'rubygems'
require 'sinatra'
require 'coffee-script'
require 'sass'

require "./lib/om"
require "./lib/rdio"
require 'open-uri'
require 'RMagick'
include Magick


RDIO_IDS = %w[s1640129, s1530579] #brit & scott

# Root
get '/' do
  rdio = Rdio.new([ENV['RDIO_KEY'], ENV['RDIO_SECRET']])
  scott_playlists = rdio.call("getPlaylists", {"user" => "s1530579", "extras" => "iframeUrl, description"})
  brit_playlists = rdio.call("getPlaylists", {"user" => "s1640129", "extras" => "iframeUrl, description"})

  @playlists = []

  scott_playlists["result"]["owned"].each do |playlist|
    if playlist["name"].downcase.include? "and to hold"
      @playlists << playlist
    end
  end

  brit_playlists["result"]["owned"].each do |playlist|
    if playlist["name"].downcase.include? "and to hold"
      @playlists << playlist
    end
  end

  @playlists.each do |playlist|
    if !File.exist?("/tmp/#{playlist["key"]}.png")
      url = playlist["icon"].gsub("=200","=1200")
      img = Magick::Image.read(url).first
      img = img.blur_image(0,4)
      img.write("/tmp/#{playlist["key"]}.png")
    end
  end

  erb :index
end

# Blur image
get "/home/blur_image/:id" do
  content_type 'image/png'
  playlist_id = params[:id]

  img = Magick::Image.read("/tmp/#{playlist_id}")[0]
  img.format = 'png'
  img.to_blob
end

## ASSETS ##

get "/application.js" do
  coffee :application
end

get "/application.css" do
  content_type 'text/css', :charset => 'utf-8'
  scss :application
end