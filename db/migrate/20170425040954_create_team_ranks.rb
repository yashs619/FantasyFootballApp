class CreateTeamRanks < ActiveRecord::Migration
  def change
    create_table :team_ranks do |t|
      t.integer :rank
      t.integer :week
      t.references :team
      t.timestamps null: false
    end
  end
end
