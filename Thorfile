class Monk < Thor
  include Thor::Actions

  desc "test", "Run all tests"
  def test
#    system("redis-server spec/redis.conf")

    verify_config(:test)

    $:.unshift File.join(File.dirname(__FILE__), "test")

    Dir['test/**/*_test.rb'].each do |file|
      load file unless file =~ /^-/
    end
  end

  desc "stories", "Run user stories."
  method_option :pdf, :type => :boolean
  def stories
    $:.unshift(Dir.pwd, "test")

    ARGV << "-r"
    ARGV << (options[:pdf] ? "stories-pdf" : "stories")
    ARGV.delete("--pdf")

    Dir["test/stories/*_test.rb"].each do |file|
      load file
    end
  end

  desc "start ENV", "Start Monk in the supplied environment"
  method_option :port
  def start(env = ENV["RACK_ENV"] || "development")
    exec "env RACK_ENV=#{env} RACK_PORT=#{options[:port]} ruby init.rb"
  end

  desc "start ENV", "Start Monk console in the supplied environment"
  def console(env = ENV["RACK_ENV"] || "development")
    exec "env RACK_ENV=#{env} irb -r init -Ku"
  end

  desc "copy_example EXAMPLE, TARGET", "Copies an example file to its destination"
  def copy_example(example, target = target_file_for(example))
    File.exists?(target) ? return : say_status(:missing, target)
    File.exists?(example) ? copy_file(example, target) : say_status(:missing, example)
  end


  class Activate
    Library = Struct.new(:name, :time, :error)
    class Library
      def activate
        time = Time.now
        require name
        self.time = Time.now - time
      rescue LoadError => e
        self.error = e.to_s
      end
    end

    def initialize(*names)
      # normalize
      names = names.map{|i| i.sub(%r{-\d+(\.\d+)*$}, '')}
      names.delete 'rubygems'
      names.unshift 'rubygems'
      @libs = names.map{|name| Library.new(name)}
    end

    def execute
      activate
      dump
    end

    private
      def activate
        @libs.each(&:activate)
      end

      def colorize(text, ansi); "#{ansi}#{text}\e[0m"; end
      def green (text); colorize(text, "\e[32m"); end
      def red   (text); colorize(text, "\e[31m"); end
      def yellow(text); colorize(text, "\e[33m"); end
      def blue  (text); colorize(text, "\e[34m"); end

      def dump(output = $stdout)
        sum = @libs.inject(0){|v,l| v+l.time.to_f}
        @libs.each do |lib|
          if sum == 0
            per = yellow('[-----]')
          elsif lib.time.to_f == 0
            per = red('[-----]')
          else
            per = green('[%4.1f%%]' % (lib.time.to_f*100/sum))
          end

          error = lib.error ? red("[#{lib.error}]") : ''
          time = lib.time ? green("%.7f" % lib.time.to_f) : red("%7s" % '---------')
          output.puts "#{per} #{time} #{lib.name} #{error}"
        end
      end
  end

  desc "benchmark", "Benchmark for loading gems"
  def benchmark(*gems)
    Activate.new(*gems).execute
  end


#   desc "start background job worker"
#   def job
#     exec "ruby script/daemons/background.rb > background.log"
#   end

private

  def self.source_root
    File.dirname(__FILE__)
  end

  def target_file_for(example_file)
    example_file.sub(".example", "")
  end

  def verify_config(env)
    verify "config/settings.example.yml"
    verify "config/redis/#{env}.example.conf"
  end

  def verify(example)
    copy_example(example) unless File.exists?(target_file_for(example))
  end

end
