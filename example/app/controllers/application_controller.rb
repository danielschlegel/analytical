class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  analytical :track_page_load_time => true, :disable_if => lambda{|controller| false}, :use_session_store => true
end
