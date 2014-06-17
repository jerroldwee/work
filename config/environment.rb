# Load the Rails application.
require File.expand_path('../application', __FILE__)

FACEBOOK = YAML.load(File.read(File.expand_path('../facebook.yml', __FILE__)))[Rails.env]
APP = YAML.load(File.read(File.expand_path('../application.yml', __FILE__)))[Rails.env]

# Initialize the Rails application.
FigoRails::Application.initialize!
