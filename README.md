# Keasy OpenAI Deployment

## Überblick

Dieses Repository stellt eine Azure Resource Manager (ARM) Vorlage zur Verfügung, mit der Nutzer der Maklerverwaltungssoftware [Keasy](https://www.keasy.de) einfach und schnell einen OpenAI-Service in Microsoft Azure bereitstellen können.

Nach der erfolgreichen Bereitstellung erhalten Sie alle notwendigen Zugangsdaten (URL, API-Schlüssel und Deployment-Name), die Sie anschließend in Keasy hinterlegen können, um die KI-Funktionen zu nutzen.

## 🚀 Schnell-Deployment

Klicken Sie auf den folgenden Button, um die OpenAI-Bereitstellung direkt in Azure zu starten:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvfm%2FKeasyOpenAIDeployment%2Frefs%2Fheads%2Fmain%2Fazuredeployopenai.json)

**Direkt-Link:** [Azure Deployment starten](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvfm%2FKeasyOpenAIDeployment%2Frefs%2Fheads%2Fmain%2Fazuredeployopenai.json)

## 📋 Voraussetzungen

- Ein aktives Microsoft Azure-Abonnement
- Berechtigung zur Erstellung von Cognitive Services-Ressourcen in Azure
- Zugang zur Keasy-Software, in der die OpenAI-Integration konfiguriert werden soll

## ⚙️ Konfigurationsparameter

Bei der Bereitstellung können Sie folgende Parameter anpassen:

| Parameter | Beschreibung | Standardwert | Hinweise |
|-----------|--------------|--------------|----------|
| **Region** | Azure-Region für die Bereitstellung | `germanywestcentral` |  |
| **Account Name** | Name Ihres OpenAI-Accounts | `openaiIHRMAKLERNAME` | Nur Kleinbuchstaben und Zahlen; wird Teil der Endpoint-URL |
| **Deployment Name** | Name des Modell-Deployments | `gpt-4o` | Wird in Keasy benötigt |
| **Modell** | OpenAI-Modell | `gpt-4o` | Verfügbar: gpt-4o, gpt-4o-mini |
| **Modell-Version** | Version des Modells | `2024-08-06` | Regionale Verfügbarkeit beachten |
| **Netzwerkzugang** | Öffentlicher Zugriff | `Enabled` | Für Keasy-Integration erforderlich |

## 📝 Schritt-für-Schritt-Anleitung

### 1. Azure-Deployment starten
1. Klicken Sie auf den [Deployment-Link](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fvfm%2FKeasyOpenAIDeployment%2Frefs%2Fheads%2Fmain%2Fazuredeployopenai.json)
2. Melden Sie sich bei Azure an, falls erforderlich
3. Wählen Sie Ihr Abonnement und eine Ressourcengruppe aus (oder erstellen Sie eine neue)

### 2. Parameter konfigurieren
1. Passen Sie den **Account Name** an (z.B. `openaimustermann` für Herr Mustermann)
2. Belassen Sie die anderen Parameter bei den Standardwerten oder passen Sie sie nach Bedarf an
3. Überprüfen Sie die Geschäftsbedingungen und akzeptieren Sie diese

### 3. Deployment ausführen
1. Klicken Sie auf "Überprüfen + erstellen"
2. Nach der Validierung klicken Sie auf "Erstellen"
3. Warten Sie, bis die Bereitstellung abgeschlossen ist (ca. 2-5 Minuten)

### 4. Zugangsdaten abrufen

Nach erfolgreichem Deployment finden Sie die wichtigen Informationen:

#### Endpoint-URL
- Gehen Sie zu Ihrer erstellten Cognitive Services-Ressource
- Kopieren Sie die **Endpoint-URL** aus dem Überblick

#### API-Schlüssel
- In der Ressource: Gehen Sie zu "Schlüssel und Endpunkt"
- Kopieren Sie **Schlüssel 1** oder **Schlüssel 2**

#### Deployment-Name
- Der Name, den Sie bei der Bereitstellung festgelegt haben (Standard: `gpt-4o`)

## 🔧 Keasy-Konfiguration

Mit den erhaltenen Daten können Sie nun Keasy konfigurieren:

1. **URL**: Die Endpoint-URL aus Azure (z.B. `https://openaimustermann.openai.azure.com/`)
2. **Secret/API-Key**: Der kopierte API-Schlüssel
3. **Deployment-Name**: Der Name Ihres Deployments (z.B. `gpt-4o`)

Tragen Sie diese Werte in den entsprechenden Feldern in Keasy ein.

## 💡 Tipps und Hinweise

- **Kosten**: Beachten Sie, dass für die Nutzung von Azure OpenAI Kosten anfallen
- **Regionen**: GPT-4o ist aktuell nur in wenigen EU-Regionen verfügbar
- **Sicherheit**: Teilen Sie Ihren API-Schlüssel niemals öffentlich
- **Updates**: Prüfen Sie regelmäßig auf Modell-Updates und neue Versionen

## 🆘 Fehlerbehebung

### Häufige Probleme:

**"Deployment fehlgeschlagen"**
- Überprüfen Sie, ob Ihr Azure-Abonnement Berechtigung für Cognitive Services hat
- Stellen Sie sicher, dass die gewählte Region OpenAI unterstützt

**"Modell nicht verfügbar"**
- Wählen Sie eine andere Region (empfohlen: `swedencentral`)
- Prüfen Sie die aktuelle Verfügbarkeit der Modelle in der Azure-Dokumentation

**"Zugriff verweigert in Keasy"**
- Überprüfen Sie URL, API-Schlüssel und Deployment-Name auf Korrektheit
- Stellen Sie sicher, dass der öffentliche Netzwerkzugang aktiviert ist

## 📞 Support

Bei Fragen zur Keasy-Integration wenden Sie sich an den Keasy-Support: [support.keasy.de](https://support.keasy.de/ticket/add)

Für Azure-spezifische Probleme konsultieren Sie die [Azure-Dokumentation](https://docs.microsoft.com/azure/cognitive-services/openai/) oder den Azure-Support.

## 📄 Lizenz

Diese Vorlage wird "wie besehen" zur Verfügung gestellt. Weitere Informationen finden Sie in den entsprechenden Azure- und OpenAI-Nutzungsbedingungen.

## 🧪 Validierung und Tests

Dieses Repository verfügt über eine umfassende Build- und Test-Pipeline, die sicherstellt, dass die ARM-Vorlage immer gültig und deploybar ist:

- **Automatische Validierung**: Jede Änderung wird automatisch über GitHub Actions getestet
- **Lokale Tests**: Führen Sie `./scripts/validate-template.sh` aus, um lokal zu validieren
- **Umfassende Prüfungen**: JSON-Syntax, Azure-Schema, Parameter-Constraints und mehr

Weitere Details finden Sie in [TESTING.md](TESTING.md) und [VALIDATION_STATUS.md](VALIDATION_STATUS.md).
