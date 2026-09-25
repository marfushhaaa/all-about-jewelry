# AllAroundJewelry

AllAroundJewelry ist eine Web-Applikation, die Schmuck-Macherinnen und Interessierte verbindet. Schmuckersteller bieten Kurse an, Benutzer buchen und stornieren diese Kurse. Ein Kurs kann nie überbucht werden. Ein Admin verwaltet die Benutzer und sieht ein Aktivitätsprotokoll.

Projektarbeit Modul 223. Problemstellung, Anforderungen, Rollen, ERM, Breadboards, Locking-Konzept, Abweichungen und Testergebnisse stehen in der Projektdokumentation: **[docs/documentation.md](docs/documentation.md)**.

## Technologie-Stack

| Komponente | Version |
|---|---|
| Ruby | 4.0.6 |
| Ruby on Rails | 8.1.3.1 |
| Bundler | 4.0.21 |
| Datenbank | SQLite 3 (Gem `sqlite3` 2.9.6) |
| Webserver | Puma 8.0.2 |
| Autorisierung | Pundit 2.5.2 |
| Aktivitätsprotokoll | audited 5.8.0 |
| Passwort-Hashing | bcrypt 3.1.22 (`has_secure_password`) |
| Tests | Minitest (Rails-Standard) |

Die genauen Versionen aller Gems stehen in `Gemfile.lock`. Node.js oder ein JavaScript-Build sind **nicht** nötig.

## Voraussetzungen

* **Ruby 4.0.6**, z. B. installiert über [mise](https://mise.jdx.dev), rbenv oder asdf. Die Version wird aus `.ruby-version` gelesen.
* **Bundler 4.0.21**: `gem install bundler -v 4.0.21`
* **Build-Werkzeuge** für native Gems (bcrypt, sqlite3), z. B. unter Ubuntu/WSL: `sudo apt install build-essential libyaml-dev`
* **Git**
* Ein aktueller Browser (Chrome, Firefox, Edge, Safari). Ältere Browser werden von der App bewusst abgewiesen (`allow_browser versions: :modern`).

## Installation und Konfiguration

```bash
git clone https://github.com/marfushhaaa/all-about-jewelry.git AllAroundJewelry
cd AllAroundJewelry

ruby -v            # muss 4.0.6 anzeigen
bundle install
```

## Datenbank und Demo-Daten

```bash
bin/rails db:prepare
```

`db:prepare` erstellt `storage/development.sqlite3`, lädt das Schema (`db/schema.rb`) und bei einer neuen Datenbank automatisch auch die Demo-Daten aus `db/seeds.rb`. Existiert die Datenbank schon, lassen sich die Demo-Daten nachladen:

```bash
bin/rails db:seed
```

Um alles zurückzusetzen (Datenbank löschen, neu aufbauen, Seeds laden):

```bash
bin/rails db:reset
```

Die Demo-Daten enthalten 4 Benutzer, 4 Kurse (einer davon ausgebucht) sowie eine bestätigte und eine stornierte Buchung.

## Starten

```bash
bin/dev # oder bin/rails server
```

Die App läuft danach unter **http://localhost:3000**.

**Passwort zurücksetzen**: Das link wird in der Console geschrieben, und kann später im Browser geöffnet.

## Tests

```bash
bin/rails test                                   # alle Tests
bin/rails test test/models/booking_service_test.rb   # eine Datei
bin/rails test test/models/booking_service_test.rb:4 # ein einzelner Test (Zeilennummer)
```

Die Testdatenbank wird automatisch aus den Fixtures in `test/fixtures/` aufgebaut. Die Demo-Daten werden dafür nicht gebraucht. Erwartetes Ergebnis: alle Tests grün (`0 failures, 0 errors`).

| Ordner | Inhalt |
|---|---|
| `test/models/` | Fachregel Buchung (`BookingService`: letzter Platz, voller Kurs, Neubuchung nach Stornierung, Rollback), Validierungen |
| `test/policies/` | Berechtigungen aller Rollen inkl. Gast |
| `test/controllers/` | Jede Controller-Action mit erlaubtem und verweigertem Zugriff |
| `test/integration/` | Abläufe, direkte Requests auf fremde Datensätze, Aktivitätsprotokoll |

Code-Stil prüfen (rubocop-rails-omakase):

```bash
bin/rubocop
```

## Demo-Konten

Alle Demo-Konten haben das Passwort **`passwort123`**. Angemeldet wird mit dem **Benutzernamen**, nicht mit der E-Mail-Adresse.

| Benutzername | Rolle | Was man damit ausprobieren kann |
|---|---|---|
| `mia` | Schmuckersteller | Eigene Kurse erstellen, bearbeiten, löschen. Hat „Perlenarmband für Anfänger“ und den ausgebuchten Kurs „Harzanhänger mit Trockenblumen“ |
| `lena` | Schmuckersteller | Zweiter Schmuckersteller für Zugriffe auf fremde Kurse. Hat den Harz-Kurs von Mia gebucht |
| `anna` | Benutzer | Kurse buchen und stornieren. Hat einen Kurs gebucht und eine stornierte Buchung, die sich neu buchen lässt |
| `admin` | Benutzer + Admin | Benutzerverwaltung und Aktivitätsprotokoll unter `/admin/users`. Darf fremde Kurse bearbeiten und löschen |

Welche Rolle was darf, steht in der Berechtigungstabelle in [docs/documentation.md](docs/documentation.md).

## Projektstruktur (Auszug)

```
app/models/booking_service.rb   Buchung mit Transaktion und Locking
app/policies/                   Pundit-Policies (Berechtigungen)
app/controllers/                Controller, admin/ für die Benutzerverwaltung
app/views/                      ERB-Views
app/assets/stylesheets/         CSS (design.css)
db/schema.rb, db/seeds.rb       Datenbankschema und Demo-Daten
docs/                           Projektdokumentation, ERM, Breadboards, Screens
designs/                        Design-Entwürfe
test/                           Automatisierte Tests
```

## Häufige Probleme

| Problem | Lösung |
|---|---|
| `Your Ruby version is …, but your Gemfile specified 4.0.6` | Ruby 4.0.6 installieren und aktivieren (`mise install` bzw. `rbenv install`) |
| `bundle install` scheitert bei `bcrypt` oder `psych` | Build-Werkzeuge installieren: `sudo apt install build-essential libyaml-dev` |
| Anmeldung schlägt fehl | Mit dem Benutzernamen (z. B. `anna`) anmelden, nicht mit der E-Mail-Adresse. Demo-Daten geladen? (`bin/rails db:seed`) |
| Port 3000 belegt | `bin/dev -p 3001` |
