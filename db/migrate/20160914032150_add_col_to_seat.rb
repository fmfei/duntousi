class AddColToSeat < ActiveRecord::Migration
  def change
    add_column :seats, :col, :string
    add_column :seats, :row, :string
  end
end
