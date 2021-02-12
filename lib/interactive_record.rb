require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        # DB[:conn].results_as_hash = true
        sql = "pragma table_info('#{table_name}')"
        DB[:conn].execute(sql).map {|row| row["name"]}
    end


    def initialize(hash = {})
        hash.each {|attribute_name, attribute_value| self.send("#{attribute_name}=", attribute_value)}
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names[1..-1].join(", ")
    end

    def values_for_insert
        self.class.column_names[1..-1].map {|col| "'#{send(col)}'" }.join(", ")
    end

    def save
        sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
        DB[:conn].execute(sql)
        # DB[:conn].results_as_hash = false
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
        # binding.pry
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
        DB[:conn].execute(sql)
    end

    def self.find_by(attribute)
        value = attribute.values.first
        f_value = value.class == Integer ? value : "'#{value}'"
        sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first} = #{f_value}"
        DB[:conn].execute(sql)
    end
end