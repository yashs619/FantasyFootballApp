class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name
      t.string :posInfo
      t.integer :rank
      t.references :team
      t.timestamps null: false
    end
  end
end
