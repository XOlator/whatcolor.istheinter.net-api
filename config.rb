# encoding: UTF-8

Encoding.default_external = "UTF-8"
Encoding.default_internal = "UTF-8"


# PRE-DEFINED VARS
TIME_START    ||= Time.now
TEXT_COL_LEN  ||= 80

APP_ROOT  ||= File.expand_path(File.dirname(__FILE__))
APP_ENV   ||= 'development'
APP_MODE  ||= 'webapp'
DEBUG     ||= false


# REQUIRE MODULES/GEMS
%w{yaml crack json redis active_record addressable/uri paperclip friendly_id color}.each{|r| require r}

# INITIALIZERS
Dir.glob("#{APP_ROOT}/initializers/*.rb").each{|r| require r}


# CONFIG
APP_CONFIG = YAML::load(File.open("#{APP_ROOT}/config.yml"))[APP_ENV]

# SETUP DATABASE
require 'mysql2'
@DB = ActiveRecord::Base.establish_connection( YAML::load(File.open("#{APP_ROOT}/database.yml"))[APP_ENV] )
@REDIS = Cache.establish_connection( YAML::load(File.open("#{APP_ROOT}/redis.yml"))[APP_ENV] )

# REQUIRE DATABASE MODELS
Dir.glob("#{APP_ROOT}/models/*.rb").each{|r| require r}
Dir.glob("#{APP_ROOT}/helpers/*.rb").each{|r| require r}