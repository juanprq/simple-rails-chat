class CreateAgents < ActiveRecord::Migration
  def change
    create_table :agents do |t|
      t.string :name
      t.string :phone
      t.integer :company_id

      t.timestamps null: false
    end
  end
end
