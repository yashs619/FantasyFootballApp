class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :owner
      t.integer :teamNumber
      t.integer :finalRank
      t.timestamps null: false
    end
  end
end
