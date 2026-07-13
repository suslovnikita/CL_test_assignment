class AddRouteSearchIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    add_index :segments,
      [ :airline, :origin_iata, :destination_iata, :std ],
      name: :index_segments_on_route_search_idx,
      algorithm: :concurrently

    add_index :permitted_routes,
      [ :carrier, :origin_iata, :destination_iata ],
      name: :index_permitted_routes_on_route_lookup_idx,
      unique: true,
      algorithm: :concurrently
  end
end
