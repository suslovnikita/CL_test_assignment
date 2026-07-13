# frozen_string_literal: true

module Routes
  class Search
    # @api private
    class RouteQuery
      # @param segment_model [Class]
      # @param bind_collector [#new]
      def initialize(segment_model: Segment, bind_collector: BindCollector)
        @segment_model = segment_model
        @bind_collector = bind_collector
      end

      # @param carrier [String]
      # @param legs_group [Array<Array<Array<String>>>]
      # @param departure_window [Range]
      # @return [Array<Array<Segment>>]
      def call(carrier:, legs_group:, departure_window:)
        table_aliases = aliases(legs_group.first.length)
        query_binds = bind_collector.new
        query_sql = raw_sql(legs_group, carrier:, departure_window:, table_aliases:, bind_collector: query_binds)

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

      attr_reader :segment_model, :bind_collector

      def raw_sql(legs_group, carrier:, departure_window:, table_aliases:, bind_collector:)
        # Один self-join покрывает все разрешенные схемы с одинаковым числом плеч.
        <<~SQL.squish
          SELECT #{select_clause(table_aliases)}
          FROM #{quoted_table_name} #{table_aliases.first}
          #{join_clause(table_aliases)}
          WHERE #{where_clause(legs_group, carrier:, departure_window:, table_aliases:, bind_collector:)}
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

      def join_clause(table_aliases)
        joins_sql = +""

        table_aliases.each_cons(2) do |(previous_alias, current_alias)|
          joins_sql << " " unless joins_sql.empty?
          joins_sql << <<~SQL.squish
            JOIN #{quoted_table_name} #{current_alias}
              ON #{current_alias}.std BETWEEN #{previous_alias}.sta + INTERVAL '8 hours'
                                          AND #{previous_alias}.sta + INTERVAL '48 hours'
          SQL
        end

        joins_sql
      end

      def where_clause(legs_group, carrier:, departure_window:, table_aliases:, bind_collector:)
        first_alias = table_aliases.first

        <<~SQL.squish
          #{carrier_clause(table_aliases, carrier:, bind_collector:)}
          AND #{first_alias}.std BETWEEN #{bind_collector.add(:departure_from, departure_window.begin, model: segment_model, column_name: "std")}
                                    AND #{bind_collector.add(:departure_to, departure_window.end, model: segment_model, column_name: "std")}
          AND (#{route_match_clause(legs_group, table_aliases:, bind_collector:)})
        SQL
      end

      def carrier_clause(table_aliases, carrier:, bind_collector:)
        carrier_sql = +""

        table_aliases.each do |table_alias|
          carrier_sql << " AND " unless carrier_sql.empty?
          carrier_sql << "#{table_alias}.airline = #{bind_collector.add("#{table_alias}_airline", carrier, model: segment_model, column_name: "airline")}"
        end

        carrier_sql
      end

      def route_match_clause(legs_group, table_aliases:, bind_collector:)
        routes_sql = +""

        legs_group.each.with_index(1) do |legs, route_index|
          routes_sql << " OR " unless routes_sql.empty?
          routes_sql << route_conditions(legs, table_aliases:, route_index:, bind_collector:)
        end

        routes_sql
      end

      def route_conditions(legs, table_aliases:, route_index:, bind_collector:)
        conditions_sql = +""

        legs.each.with_index do |(origin_iata, destination_iata), index|
          table_alias = table_aliases.fetch(index)
          leg_index = index + 1

          conditions_sql << " AND " unless conditions_sql.empty?
          conditions_sql << <<~SQL.squish
            #{table_alias}.origin_iata = #{bind_collector.add("route#{route_index}_s#{leg_index}_origin_iata", origin_iata, model: segment_model, column_name: "origin_iata")}
            AND #{table_alias}.destination_iata = #{bind_collector.add("route#{route_index}_s#{leg_index}_destination_iata", destination_iata, model: segment_model, column_name: "destination_iata")}
          SQL
        end

        "(#{conditions_sql})"
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
