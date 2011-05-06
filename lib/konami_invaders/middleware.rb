# (c) 2011 Phil Hofmann <phil@branch14.org>

module KonamiInvaders
  class Middleware

    attr_accessor :app, :options

    def initialize(app, options)
      self.app, self.options = app, options
      self.options['assets'] ||= assets
    end

    def call(env)
      path = env["PATH_INFO"]
      if options['assets'].include? path
        # deliver
        file = File.join(assets_path, path)
        extension = File.extname(file)
        mime = Rack::Mime.mime_type(extension)
        data = File.read(file) 
        [ 200, { 'Content-type:' => mime }, data ]
      else
        # inject
        status, headers, response = app.call(env)
        if headers["Content-Type"] =~ /text\/html|application\/xhtml\+xml/
          body = ""
          response.each { |part| body << part }
          index = body.rindex "</head>"
          if index
            body.insert index, payload
            headers["Content-Length"] = body.length.to_s
            response = [ body ]
          end
        end
        [ status, headers, response ]
      end
    end

    private

    def payload
      javascript_tag '/konami/invaders.js'
    end

    def assets
      @assets ||= Dir.glob("#{assets_path}/**/*").map { |path| path.gsub(assets_path, '') }
    end

    def assets_path
      File.expand_path('../../../public', __FILE__)
    end

    def javascript_tag(src)
      '<script type="text/javascript" src="%s"></script>' % src
    end

  end
end
