class GemActivate
  Library = Struct.new(:name, :time, :error, :loader)
  class Library
    def activate
      time = Time.now
      if loader
        loader.call
      else
        require name
      end
    rescue Exception => e
      self.error = e.to_s
    ensure
      self.time = Time.now - time
    end
  end

  def initialize(*names)
    @opts = names.last.is_a?(Hash) ? names.pop : {}
    @opts = default_opts.merge(@opts)
    @libs = []
    add 'rubygems'
    names.each{|name| add name }
  end

  def <<(*args)
    add(*args)
  end

  def add(name, &block)
    name = name.sub(%r{-\d+(\.\d+)*$}, '')
    @libs << Library.new(name, nil, nil, block)
  end

  def execute(runtime_opts = {})
    opts = @opts.merge(runtime_opts)
    if opts[:profile]
      activate
      dump if opts[:verbose]
    else
      @libs.each do |lib|
        lib.activate
        puts library_summary(lib) if opts[:verbose]
      end
    end
  end

  private
    def default_opts
      {:profile=>false, :verbose=>false}
    end

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
        puts "#{per} #{library_summary(lib)}"
      end
    end

    def library_summary(lib)
      error = lib.error ? red("[#{lib.error}]") : ''
      time = lib.time ? green("%.7f" % lib.time.to_f) : red("%7s" % '---------')
      "#{time} #{lib.name} #{error}"
    end
end
