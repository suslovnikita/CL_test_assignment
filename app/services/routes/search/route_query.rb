# frozen_string_literal: true

module Routes
  class Search
    # @api private
    class RouteQuery
      # @param segment_model [Class]
      # @param binds_factory [#new]
      def initialize(segment_model: Segment, binds_factory: BindCollector)
        @segment_model = segment_model
        @binds_factory = binds_factory
      end

      # @param carrier [String]
      # @param legs_group [Array<Array<Array<String>>>]
      # @param departure_window [Range]
      # @return [Array<Array<Segment>>]
      def call(carrier:, legs_group:, departure_window:)
        table_aliases = aliases(legs_group.first.length)
        query_binds = binds_factory.new
        query_sql = raw_sql(legs_group, carrier:, departure_window:, table_aliases:, binds: query_binds)

        # Каждая строка результата содержит все плечи маршрута, выбранные через aliases s1, s2, ...
        segment_model.connection.exec_query(
          query_sql,
          "Routes::Search::RouteQuery",
          query_binds.query_attributes,
          prepare: true
        ).map do |row|
          table_aliases.map do |table_alias|
            segment_model.instantiate(segment_attributes(row, table_alias))
          end
        end
      end

      private

      attr_reader :segment_model, :binds_factory

      def raw_sql(legs_group, carrier:, departure_window:, table_aliases:, binds:)
        routes_sql = +""

        legs_group.each.with_index(1) do |legs, route_index|
          routes_sql << " UNION ALL " unless routes_sql.empty?
          routes_sql << route_sql(legs, route_index:, carrier:, departure_window:, table_aliases:, binds:)
        end

        routes_sql
      end

      def route_sql(legs, route_index:, carrier:, departure_window:, table_aliases:, binds:)
        # UNION ALL оставляет один round-trip на число плеч, но дает planner-у простые route-specific ветки.
        <<~SQL.squish
          SELECT #{select_clause(table_aliases)}
          FROM #{quoted_table_name} #{table_aliases.first}
          #{join_clause(legs, route_index:, carrier:, table_aliases:, binds:)}
          WHERE #{where_clause(legs, route_index:, carrier:, departure_window:, table_aliases:, binds:)}
        SQL
      end

      def select_clause(table_aliases)
        # Префикс alias нужен, чтобы восстановить отдельные Segment из одной строки результата.
        select_sql = +""

        table_aliases.each do |table_alias|
          column_names.each do |column_name|
            select_sql << ", " unless select_sql.empty?
            select_sql << "#{table_alias}.#{quote_column(column_name)} AS #{quote_column("#{table_alias}_#{column_name}")}"
          end
        end

        select_sql
      end

      def join_clause(legs, route_index:, carrier:, table_aliases:, binds:)
        joins_sql = +""

        table_aliases.each_cons(2).with_index(2) do |(previous_alias, current_alias), leg_index|
          source_alias = "#{current_alias}_source"
          joins_sql << " " unless joins_sql.empty?
          # OFFSET 0 не дает PostgreSQL расплющить LATERAL обратно в join с поздним Join Filter.
          joins_sql << <<~SQL.squish
            JOIN LATERAL (
              SELECT #{source_alias}.*
              FROM #{quoted_table_name} #{source_alias}
              WHERE #{leg_conditions(legs.fetch(leg_index - 1), source_alias, route_index:, leg_index:, carrier:, binds:)}
              AND #{source_alias}.std BETWEEN #{previous_alias}.sta + INTERVAL '8 hours'
                                          AND #{previous_alias}.sta + INTERVAL '48 hours'
              OFFSET 0
            ) #{current_alias} ON TRUE
          SQL
        end

        joins_sql
      end

      def where_clause(legs, route_index:, carrier:, departure_window:, table_aliases:, binds:)
        first_alias = table_aliases.first

        <<~SQL.squish
          #{leg_conditions(legs.first, first_alias, route_index:, leg_index: 1, carrier:, binds:)}
          AND #{first_alias}.std BETWEEN #{binds.add(:departure_from, departure_window.begin, type: attribute_type("std"))}
                                    AND #{binds.add(:departure_to, departure_window.end, type: attribute_type("std"))}
        SQL
      end

      def leg_conditions(leg, table_alias, route_index:, leg_index:, carrier:, binds:)
        origin_iata, destination_iata = leg

        <<~SQL.squish
          #{table_alias}.airline = #{binds.add("#{table_alias}_airline", carrier, type: attribute_type("airline"))}
          AND #{table_alias}.origin_iata = #{binds.add("route#{route_index}_s#{leg_index}_origin_iata", origin_iata, type: attribute_type("origin_iata"))}
          AND #{table_alias}.destination_iata = #{binds.add("route#{route_index}_s#{leg_index}_destination_iata", destination_iata, type: attribute_type("destination_iata"))}
        SQL
      end

      def attribute_type(column_name)
        segment_model.type_for_attribute(column_name)
      end

      def aliases(legs_count)
        Array.new(legs_count) { |index| "s#{index + 1}" }
      end

      def segment_attributes(row, table_alias)
        column_names.each_with_object({}) do |column_name, attributes|
          attributes[column_name] = row["#{table_alias}_#{column_name}"]
        end
      end

      def column_names
        @column_names ||= segment_model.column_names.freeze
      end

      def quoted_table_name
        segment_model.quoted_table_name
      end

      def quote_column(column_name)
        segment_model.connection.quote_column_name(column_name)
      end
    end
  end
end
