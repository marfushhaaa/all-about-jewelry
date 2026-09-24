# Anzeige-Helfer für das Design (deutsche Datumsangaben, Dauer, Avatare).
module DesignHelper
  DE_DAYS = %w[Sonntag Montag Dienstag Mittwoch Donnerstag Freitag Samstag].freeze
  DE_MONTHS = %w[Januar Februar März April Mai Juni Juli August September Oktober November Dezember].freeze

  # "Donnerstag, 15. Oktober 2026"
  def de_date(time)
    return "offen" if time.blank?
    "#{DE_DAYS[time.wday]}, #{time.day}. #{DE_MONTHS[time.month - 1]} #{time.year}"
  end

  # "15.10.2026, 14:00"
  def de_short(time)
    time.present? ? time.strftime("%d.%m.%Y, %H:%M") : "offen"
  end

  # "14:00"
  def de_time(time)
    time.present? ? time.strftime("%H:%M") : "–"
  end

  # "3 Stunden", "2.5 Stunden", "2 Tage"
  def course_duration(course)
    return "–" if course.start_date.blank? || course.end_date.blank?

    hours = (course.end_date - course.start_date) / 3600.0
    if hours >= 24
      days = (hours / 24).round
      days == 1 ? "1 Tag" : "#{days} Tage"
    else
      value = (hours % 1).zero? ? hours.to_i : hours.round(1)
      value == 1 ? "1 Stunde" : "#{value} Stunden"
    end
  end

  # "4/12 frei", "Ausgebucht", "Unbegrenzt"
  def places_short(course)
    return "Unbegrenzt" if course.max_participants.nil?
    course.full? ? "Ausgebucht" : "#{course.free_places}/#{course.max_participants} frei"
  end

  # Anteil der belegten Plätze in Prozent (für den Fortschrittsbalken)
  def occupancy_percent(course)
    return 0 if course.max_participants.to_i.zero?
    [ (course.confirmed_bookings.count * 100.0 / course.max_participants).round, 100 ].min
  end

  def avatar_initial(user)
    user&.username.to_s.first.to_s.upcase.presence || "?"
  end

  ICON_PATHS = {
    calendar: '<rect x="3" y="4" width="18" height="18" rx="2"/><path d="M16 2v4M8 2v4M3 10h18"/>',
    clock: '<circle cx="12" cy="12" r="10"/><path d="M12 6v6l4 2"/>',
    timer: '<circle cx="12" cy="13" r="8"/><path d="M12 9v4l2 2M9 2h6M12 2v3"/>',
    user: '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
    users: '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75"/>',
    flag: '<path d="M4 15s1-1 4-1 5 2 8 2 4-1 4-1V3s-1 1-4 1-5-2-8-2-4 1-4 1zM4 22v-7"/>',
    receipt: '<path d="M4 2v20l3-2 3 2 3-2 3 2 3-2 1 .7V2l-3 2-3-2-3 2-3-2-3 2z"/><path d="M8 9h8M8 13h6"/>',
    globe: '<circle cx="12" cy="12" r="10"/><path d="M2 12h20M12 2a15 15 0 0 1 0 20M12 2a15 15 0 0 0 0 20"/>',
    spark: '<path d="M12 2l2.4 7.4H22l-6.2 4.5 2.4 7.4-6.2-4.5-6.2 4.5 2.4-7.4L2 9.4h7.6z"/>',
    heart: '<path d="M20.8 4.6a5.5 5.5 0 0 0-7.8 0L12 5.7l-1-1.1a5.5 5.5 0 0 0-7.8 7.8L12 21l8.8-8.6a5.5 5.5 0 0 0 0-7.8z"/>',
    chat: '<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>',
    lock: '<rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/>',
    check: '<path d="M20 6L9 17l-5-5"/>',
    leaf: '<path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.5 19 2c1 2 2 4.2 2 8 0 5.5-4.8 10-10 10z"/><path d="M2 21c0-3 1.9-5.4 5.1-6"/>'
  }.freeze

  # Kleines Inline-SVG-Icon (unabhängig von Emoji-Schriften)
  def icon(name, css: "icon")
    tag.svg(ICON_PATHS.fetch(name).html_safe, class: css, viewBox: "0 0 24 24", fill: "none",
      stroke: "currentColor", "stroke-width": 2, "stroke-linecap": "round", "stroke-linejoin": "round",
      "aria-hidden": true)
  end

  # Wechselnde Platzhalter-Bilder (CSS-Muster), solange Kurse kein Bild haben
  def course_art_class(course)
    "art art-#{course.id.to_i % 4}"
  end
end
