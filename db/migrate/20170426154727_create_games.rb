class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :opponent
      t.boolean :win
      t.decimal :myPoints
      t.decimal :oppPoints
      t.integer :week
      t.references :team
      t.timestamps null: false
    end
  end
end
