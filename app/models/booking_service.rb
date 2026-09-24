class BookingService
  class CourseFull < StandardError; end

  def self.book!(course, user)
    Course.transaction do
      course.lock!                            # SELECT ... FOR UPDATE
      raise CourseFull if course.full?

      existing = Booking.find_by(course: course, user: user)
      if existing
        existing.update!(status: "confirmed") # blockiert "den letzten Request, die Transaktion"
        existing
      else
        Booking.create!(course: course, user: user, status: "confirmed")
      end
    end
  end
end