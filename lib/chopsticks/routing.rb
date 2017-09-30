module Chopsticks
  class RouteObject
    def initialize
      @rules = []

      match "/:controller/", default: {action: :index}
      match "/:controller/:id", default: {action: :show}
      match "/:controller/:id/:action"
    end

    def match(url, *args)
      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}

      # destination, maybe a middleware or a controller
      to = nil
      to = args.pop if args.length > 0
      raise 'Too many arguments!' if args.length > 0

      # compile regexp from url
      parts = url.split('/')
      parts.reject! { |p| p.empty? }

      param_keys = []
      regexp_parts = parts.map do |part|
        if part[0] == ':'
          param_keys << part[1..-1]
          '([A-Za-z0-9_]+)'
        elsif part[0] == '*'
          param_keys << part[1..-1]
          '(.*)'
        else
          part
        end
      end

      regexp = regexp_parts.join('/')

      @rules.unshift({
        regexp: Regexp.new("^/#{regexp}/?$"),
        param_keys: param_keys,
        to: to,
        options: options,
      })
    end

    def check_url(url)
      @rules.each do |r|
        m = r[:regexp].match(url)
        if m
          options = r[:options]
          params = options[:default].dup
          r[:param_keys].each_with_index do |k, i|
            params[k.intern] = m.captures[i]
          end

          if r[:to]
            return get_dest(r[:to], params)
          else
            controller = params[:controller]
            action = params[:action]
            return get_dest("#{controller}##{action}", params)
          end
        end
      end

      nil
    end

    def get_dest(to, routing_params = {})
      return to if to.respond_to?(:call)
      
      if to =~ /^([^#]+)#([^#]+)$/
        controller_name = Chopsticks.to_camle_case($1)
        controller = Object.const_get("#{controller_name}Controller")
        return controller.action($2, routing_params)
      end
      raise "No destination: #{to.inspect}!"
    end

    def root(to)
      match '/', to
    end
  end

  class Application
    def route(&b)
      @route_obj ||= RouteObject.new
      @route_obj.instance_eval(&b)
    end

    def get_rack_app(env)
      raise 'No routes!' unless @route_obj
      @route_obj.check_url env['PATH_INFO']
    end

  end

end
