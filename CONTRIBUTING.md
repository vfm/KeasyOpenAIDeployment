# Beitrag zu KeasyOpenAIDeployment

## Übersicht

Vielen Dank für Ihr Interesse, zu diesem Projekt beizutragen! Dieses Repository enthält die **Dokumentation zur Keasy-KI-Einrichtung in Azure** (Nutzer-Anleitung und technische Deployment-Anleitung). Die eigentliche Einrichtung erfolgt über den **Einrichtungsassistenten** ([keasyki-onboarding.azurewebsites.net](https://keasyki-onboarding.azurewebsites.net)), der separat entwickelt wird — Beiträge hier betreffen daher in erster Linie die Dokumentation.

## Wie kann ich beitragen?

### 🐛 Fehler melden
Wenn Sie einen Fehler gefunden haben (veraltete Angabe, falscher Wert, toter Link, Problem im Einrichtungsassistenten):
1. Überprüfen Sie die [Issues](../../issues), ob der Fehler bereits gemeldet wurde
2. Erstellen Sie ein neues Issue mit detaillierter Beschreibung
3. Bei Problemen im Assistenten: Fehlermeldungen haben dort einen **„Kopieren"-Button** — bitte den kopierten Text vollständig ins Issue einfügen (er enthält Aktion, HTTP-Status und Azure-Fehlercode, aber keine Geheimnisse)

### 💡 Verbesserungen vorschlagen
Für neue Inhalte oder Änderungen am Einrichtungsweg:
1. Erstellen Sie ein Issue zur Diskussion der Idee
2. Warten Sie auf Feedback, bevor Sie mit der Umsetzung beginnen
3. Funktionswünsche zum Einrichtungsassistenten selbst werden ebenfalls per Issue gesammelt und intern umgesetzt

### 📝 Dokumentation verbessern
- Korrekturen an `README.md` / `KeasyKIDeployment.md` (Nutzer-Anleitung)
- Korrekturen an `Deployment_Guide.md` (technische Anleitung)
- Aktualisierung von Modellnamen, Kapazitäten, API-Versionen und Links, wenn sich Azure weiterentwickelt

## Pull Request Prozess

1. **Fork** des Repositories erstellen
2. **Branch** für Ihre Änderungen erstellen:
   ```bash
   git checkout -b docs/beschreibung-ihrer-aenderung
   ```
3. **Änderungen** vornehmen und inhaltlich prüfen (siehe Prüf-Prozess unten)
4. **Commit** mit aussagekräftiger Nachricht:
   ```bash
   git commit -m "Beschreibung der Änderung"
   ```
5. **Push** zu Ihrem Fork:
   ```bash
   git push origin docs/beschreibung-ihrer-aenderung
   ```
6. **Pull Request** erstellen

## Inhaltliche Änderungen an den Anleitungen

### Wichtige Überlegungen:
- ✅ Der beschriebene Weg muss zum **aktuellen Stand des Einrichtungsassistenten** passen (Foundry-Ressource `kind: AIServices`, `gpt-5.4` als Standard, `mistral-document-ai-2512` für OCR)
- ✅ Kapazitäts-Angaben aktuell halten (GPT: 100 = 100.000 Tokens/Min; Mistral-OCR: 40 Anforderungen/Min = Azure-Maximum)
- ✅ Der OCR-Endpoint muss immer mit dem Pflicht-Pfad `/providers/mistral/azure/ocr` dokumentiert sein
- ✅ EU-DSGVO-Compliance beachten (Region `germanywestcentral`, SKU `DataZoneStandard`)
- ✅ Keine konkreten Preise in die Dokumente schreiben — immer auf die offizielle Azure-Preisliste verlinken (Preise ändern sich)
- ✅ Keine API-Schlüssel, Tenant-IDs oder andere echte Kundendaten in Beispielen verwenden

### Prüf-Prozess:
1. Angaben gegen den Einrichtungsassistenten bzw. das Azure-Portal verifizieren (Testmodus des Assistenten: `?test` an die URL anhängen — spielt alle Schritte ohne Azure-Aufrufe durch)
2. Technische Werte (API-Versionen, SKUs, Kapazitäten) gegen die `Deployment_Guide.md` und die offizielle Azure-Dokumentation abgleichen
3. Alle Links prüfen

## Dokumentations-Standards

### Nutzer-Anleitung (README / KeasyKIDeployment):
- Deutsche Sprache, Anrede „Sie"
- Zielgruppe sind **Keasy-Anwender ohne Azure-Vorwissen** — kein unerklärter Technik-Jargon (TPM/RPM immer in Klartext erläutern)
- Klare, schrittweise Anleitungen mit realistischen Beispielwerten (`foundry-mustermann`)

### Technische Anleitung (Deployment_Guide):
- Zielgruppe Administratoren — REST-/CLI-Beispiele erwünscht
- API-Versionen explizit angeben und bei Änderungen konsistent im ganzen Dokument aktualisieren

## Bewertungskriterien

Pull Requests werden auf folgende Kriterien geprüft:

### ✅ Korrektheit
- Beschriebener Ablauf entspricht dem aktuellen Assistenten und Azure-Stand
- Werte (Modelle, Kapazitäten, Endpunkte, Rollen) sind verifiziert
- Keasy-Integration bleibt korrekt beschrieben (insb. OCR-Endpoint-Pfad)

### ✅ Qualität
- Verständlich für die jeweilige Zielgruppe
- Dokumente bleiben untereinander konsistent (Nutzer- und Admin-Anleitung)
- Keine unnötigen Dateien

### ✅ Compliance & Sicherheit
- DSGVO-konforme Regionen und EU-Datenzone
- Keine Geheimnisse oder echten Kundendaten in Beispielen
- Sicherheitshinweise (Schlüssel-Umgang) bleiben erhalten

## Kommunikation

- **Sprache**: Deutsch bevorzugt, Englisch akzeptiert
- **Ton**: Professionell und konstruktiv
- **Issues**: Detaillierte Beschreibungen mit Kontext (bei Assistenten-Fehlern: kopierte Fehlermeldung anhängen)

## Lizenz

Durch das Einreichen von Beiträgen stimmen Sie zu, dass Ihre Arbeit unter derselben Lizenz wie das Projekt veröffentlicht wird.

## Fragen?

Bei Fragen können Sie:
- Ein Issue erstellen
- Den Projekt-Maintainer kontaktieren
- Bei Keasy-Anwendungsfragen: [support.keasy.de](https://support.keasy.de/ticket/add)

Vielen Dank für Ihren Beitrag! 🚀
