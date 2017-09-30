require "chopsticks/version"
require 'chopsticks/util'
require 'chopsticks/dependencies'
require 'chopsticks/routing'
require 'chopsticks/controller'
require 'chopsticks/file_model'
require 'chopsticks/sql_model'

module Chopsticks

  class Application
    def call(env)
      rack_app = get_rack_app(env)
      rack_app.call env
    end

  end

end
