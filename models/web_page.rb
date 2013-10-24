class WebPage < ActiveRecord::Base

  # self.per_page = 50

  STEPS = [:none, :screenshot, :process, :scrape, :parse, :complete]


  # Nicer fetching by url name
  extend FriendlyId
  friendly_id :path, use: :scoped, scope: :web_site_id

  # File storage for HTML page
  include Paperclip::Glue

  has_attached_file :html_page, 
    path: "storage/web_pages/:attachment/:id_partition/:style/:filename",
    styles:  {
      original: {format: :html, processors: [:save_html]}
    }

  has_attached_file :screenshot, 
    path: "storage/web_pages/:attachment/:id_partition/:style.:extension",
    styles: {
      thumbnail: "",
      pixel: ["1x1#", :png]
    },
    convert_options: {
      thumbnail: "-gravity north -thumbnail 300x300^ -extent 300x300 -background white -flatten +matte",
      pixel: "-background white -flatten +matte"
    }


  # --- Associations ----------------------------------------------------------

  belongs_to :web_site, :counter_cache => :web_pages_count
  has_one :color_palette

  before_save :update_counter_if_complete

  serialize :headers, Hash


  # --- Validations -----------------------------------------------------------

  validates :url, presence: true, format: {with: /\Ahttp/i}


  # --- Scopes ----------------------------------------------------------------

  STEPS.each_with_index do |v,i|
    scope "#{v}?".to_sym, where('step_index >= ?', i)
  end
    

  scope :available, where(available: true)


  # --- Methods ---------------------------------------------------------------

  # API Output
  def to_api
    {id: id, url: url, title: (title || '').gsub(/\<(\/)?title\>(\n+)?/im, ''), screenshot: {original: screenshot.url(:original), thumbnail: screenshot.url(:thumbnail), pixel: screenshot.url(:pixel)}}
  end

  # Mark next step. Do save to ensure is passable
  def step!(s)
    return false unless STEPS.include?(s)
    self.save && self.update_attribute(:step_index, STEPS.index(s))
  end

  # Check if has completed step
  def step?(s)
    return false unless STEPS.include?(s)
    self.step_index >= STEPS.index(s)
  end

  # Get the current step
  def step; STEPS[self.step_index]; end

  # Filename for use w/ Paperclip
  def filename
    uri = Addressable::URI.parse(self.url)
    f = File.basename(uri.path)
    (f.blank? ? 'index' : f)
  end


protected

  def update_counter_if_complete
    if self.step == :complete && self.step_index_changed?
      WebSite.increment_counter(:completed_web_pages_count, self.web_site_id)
    end
  end

end