class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :max_participants
      t.references :creator, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
