class Course < ApplicationRecord
  audited
  
  belongs_to :creator, class_name: "User"
  has_many :bookings, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }
  validates :max_participants, numericality: { greater_than: 0 }, allow_nil: true
  validate :end_after_start

  # app/models/course.rb
  def confirmed_bookings
    bookings.where(status: "confirmed")
  end

  def free_places
    return Float::INFINITY if max_participants.nil?
    max_participants - confirmed_bookings.count
  end

  def full?
    max_participants.present? && confirmed_bookings.count >= max_participants
  end

  def bookable_by?(user)
    user.present? && creator_id != user.id && !full? &&
      !confirmed_bookings.exists?(user_id: user.id)
  end

  private

  def end_after_start
    return if start_date.blank? || end_date.blank?
    errors.add(:end_date, "muss nach dem Start liegen") if end_date <= start_date
  end
end
