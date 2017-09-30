require 'erubis'
require 'chopsticks/file_model'
require 'rack/request'

module Chopsticks

  class Controller
    include Chopsticks::Model

    def initialize(env)
      @env = env
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params.merge @routing_params
    end

    def response(text, status = 200, headers = {})
      raise 'Already responsed!' if @response

      a = [text].flatten
      @response = Rack::Response.new(a, status, headers)
    end

    def render(*args)
      response render_view(*args)
    end

    def get_response
      @response
    end

    def self.action(act, rp = {})
      proc { |e| self.new(e).dispatch(act, rp) }
    end

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      send action
      render action unless get_response

      st, hd, rs = get_response.to_a
      [st, hd, [rs.body].flatten]
    end

    private
      attr_reader :env
      
      def render_view(view_name, locals = {})
        filename = File.join('app', 'views', controller_name,
                             "#{view_name}.html.erb")
        template = File.read(filename)

        eruby = Erubis::Eruby.new(template)

        instance_variables.each do |v|
          locals.merge!(v => instance_variable_get(v))
        end

        eruby.result locals.merge(env: env)
      end

      def controller_name
        klass = self.class.to_s.gsub(/Controller$/, '')
        Chopsticks.to_underscore klass
      end

  end

end
