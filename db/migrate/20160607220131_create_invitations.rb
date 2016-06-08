class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :inviter_id
      t.text :message
      t.string :recipient_email, :recipient_name
    end
  end
end
