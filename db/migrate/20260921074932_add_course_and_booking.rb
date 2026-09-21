class AddCourseAndBooking < ActiveRecord::Migration[8.1]
  def change
    change_column_default :users, :role, from: nil, to: "user"
    change_column_null :users, :role, false, "user"
    change_column_default :bookings, :status, from: nil, to: "confirmed"
    change_column_null :bookings, :status, false, "confirmed"
  end
end
