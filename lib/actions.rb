def current_color
  {
    count: Cache.get('palette_count').to_i, 
    pixel: {hex: Cache.get('pixel_hex_color'), r: Cache.get('pixel_rgb_red').to_i, g: Cache.get('pixel_rgb_green').to_i, b: Cache.get('pixel_rgb_blue').to_i}, 
    dominant: {hex: Cache.get('dominant_hex_color'), r: Cache.get('dominant_rgb_red').to_i, g: Cache.get('dominant_rgb_green').to_i, b: Cache.get('dominant_rgb_blue').to_i}, 
    cached_at: Time.at(Cache.get('index_reset_at').to_i)
  }
end

def reset_current_cache
  t = Cache.get('index_reset_at') rescue nil
  t ||= 0
  to = 5.minutes

  if (Time.now > (Time.at(t.to_i)+to))
    pixel_rgb, dom_rgb = ColorPalette.pixel_rgb, ColorPalette.dominant_rgb
    Cache.set('palette_count', ColorPalette.count)
    Cache.set('pixel_hex_color', ColorPalette.pixel_hex_color)
    Cache.set('dominant_hex_color', ColorPalette.dominant_hex_color)
    Cache.set('pixel_rgb_red', pixel_rgb[0].round)
    Cache.set('pixel_rgb_green', pixel_rgb[1].round)
    Cache.set('pixel_rgb_blue', pixel_rgb[2].round)
    Cache.set('dominant_rgb_red', dom_rgb[0].round)
    Cache.set('dominant_rgb_green', dom_rgb[1].round)
    Cache.set('dominant_rgb_blue', dom_rgb[2].round)
    Cache.set('index_reset_at', Time.now.to_i)
  end
end

def color_stream(opts={})
  l = opts[:limit]
  l ||= 60
  obj = ColorPalette.has_pixel_color.order('id desc').limit(l.to_i > 300 ? 300 : l.to_i)

  # Specific hack to make return call results simple.
  if opts[:simple]
    obj.map{|v| v.to_simple_api(opts[:color_type] || :pixel) }
  else
    obj.map(&:to_api)
  end
end


# API Stream (latest)
# Show the latest stream information from the scraping process.
#
#   Options:
#   *   limit - (default: 60, min: 1, max: 300)
#
get '/api/stream' do
  respond_to do |format|
    format.csv {
      params[:simple] = 1 #Force simple
      content_type :csv
      csv = [] #['ID', 'Pixel Red', 'Pixel Green', 'Pixel Blue', 'Pixel Hex'].join(',')]
      color_stream(params).each{|v| csv << [v[:id], v[:r], v[:g], v[:b], v[:hex]].join(',')}
      
      csv.join("\n")
    }
    format.json {
      content_type :json
      color_stream(params).to_json#, params[:callback]
    }
  end
end

# API Current
# Show the latest results from the scraping process. 
# Cached results up to 5 minutes old
#   
#   Options:
#   *   [none]
#
get '/api/current' do
  respond_to do |format|
    format.csv {
      content_type :csv
      reset_current_cache
      csv = [['Count', 'Cached', 'Pixel Red', 'Pixel Green', 'Pixel Blue', 'Pixel Hex', 'Dominant Red', 'Dominant Green', 'Dominant Blue', 'Dominant Hex'].join(',')]
      csv << [current_color[:count], current_color[:cached_at], current_color[:pixel][:r], current_color[:pixel][:g], current_color[:pixel][:b], current_color[:pixel][:hex], current_color[:dominant][:r], current_color[:dominant][:g], current_color[:dominant][:b], current_color[:dominant][:hex]].join(',')
      csv.join("\n")
    }
    format.json {
      content_type :json
      reset_current_cache
      current_color.to_json
    }
  end
end



# --- HTML PAGES ---

# Stream
get '/stream' do
  respond_to do |format|
    format.html {
      @color_stream = color_stream(params)
      haml :'stream'
    }
  end
end

# Homepage
get '/' do
  respond_to do |format|
    format.html {
      @color_info = current_color
      haml :'index'
    }
  end
end