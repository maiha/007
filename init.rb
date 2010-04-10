$KCODE = 'u'

require File.join(File.dirname(__FILE__), 'gem_activate')

gems = GemActivate.new
gems.add('dependencies') do
  begin
    require "vendor/dependencies/lib/dependencies"
  rescue LoadError
    require "dependencies"
  end
end
gems.add('mongo_mapper') do
  require 'mongo_mapper'
  MongoMapper.database = "memo"
end
gems.add('sinatra') do
  require "sinatra/base"
  require 'haml'
end

gems.add('james-bond')
gems.execute(:verbose=>!(ENV['RACK_ENV'] == 'production'))


James.config do
  # Specify files to load, and give :reload for reloading in deveopment.
  # When a directory is given, sub directory is automatically loaded.
  # In default, following code is internally defined.
  #
  # require "lib"
  # require "app", :reload
  # require "config/local", :reload
end

James.run(__FILE__)
