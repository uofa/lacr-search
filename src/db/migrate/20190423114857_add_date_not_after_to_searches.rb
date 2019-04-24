class AddDateNotAfterToSearches < ActiveRecord::Migration[5.2]
  def change
    add_column :searches, :date_not_after, :date
  end
end
