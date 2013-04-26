require 'annotations.rb'

# FIX for engines model reloading issue in development mode
if ENV['RAILS_ENV'] != 'production'
	autoload_paths.each do |path|
		ActiveSupport::Dependencies.autoload_once_paths.delete(path)
	end
end
