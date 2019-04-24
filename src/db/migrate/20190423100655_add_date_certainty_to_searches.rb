class AddDateCertaintyToSearches < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :date_certainty, :string, default: 'high'
  end
end
