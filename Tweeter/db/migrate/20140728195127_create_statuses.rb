class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :text
      t.string :twitter_status_id
      t.string :twitter_user_id
    end

    add_index :statuses, :twitter_status_id, unique: true
    add_index :statuses, :twitter_user_id
  end
end
