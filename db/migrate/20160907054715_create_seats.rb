class CreateSeats < ActiveRecord::Migration
  def change
    create_table :seats do |t|
      t.string :num
      t.string :area
      t.string :status

      t.timestamps null: false
    end
  end
end
