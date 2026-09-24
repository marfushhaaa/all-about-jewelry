module CoursesHelper
   def course_date(date)
      date ? l(date, format: :short) : "keine"
   end
end
