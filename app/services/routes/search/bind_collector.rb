# frozen_string_literal: true

module Routes
  class Search
    # @api private
    class BindCollector
      Bind = Data.define(:name, :value, :type) do
        def to_query_attribute
          ActiveRecord::Relation::QueryAttribute.new(name, value, type)
        end
      end

      attr_reader :binds

      def initialize
        @binds = []
        @indexes = {}
      end

      # @param name [String, Symbol]
      # @param value [Object]
      # @param type [ActiveModel::Type::Value]
      # @return [String]
      def add(name, value, type:)
        key = name.to_s
        index = indexes[key]
        bind = Bind.new(name: key, value:, type:)

        if index
          validate_same_bind!(binds.fetch(index), bind)
        else
          binds << bind
          index = binds.length - 1
          indexes[key] = index
        end

        "$#{index + 1}"
      end

      # @return [Array<ActiveRecord::Relation::QueryAttribute>]
      def query_attributes
        binds.map(&:to_query_attribute)
      end

      private

      attr_reader :indexes

      def validate_same_bind!(existing_bind, new_bind)
        return if existing_bind == new_bind

        raise ArgumentError, "Bind #{new_bind.name.inspect} is already registered with different attributes"
      end
    end
  end
end
