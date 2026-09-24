module AuditsHelper
  def audit_sentence(audit)
   case audit.action
   when "create"  then "hat #{audit_label(audit)} erstellt"
   when "update"  then "hat #{audit_label(audit)} geändert: #{audit_fields(audit)}"
   when "destroy" then "hat #{audit_label(audit)} gelöscht"
   end
   end

   def audit_label(audit)
   changes = audit.audited_changes

   case audit.auditable_type
   when "Course"
      name = changes["name"]
      name = name.last if name.is_a?(Array)         # bei update: [alt, neu]
      name ||= audit.auditable&.name
      name ? "den Kurs „#{name}“" : "einen Kurs"
   when "Booking"
        id = changes["course_id"]
         id = id.last if id.is_a?(Array)
         course = Course.find_by(id: id)
         course ? "eine Buchung für „#{course.name}“" : "eine Buchung"
   else
      audit.auditable_type
   end
   end

  def audit_fields(audit)
    audit.audited_changes.map { |field, (old, new)| "#{field}: #{old} → #{new}" }.join(", ")
  end
end