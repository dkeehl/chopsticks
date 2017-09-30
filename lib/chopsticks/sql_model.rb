require 'sqlite3'
require 'chopsticks/util'

DB = SQLite3::Database.new 'test.db'

module Chopsticks
  module Model
    class SQLite
      def initialize(data = nil)
        @hash = data
      end

      def [](name)
        @hash[name.to_s]
      end

      def []=(name, value)
        @hash[name.to_s] = value
      end

      def save!
        unless @hash['id']
          self.class.create
          return true
        end

        fields = @hash.map do |k, v|
          "#{k} = #{self.class.to_sql v}"
        end.join ','

        DB.execute <<-SQL
        UPDATE #{self.class.table}
        SET #{fields}
        WHERE id = #{@hash['id']};
        SQL
        true
      end

      def save
        save! rescue false
      end

      def method_missing(m, *args)
        if self.class.schema.keys.include?(m.to_s)
          self.class.class_eval <<-RUBY
            def #{m}; @hash['#{m}'] end
          RUBY
          @hash[m.to_s]
        else
          super
        end
      end
        
      def self.to_sql(val)
        case val
        when Numeric
          val.to_s
        when String
          "'#{val}'"
        else
          raise "Can't change #{val.class} to SQL!"
        end
      end

      def self.create(values)
        values.delete 'id'
        keys = schema.keys - ['id']
        vals = keys.map { |k| values[k] ? to_sql(values[k]) : 'null' }

        DB.execute <<-SQL
        INSERT INTO #{table} (#{keys.join ','})
        VALUES (#{vals.join ','});
        SQL

        data = {}
        keys.each { |k| data[k] = values[k] }

        sql = 'SELECT last_insert_rowid()'
        data['id'] = DB.execute(sql)[0][0]
        new data
      end

      def self.count
        DB.execute(<<-SQL)[0][0]
        SELECT COUNT(*) FROM #{table};
        SQL
      end

      def self.find(id)
        row = DB.execute <<-SQL
        SELECT #{schema.keys.join ','} FROM #{table} WHERE id = #{id};
        SQL

        data = Hash[schema.keys.zip row[0]]
        new data
      end

      def self.all
        records = DB.execute("SELECT * FROM #{table}")
        records.map do |r|
          data = Hash[schema.keys.zip r]
          new data
        end
      end

      def self.table
        Chopsticks.to_underscore name
      end

      def self.schema
        return @schema if @schema

        @schema = {}
        DB.table_info(table) do |row|
          @schema[row['name']] = row['type']
        end

        @schema
      end

    end

  end
end
