# Keasy KI in Azure einrichten

## Überblick

Die KI-Funktionen von [Keasy](https://www.keasy.de) laufen auf **Azure-KI-Ressourcen in Ihrem eigenen Microsoft-Kunden-Tenant** — nicht bei Keasy und nicht bei einem Drittanbieter. Ihre Daten bleiben damit in Ihrer eigenen Azure-Umgebung, und die KI-Nutzung wird direkt über Ihr eigenes Azure-Abonnement abgerechnet.

Benötigt wird eine **KI-Ressource** mit zwei Modellen: ein **Sprachmodell** (für Texte, Zusammenfassungen und KI-Assistenz) und ein **OCR-Modell** (für das Auslesen von Dokumenten). Der Einrichtungsassistent erledigt das komplett für Sie — alternativ finden Sie weiter unten die [manuelle Anleitung](#%EF%B8%8F-alternative-manuelle-einrichtung-im-azure-portal).

## 📋 Voraussetzungen

- Ein eigener **Microsoft-Tenant** (Microsoft 365 / Entra ID) und darin ein aktives **Azure-Abonnement** (Subscription)
- **Berechtigungen auf dem Abonnement:**
  - **Für den Assistenten:** Anmeldung als **Global Administrator** Ihres Tenants genügt — fehlende Azure-Berechtigungen richtet der Assistent auf Knopfdruck selbst ein
  - **Für die manuelle Einrichtung:** mindestens die Azure-Rolle **„Mitwirkender" (Contributor)** auf dem Abonnement oder der Ressourcengruppe; empfohlen ist **„Besitzer" (Owner)** — die brauchen Sie, wenn Sie zusätzlich Berechtigungen vergeben oder eine bestehende Azure-OpenAI-Ressource auf Foundry aktualisieren möchten
- Zugang zu Ihrer Keasy-Installation, um die Zugangsdaten zu hinterlegen

> **Wichtig:** Ein Microsoft-365-Administrator hat nicht automatisch Azure-Rechte — „Global Administrator" (Entra) und Azure-Rollen wie „Besitzer"/„Mitwirkender" sind zwei getrennte Dinge. Der Assistent erkennt fehlende Azure-Rechte und behebt das automatisch; manuell vergeben Sie die Rolle im Azure-Portal unter *Abonnement → Zugriffssteuerung (IAM) → Rollenzuweisung hinzufügen*.

## 🚀 So richten Sie die KI ein

**➡️ [https://keasyki-onboarding.azurewebsites.net](https://keasyki-onboarding.azurewebsites.net)**
Achtung: Die Seite kann beim ersten Laden bis zu einer Minute Wartezeit haben.

Der Assistent führt Sie in 5 Schritten durch die Einrichtung:

1. **Anmelden** — mit Ihrem Microsoft-Administrator-Konto (Global Administrator)
2. **Bestätigen** — Ihre Firma (Tenant) wird automatisch erkannt
3. **Konfigurieren** — Azure-Abonnement wählen. Der Assistent prüft, ob bereits eine KI-Ressource existiert. Fehlen Ihrem Konto Berechtigungen auf dem Abonnement, erkennt der Assistent das und richtet sie auf Knopfdruck automatisch ein
4. **AI einrichten** — Ressource und Modelle werden angelegt. Ist schon etwas vorhanden, wird es weiterverwendet: Bereits vorhandene Modelle werden erkannt und übersprungen, eine ältere Azure-OpenAI-Ressource wird automatisch aktualisiert (dauert ca. 2 Minuten, alle bestehenden Zugänge bleiben erhalten)
5. **Fertig** — Sie erhalten alle Zugangsdaten zum Kopieren und die Datei **`Setup-KeasyOpenAI.cmd`**, die alles automatisch in Keasy einträgt

> **Tipp:** Die Zugangsdaten lassen sich jederzeit erneut abrufen — im Assistenten die bestehende Ressource auswählen und **„Nur Daten auslesen"** klicken. Dabei wird nichts verändert.

## 📦 Was wird in Azure angelegt — und warum

| Was | Warum |
|---|---|
| **KI-Ressource** (Azure AI Foundry, z. B. `foundry-mustermann`) | Das „Konto", auf dem die KI-Modelle laufen — in der Azure-Region Deutschland (`germanywestcentral`). Es wird bewusst der neuere Typ **AI Foundry** verwendet, weil nur dieser das OCR-Modell für die Dokumentenerkennung unterstützt |
| **Projektordner** (wird automatisch mit angelegt) | Azure verlangt für Foundry-Ressourcen einen Projektordner — der Assistent legt ihn mit dem empfohlenen Standardnamen an, Sie müssen nichts tun |
| **Sprachmodell `gpt-5.4`** | Erledigt die Text-KI-Funktionen in Keasy. `gpt-5.4` ist der bewährte Standard; alternativ gibt es `gpt-5.6-terra/-sol/-luna` — **Terra liefert die besten Ergebnisse**, verursacht aber höhere KI-Kosten |
| **OCR-Modell `mistral-document-ai-2512`** (empfohlen) | Liest Dokumente per KI aus (Keasy-OCR). Läuft auf derselben Ressource und nutzt denselben Schlüssel — es entstehen nur Kosten bei tatsächlicher Nutzung |

## ⚙️ Empfohlene Standard-Werte

Diese Werte sind im Assistenten bereits voreingestellt und für den normalen Keasy-Betrieb ausgelegt:

| Modell | Voreinstellung | Was bedeutet das? |
|---|---|---|
| `gpt-5.4` | **100** (= 100.000 Tokens pro Minute) | Wie viel Text die KI pro Minute verarbeiten darf. 100 ist der empfohlene Wert — ältere Einrichtungen mit weniger schlägt der Assistent automatisch zur Erhöhung vor |
| `mistral-document-ai-2512` | **40** (= 40 Anfragen pro Minute) | Wie viele Dokument-Anfragen pro Minute möglich sind. 40 ist das von Azure erlaubte Maximum und sollte so übernommen werden |

## 🔧 Diese Werte braucht Keasy

Am einfachsten: Die heruntergeladene **`Setup-KeasyOpenAI.cmd`** auf dem Keasy-Rechner per Rechtsklick **„Als Administrator ausführen"** — sie trägt alle Werte automatisch und sicher verschlüsselt in Keasy ein.

Falls Sie die Werte manuell eintragen möchten, zeigt die Abschlussseite des Assistenten alles zum Kopieren:

| Wert | Beispiel |
|---|---|
| **Endpoint-URL** | `https://foundry-mustermann.cognitiveservices.azure.com/` |
| **API-Schlüssel** | *(geheim halten — gilt für Sprachmodell **und** OCR)* |
| **Deployment-Name** | `gpt-5.4` |
| **OCR-Endpoint** | `https://foundry-mustermann.services.ai.azure.com/providers/mistral/azure/ocr` — **der Teil `/providers/mistral/azure/ocr` muss enthalten sein!** |
| **OCR-Modell** | `mistral-document-ai-2512` |

## 🛠️ Alternative: Manuelle Einrichtung im Azure-Portal

Wenn Sie den Assistenten nicht nutzen möchten, legen Sie die Ressourcen so von Hand an (benötigt mindestens „Mitwirkender" auf dem Abonnement, siehe Voraussetzungen):

### 1. KI-Ressource (Azure AI Foundry) anlegen

1. [portal.azure.com](https://portal.azure.com) → **„Ressource erstellen"** → nach **„Azure AI Foundry"** suchen → **Erstellen**
2. Abonnement wählen, Ressourcengruppe anlegen (z. B. `rg-foundry-mustermann`)
3. Region: **Germany West Central** · Name: nur Kleinbuchstaben/Zahlen/Bindestriche, z. B. `foundry-mustermann` (der Name wird Teil Ihrer Endpoint-Adressen)
4. Den vorgeschlagenen **Standardprojekt-Namen** einfach übernehmen · Preisstufe: **Standard S0**
5. **„Überprüfen + erstellen"** → **„Erstellen"** — die Bereitstellung dauert wenige Minuten

> **Sie haben schon eine Ressource vom Typ „Azure OpenAI"?** Dann nichts neu anlegen: Öffnen Sie die Ressource im Azure-Portal und folgen Sie dem Banner **„Ressourcenupgrade"** (Upgrade auf Foundry, ca. 2 Minuten — Endpunkte, Schlüssel und Modelle bleiben erhalten). Ohne dieses Upgrade lässt sich das OCR-Modell nicht bereitstellen.

### 2. Sprachmodell bereitstellen

1. [ai.azure.com](https://ai.azure.com) (Azure AI Foundry Portal) öffnen → Ihre Ressource/Ihr Projekt auswählen
2. **Modellkatalog** → `gpt-5.4` suchen → **„Bereitstellen"**
3. Deployment-Name: `gpt-5.4` (so übernehmen — der Name wird in Keasy eingetragen)
4. Bereitstellungstyp: **Data Zone Standard** · Ratenlimit: **100K Tokens pro Minute**

### 3. OCR-Modell bereitstellen

1. Wieder **Modellkatalog** → `mistral-document-ai-2512` suchen → **„Bereitstellen"**
2. Deployment-Name: `mistral-document-ai-2512` · Bereitstellungstyp: **Data Zone Standard**
3. Ratenlimit: **40 Anforderungen pro Minute** (das Maximum — voreingestellt lassen)

### 4. Wo finden Sie die Werte für Keasy?

| Wert | Fundort |
|---|---|
| **Endpoint-URL** | Azure-Portal → Ihre KI-Ressource → **„Schlüssel und Endpunkt"** — die Adresse in der Form `https://<name>.cognitiveservices.azure.com/` |
| **API-Schlüssel** | Ebenfalls unter **„Schlüssel und Endpunkt"** → **Schlüssel 1** (oder Schlüssel 2 — beide gelten für Sprachmodell und OCR) |
| **Deployment-Name** | Foundry-Portal → **„Bereitstellungen"** — der exakte Name Ihres Sprachmodells, z. B. `gpt-5.4` |
| **OCR-Endpoint** | Foundry-Portal → Bereitstellung `mistral-document-ai-2512` öffnen → **Ziel-URI** — sie lautet `https://<name>.services.ai.azure.com/providers/mistral/azure/ocr` (der Pfad `/providers/mistral/azure/ocr` muss enthalten sein!) |
| **OCR-Modell** | Immer `mistral-document-ai-2512` |

Diese Werte tragen Sie anschließend in Keasy ein (siehe Tabelle oben). Der Assistent nimmt Ihnen genau diese Schritte ab und erzeugt zusätzlich die Setup-Datei — auch nachträglich: einfach anmelden, Ressource wählen und **„Nur Daten auslesen"**.

## 💡 Gut zu wissen

- **Sie haben schon eine Azure-OpenAI-Ressource?** Nicht löschen! Der Assistent verwendet sie weiter und ergänzt nur, was fehlt.
- **Ressource gelöscht und Name blockiert?** Azure reserviert den Namen einer gelöschten Ressource bis zu **48 Stunden**. In dieser Zeit einfach einen anderen Namen wählen oder warten — der Assistent weist darauf hin.
- **Kosten:** Die KI-Nutzung wird von Azure nach Verbrauch abgerechnet. Die Modelle Terra und Sol sind leistungsfähiger, aber teurer als GPT-5.4. Preise und die Auswertung Ihres eigenen Verbrauchs: siehe nächster Abschnitt.
- **Sicherheit:** Geben Sie Ihren API-Schlüssel niemals weiter.

## 💶 KI-Kosten: Preise nachlesen und eigenen Verbrauch auswerten

### Aktuelle Preise bei Microsoft

- **Offizielle Preisliste Azure OpenAI** (GPT-Modelle, Abrechnung je 1.000 Tokens): [azure.microsoft.com/de-de/pricing/details/cognitive-services/openai-service/](https://azure.microsoft.com/de-de/pricing/details/cognitive-services/openai-service/)
- **Azure-Preisrechner** zum Durchrechnen eigener Szenarien: [azure.microsoft.com/pricing/calculator/](https://azure.microsoft.com/de-de/pricing/calculator/)
- Der Preis eines Modells (auch des Mistral-OCR-Modells) wird zusätzlich **im Foundry-Portal direkt beim Bereitstellen** im Modellkatalog angezeigt.

### Eigene KI-Kosten in Azure auslesen

1. [portal.azure.com](https://portal.azure.com) → **„Abonnements"** → Ihr Abonnement öffnen
2. Im Menü links **„Kostenanalyse"** (Cost Management) wählen
3. Zeitraum wählen und nach Ihrer Ressourcengruppe (z. B. `rg-foundry-mustermann`) oder direkt nach der KI-Ressource filtern — so sehen Sie die reinen KI-Kosten getrennt von anderen Azure-Diensten, auf Wunsch nach Tagen oder Diensten aufgeschlüsselt

**Benötigte Berechtigungen:** Zum **Einsehen** der Kosten genügt auf dem Abonnement die Rolle **„Kostenverwaltungsleser" (Cost Management Reader)** oder **„Leser" (Reader)** — wer „Besitzer" oder „Mitwirkender" ist, hat den Zugriff automatisch. Die Rolle vergibt ein Besitzer unter *Abonnement → Zugriffssteuerung (IAM) → Rollenzuweisung hinzufügen*.

> **Tipp — Budget-Warnung:** Unter *Kostenverwaltung → Budgets* können Sie ein Monatsbudget mit E-Mail-Benachrichtigung anlegen (z. B. „warne mich bei 80 %"). Zum Anlegen ist mindestens **„Mitwirkender"** oder **„Kostenverwaltungsmitwirkender" (Cost Management Contributor)** auf dem Abonnement nötig — so bemerken Sie ungewöhnlichen KI-Verbrauch, bevor die Rechnung kommt.

## 🆘 Wenn etwas nicht klappt

| Meldung / Problem | Das hilft |
|---|---|
| „Keine Berechtigung auf diese Subscription" | Im Assistenten auf **„Berechtigungen automatisch einrichten"** klicken (Anmeldung als Global Administrator nötig) |
| „Modell schon vorhanden, wird übersprungen" | Kein Fehler — das Modell existiert bereits und wird einfach weiterverwendet |
| Name wird bei der Neuanlage abgelehnt | Der Name ist noch durch eine kürzlich gelöschte Ressource belegt (bis zu 48 h) — anderen Namen wählen oder warten |
| OCR funktioniert in Keasy nicht | Prüfen, ob der OCR-Endpoint mit `/providers/mistral/azure/ocr` endet — ohne diesen Teil funktioniert die Dokumentenerkennung nicht |
| Keasy meldet „Zugriff verweigert" | Endpoint-URL, API-Schlüssel und Deployment-Name noch einmal vergleichen (am besten frisch über „Nur Daten auslesen" holen) |
| Fehlermeldung im Assistenten | Jede Meldung hat einen **„Kopieren"-Button** — Text kopieren und an den Support senden |

## 📞 Support

Bei Fragen zur Keasy-Integration: [support.keasy.de](https://support.keasy.de/ticket/add)
