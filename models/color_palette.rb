class ColorPalette < ActiveRecord::Base


  # --- Associations ----------------------------------------------------------

  belongs_to :web_page

  serialize :pixel_color,     Array
  serialize :dominant_color,  Array
  serialize :color_palette


  # --- Validations -----------------------------------------------------------

  before_save :convert_rgb_to_hsl

  validates :pixel_color_red,       numericality: {greater_than_or_equal_to: 0, less_than: 256}, allow_nil: true, allow_blank: true
  validates :pixel_color_green,     numericality: {greater_than_or_equal_to: 0, less_than: 256}, allow_nil: true, allow_blank: true
  validates :pixel_color_blue,      numericality: {greater_than_or_equal_to: 0, less_than: 256}, allow_nil: true, allow_blank: true
  validates :dominant_color_red,    numericality: {greater_than_or_equal_to: 0, less_than: 256}, allow_nil: true, allow_blank: true
  validates :dominant_color_green,  numericality: {greater_than_or_equal_to: 0, less_than: 256}, allow_nil: true, allow_blank: true
  validates :dominant_color_blue,   numericality: {greater_than_or_equal_to: 0, less_than: 256}, allow_nil: true, allow_blank: true


  # --- Scopes ----------------------------------------------------------------

  scope :has_pixel_color, where("(pixel_color_red != '' AND pixel_color_red IS NOT NULL) AND (pixel_color_green != '' AND pixel_color_green IS NOT NULL) AND (pixel_color_blue != '' AND pixel_color_blue IS NOT NULL)")


  # --- Methods ---------------------------------------------------------------

  def self.color_avg(v); where("#{v} != '' AND #{v} IS NOT NULL").average(v).to_f; end

  def self.pixel_hex_color; ("%02x%02x%02x" % pixel_rgb).upcase; end
  def self.pixel_rgb; [color_avg(:pixel_color_red), color_avg(:pixel_color_green), color_avg(:pixel_color_blue)]; end
  def self.dominant_hex_color; ("%02x%02x%02x" % dominant_rgb).upcase; end
  def self.dominant_rgb; [color_avg(:dominant_color_red), color_avg(:dominant_color_green), color_avg(:dominant_color_blue)]; end

  # def self.hsl_hex_color
  #   h,s,l = color_avg(:pixel_color_hue), color_avg(:pixel_color_saturation), color_avg(:pixel_color_value)
  #   # h,s,l = color_avg(:dominant_color_hue), color_avg(:dominant_color_saturation), color_avg(:dominant_color_value)
  #   # puts h,s,l
  #   # rgb = Color::HSL.from_fraction(h,s,l).to_rgb
  #   # rgb.html.gsub(/\#/, '').upcase
  # end


  # API Output
  def to_api
    {
      id: id, page: web_page.to_api,
      pixel: {r: pixel_color_red, g: pixel_color_green, b: pixel_color_blue, hex: pixel_hex_color}, 
      dominant: {r: dominant_color_red, g: dominant_color_green, b: dominant_color_blue, hex: dominant_hex_color}, 
    }
  end


  def pixel_hex_color
    ("%02x%02x%02x" % [self.pixel_color_red, self.pixel_color_green, self.pixel_color_blue]).upcase
  end

  def dominant_hex_color
    ("%02x%02x%02x" % [self.dominant_color_red, self.dominant_color_green, self.dominant_color_blue]).upcase
  end

  def convert_rgb_to_hsl
    begin
      rgb = Color::RGB.new(self.pixel_color_red,self.pixel_color_green,self.pixel_color_blue)
      hsl = rgb.to_hsl
      self.pixel_color_hue = hsl.h
      self.pixel_color_saturation = hsl.s
      self.pixel_color_value = hsl.l
    rescue => err
      _debug("HSL Pixel Error: #{err}", 1, self)
    end

    begin
      rgb = Color::RGB.new(self.dominant_color_red,self.dominant_color_green,self.dominant_color_blue)
      hsl = rgb.to_hsl
      self.dominant_color_hue = hsl.h
      self.dominant_color_saturation = hsl.s
      self.dominant_color_value = hsl.l
    rescue => err
      _debug("HSL Dominant Error: #{err}", 1, self)
    end
  end


protected


end