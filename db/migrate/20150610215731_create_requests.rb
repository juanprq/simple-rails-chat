class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.string :name
      t.string :status
      t.string :token
      t.integer :organization_id

      t.timestamps null: false
    end
  end
end
