class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.decimal :value
      t.integer :week
      t.references :player
      t.timestamps null: false
    end
  end
end
