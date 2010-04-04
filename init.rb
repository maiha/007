$KCODE = 'u'

def say(name, verbose = nil, &block)
  verbose ||= ENV['RACK_ENV'] == 'development'
  print "%s ... " % name if verbose
  block.call
  puts "done" if verbose
end

say("require 'rubygems'") {
  require "rubygems"
}

say("require 'dependencies'") {
  begin
    require "vendor/dependencies/lib/dependencies"
  rescue LoadError
    require "dependencies"
  end
}

say("require 'mongo_mapper'") {
  require 'mongo_mapper'
#  MongoMapper.database = "YOUR_DB_NAME"
}

say("require 'sinatra'") {
  require "sinatra/base"
  require 'haml'
}

say("require 'james-bond'") {
  require 'james-bond'
}

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
