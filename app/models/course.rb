class Course < ApplicationRecord
  belongs_to :creator, class_name: "User"
  has_many :bookings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :max_participants, numericality: { greater_than: 0 }, allow_nil: true
  validate :end_after_start

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "muss nach dem Start liegen") if end_date <= start_date
  end
end
