require 'multi_json'

module Chopsticks
  module Model
    class FileModel
      def initialize(filename)
        @filename = filename
        basename = File.split(filename)[-1]
        @id = File.basename(basename, '.json').to_i

        f = File.read(filename)
        @hash = MultiJson.load(f)
      end

      def [](key)
        @hash[key.to_s]
      end

      def []=(key, value)
        @hash[key.to_s] = value
      end

      def save
        File.open(@filename, 'w') { |f| f.write MultiJson.dump(@hash) }
      end

      def self.find(id)
        begin
          new("db/quotes/#{id}.json")
        rescue
          return nil
        end
      end

      def self.all
        files = Dir["db/quotes/*.json"]
        files.map { |f| new f }
      end
      
      def self.create(attrs)
        hash = {}
        hash['submitter'] = attrs[:submitter] || ''
        hash['quote'] = attrs[:quote] || ''
        hash['attribution'] = attrs[:attribution] || ''

        files = Dir["db/quotes/*.json"]
        ids = files.map { |f| File.split(f)[-1][0...-5].to_i }
        id = ids.max + 1

        File.open("db/quotes/#{id}.json", 'w') do |f|
          f.write <<-JSON
          { 
            "submitter": "#{hash['submitter']}",
            "quote": "#{hash['quote']}",
            "attribution": "#{hash['attribution']}"
          }
          JSON
        end

        new "db/quotes/#{id}.json"
      end

      def self.where(attrs)
        all.select do |q|
          test = true
          attrs.each_pair { |k, v| test &&= q[k] == v }
          test
        end
      end

      def self.method_missing(m, *args)
        if m =~ /^find_all_by_(.+)/
          where($1 => args[0])
        else
          super
        end
      end

    end

  end
end
