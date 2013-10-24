# encoding: UTF-8

# A X&O Lab Creative Project
# http://www.x-and-o.co/lab
#
# (C) 2013 X&O. All Rights Reserved
# License information: LICENSE.md


# START IT UP...

require "rubygems"
require "bundler"
Bundler.require

require "sinatra"


configure do
  APP_MODE = 'api'
  APP_ROOT = File.expand_path('.', File.dirname(__FILE__))
  DEBUG = false
  TIME_START = Time.now
  require "#{APP_ROOT}/config.rb"

  %w{haml sinatra/content_for sinatra/respond_to sinatra/r18n sinatra/flash}.each{|r| require r}

  Sinatra::Application.register Sinatra::RespondTo

  files = []
  files += Dir.glob("#{APP_ROOT}/lib/*.rb")
  files.each{|r| require r}

  AWS.eager_autoload!

  # Ugly override!
  module Sinatra
    module RespondTo
      module Helpers
        def format(val=nil)
          unless val.nil?
            mime_type = ::Sinatra::Base.mime_type(val)
            @_format = val.to_sym
            if mime_type.nil?
              request.path_info << ".#{val}"
              mime_type = 'text/html'
              @_format = 'html'
            end
            response['Content-Type'] ? response['Content-Type'].sub!(/^[^;]+/, mime_type) : content_type(@_format)
          end
          @_format
        end
      end
    end
  end


  FLASH_TYPES = [:warning, :notice, :success, :error]
  use Rack::Session::Cookie, :key => 'wciti_rack_key', :secret => 'plzdontbegrey13', :path => '/', :expire_after => 21600
  set :sessions => true

  # Allow iframe embedding
  set :protection, :except => :frame_options

  # --- I18N -------------------------------
  APP_LOCALES = {
    :en => 'English',
  }

  Sinatra::Application.register Sinatra::R18n
  set :default_locale, 'en'
  set :translations,   './i18n'

end

before do
  set_current_user_locale
  set_template_defaults
end