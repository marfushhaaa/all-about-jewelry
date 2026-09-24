module AuditsHelper
  def audit_sentence(audit)
    was = audit.auditable_type == "Course" ? "den Kurs" : "eine Buchung"
    case audit.action
    when "create"  then "hat #{was} erstellt"
    when "update"  then "hat #{was} geändert: #{audit_fields(audit)}"
    when "destroy" then "hat #{was} gelöscht"
    end
  end

  def audit_fields(audit)
    audit.audited_changes.map { |field, (old, new)| "#{field}: #{old} → #{new}" }.join(", ")
  end
end