# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Demo-Daten für AllAroundJewelry. Mehrfaches Ausführen legt keine Duplikate an.
DEMO_PASSWORD = "passwort123"

def demo_user(username, role:, admin: false)
  User.find_or_create_by!(username: username) do |user|
    user.email_address = "#{username}@example.com"
    user.password = DEMO_PASSWORD
    user.role = role
    user.admin = admin
  end
end

mia   = demo_user("mia",   role: "creator")
lena  = demo_user("lena",  role: "creator")
anna  = demo_user("anna",  role: "user")
demo_user("admin", role: "user", admin: true)

def demo_course(creator, name, description:, starts_in:, hours:, max:)
  start = starts_in.from_now.change(hour: 14)
  creator.courses.find_or_create_by!(name: name) do |course|
    course.description = description
    course.start_date = start
    course.end_date = start + hours.hours
    course.max_participants = max
  end
end

perlen = demo_course(mia, "Perlenarmband für Anfänger",
  description: "Lerne, dein erstes Perlenarmband zu gestalten! Wir verwenden Glasperlen, Samenperlen und Miyuki-Delicas.",
  starts_in: 3.weeks, hours: 3, max: 12)

draht = demo_course(lena, "Drahtring wickeln – Grundkurs",
  description: "In diesem Kurs lernst du die Grundtechnik des Drahtwickelns. Wir erstellen gemeinsam einen Ring.",
  starts_in: 4.weeks, hours: 4, max: 8)

harz = demo_course(mia, "Harzanhänger mit Trockenblumen",
  description: "Erstelle wunderschöne Harzanhänger mit gepressten Wildblumen und Blütenblättern.",
  starts_in: 6.weeks, hours: 2, max: 1)

demo_course(lena, "Makramee-Ohrringe",
  description: "Knüpfe leichte Ohrringe aus Baumwollgarn. Keine Vorkenntnisse nötig.",
  starts_in: 8.weeks, hours: 3, max: 6)

# Buchungen: Anna hat einen Kurs gebucht, der Harz-Kurs ist durch Lena ausgebucht,
# und eine stornierte Buchung zeigt die Neubuchung nach Storno.
Booking.find_or_create_by!(user: anna, course: perlen) { |b| b.status = "confirmed" }
Booking.find_or_create_by!(user: lena, course: harz)   { |b| b.status = "confirmed" }
Booking.find_or_create_by!(user: anna, course: draht)  { |b| b.status = "cancelled" }

puts "Demo-Daten: #{User.count} Benutzer, #{Course.count} Kurse, #{Booking.count} Buchungen."
