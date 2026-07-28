# Detaillierte Deployment-Anleitung (für Administratoren)

## Technische Details zur Keasy-KI-Bereitstellung in Azure

Diese Anleitung richtet sich an technische Administratoren. Für Endanwender gibt es die einfache Anleitung ([KeasyKIDeployment.md](KeasyKIDeployment.md)) und den **Einrichtungsassistenten**, der alle folgenden Schritte automatisiert: **[https://keasyki-onboarding.azurewebsites.net](https://keasyki-onboarding.azurewebsites.net)**

> **Wichtigste Änderung gegenüber früheren Versionen dieser Anleitung:** Es wird **keine klassische Azure-OpenAI-Ressource (`kind: OpenAI`) mehr angelegt**, sondern eine **Azure AI Foundry-Ressource (`kind: AIServices`)** — nur diese unterstützt neben den GPT-Modellen auch das Mistral-OCR-Modell, das Keasy für die Dokumentenerkennung nutzt. Die frühere ARM-Vorlage (gpt-4o) ist veraltet.

## Was wird bereitgestellt?

1. **Azure AI Foundry Account** (Cognitive Services)
   - Kind: `AIServices` (nicht `OpenAI`!)
   - SKU: `S0` (Standard)
   - Region: `germanywestcentral` (empfohlen)
   - `customSubDomainName` = Kontoname (Pflicht für die Endpunkte)
   - `allowProjectManagement: true` (Pflicht für Foundry-Projekte; erfordert api-version **2025-06-01** — ältere API-Versionen verwerfen das Flag stillschweigend)
   - Öffentlicher Netzwerkzugang: `Enabled` (für die Keasy-Integration erforderlich)

2. **Foundry-Standardprojekt** (`<accountName>-project`)
   - Ohne Projekt verlangt das Foundry-Portal vor der Nutzung eine manuelle Projektanlage
   - Identity: `SystemAssigned`

3. **GPT-Deployment** (`gpt-5.4`)
   - SKU: `DataZoneStandard` (EU-Datenzone), Kapazität **100** = 100.000 Tokens/Minute (TPM)
   - Alternativ: `gpt-5.6-terra` / `-sol` / `-luna` (Terra = beste Qualität, höhere Kosten)

4. **OCR-Deployment** (`mistral-document-ai-2512`)
   - Modellformat: **`Mistral AI`** (mit Leerzeichen!)
   - SKU: `DataZoneStandard`, Kapazität **40** = 40 **Anforderungen/Minute (RPM, nicht Tokens!)** — aktuelles Azure-Maximum für dieses Modell
   - RAI-Policy: `Microsoft.DefaultV2`
   - Achtung: Der Standort-Modellkatalog meldet teils höhere Maxima (bis 1000) — deploybar sind aktuell 40

## Bereitstellung per REST / Infrastructure-as-Code

Die folgenden Aufrufe entsprechen dem, was der Assistent ausführt (ARM-Token mit `https://management.azure.com/.default`-Scope vorausgesetzt).

### 1. Account anlegen

```http
PUT https://management.azure.com/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.CognitiveServices/accounts/{accountName}?api-version=2025-06-01
{
  "kind": "AIServices",
  "location": "germanywestcentral",
  "sku": { "name": "S0" },
  "properties": {
    "customSubDomainName": "{accountName}",
    "publicNetworkAccess": "Enabled",
    "allowProjectManagement": true
  }
}
```

### 2. Standardprojekt anlegen

```http
PUT …/accounts/{accountName}/projects/{accountName}-project?api-version=2025-06-01
{
  "location": "germanywestcentral",
  "identity": { "type": "SystemAssigned" },
  "properties": { "displayName": "{accountName}-project" }
}
```

### 3. GPT-Deployment

```http
PUT …/accounts/{accountName}/deployments/gpt-5.4?api-version=2025-10-01-preview
{
  "sku": { "name": "DataZoneStandard", "capacity": 100 },
  "properties": {
    "model": { "format": "OpenAI", "name": "gpt-5.4", "version": "{aktuelle Version aus dem Regionskatalog}" }
  }
}
```

### 4. OCR-Deployment (Mistral)

```http
PUT …/accounts/{accountName}/deployments/mistral-document-ai-2512?api-version=2025-10-01-preview
{
  "sku": { "name": "DataZoneStandard", "capacity": 40 },
  "properties": {
    "model": { "format": "Mistral AI", "name": "mistral-document-ai-2512", "version": "1" },
    "raiPolicyName": "Microsoft.DefaultV2"
  }
}
```

### Bestehende Azure-OpenAI-Ressource? → Foundry-Upgrade statt Neuanlage

Eine vorhandene `kind: OpenAI`-Ressource wird per **PATCH** aktualisiert — Endpunkte, Schlüssel und Deployments bleiben erhalten (entspricht dem „Ressourcenupgrade"-Wizard im Azure-Portal, [MS-Doku](https://learn.microsoft.com/azure/foundry/how-to/upgrade-azure-openai)):

```http
PATCH …/accounts/{accountName}?api-version=2025-06-01
{
  "kind": "AIServices",
  "identity": { "type": "SystemAssigned" },
  "properties": { "allowProjectManagement": true }
}
```

- **Managed Identity (SystemAssigned) ist Upgrade-Voraussetzung** — im selben PATCH aktivierbar
- `disableLocalAuth` **nicht** setzen — Keasy authentifiziert per API-Key
- Danach Standardprojekt anlegen (siehe oben); Dauer des Upgrades: ca. 2 Minuten
- Grenzen: Konten mit Private Endpoints oder Customer-Managed Keys sind vom automatischen Upgrade ausgeschlossen; Rollback ist im Portal möglich

## Regionale Verfügbarkeit

| Region | gpt-5.4 / gpt-5.6 | mistral-document-ai-2512 | Empfehlung |
|--------|-------------------|--------------------------|------------|
| `germanywestcentral` | ✅ | ✅ | **Empfohlen** (Deutschland, DSGVO) |
| `swedencentral` | ✅ | ✅ | Alternative |
| `westeurope` | ✅ | teils | Alternative |

Verbindlich ist der Regionskatalog: `GET …/providers/Microsoft.CognitiveServices/locations/{region}/models?api-version=2024-10-01` — dort stehen je Modell Format, Versionen und SKU-Kapazitäten.

## Kosten

Die Abrechnung erfolgt verbrauchsbasiert (Tokens bzw. OCR-Anfragen) über das Azure-Abonnement des Kunden. **Konkrete Preise bitte immer aktuell nachschlagen** — sie ändern sich regelmäßig:

- [Azure OpenAI / Foundry-Preisliste](https://azure.microsoft.com/de-de/pricing/details/cognitive-services/openai-service/)
- [Azure-Preisrechner](https://azure.microsoft.com/de-de/pricing/calculator/)
- Preis je Modell wird auch im Foundry-Portal beim Bereitstellen angezeigt (inkl. Mistral)

Faustregeln: `gpt-5.6-terra`/`-sol` sind leistungsfähiger, aber teurer als `gpt-5.4`; das Mistral-OCR-Modell kostet nur bei tatsächlicher Nutzung. Kostenkontrolle: *Abonnement → Kostenanalyse* (Rolle „Kostenverwaltungsleser"/„Leser" genügt), Budget-Warnungen unter *Kostenverwaltung → Budgets*.

## Sicherheitsüberlegungen

### Berechtigungen (Azure RBAC)
- Bereitstellung: mindestens **Mitwirkender (Contributor)** auf Subscription oder Resource Group; **Besitzer (Owner)** für Rollenvergabe und Foundry-Upgrade empfohlen
- Global Administratoren ohne Azure-RBAC können sich über Entra **„Zugriffsverwaltung für Azure-Ressourcen"** (elevateAccess) selbst Zugriff verschaffen — der Assistent automatisiert genau das

### API-Schlüssel
- Ein Schlüsselpaar je Account — **gilt für GPT- und OCR-Deployments gemeinsam**
- Regelmäßig rotieren (Portal: „Schlüssel und Endpunkt" → Schlüssel neu generieren; Keasy danach aktualisieren)
- Sicher ablegen (z. B. Azure Key Vault), niemals in Skripte/Repos einchecken

### Netzwerk & DSGVO
- Öffentlicher Zugang ist für die Keasy-Integration erforderlich; Private Endpoints sind möglich, erfordern aber VPN/ExpressRoute — und blockieren das automatische Foundry-Upgrade
- `DataZoneStandard` hält die Verarbeitung in der EU-Datenzone; Region `germanywestcentral` = Deutschland

### Soft-Delete (wichtig!)
Gelöschte Cognitive-Services-Konten sind **bis zu 48 Stunden im Soft-Delete** — der Name bleibt so lange reserviert (Neuanlage scheitert mit `FlagMustBeSetForRestore`). Optionen:
- Anderen Namen wählen oder warten
- Konto wiederherstellen (PUT mit `"restore": true`)
- Namen sofort freigeben (endgültig!): `az cognitiveservices account purge -l germanywestcentral -g {rg} -n {accountName}`

## Monitoring

```bash
# Token-Verbrauch je Zeitraum
az monitor metrics list \
  --resource "/subscriptions/{sub}/resourceGroups/{rg}/providers/Microsoft.CognitiveServices/accounts/{accountName}" \
  --metric "ProcessedPromptTokens" "GeneratedTokens" --interval PT1H
```

Empfohlene Metriken: `TotalCalls` (API-Aufrufe), `ProcessedPromptTokens` / `GeneratedTokens` (Token-Verbrauch, filterbar nach `ModelDeploymentName`), `Errors`, `Latency`.

## Troubleshooting

| Fehler | Ursache / Lösung |
|---|---|
| `FlagMustBeSetForRestore` bzw. „soft deleted" bei der Neuanlage | Name ist durch ein gelöschtes Konto belegt (Soft-Delete, 48 h) → anderen Namen, warten oder purge (s. o.) |
| `CannotDeleteResource … nested resources … /projects/…` beim Konto-Löschen | Erst alle Deployments, dann alle **Foundry-Projekte** löschen, dann das Konto. Achtung: Das Projekt-DELETE ist eine **lange synchrone Operation** (>60 s) — Client-Timeout großzügig setzen und per GET verifizieren, dass das Projekt weg ist |
| Mistral-Deployment schlägt auf `kind: OpenAI`-Konto fehl | Konto zuerst per Foundry-Upgrade auf `AIServices` heben (s. o.) |
| „Project can only created under AIServices Kind account with allowProjectManagement…" | Konto wurde ohne `allowProjectManagement` angelegt (alte api-version) → Flag per PATCH (api-version 2025-06-01) nachziehen |
| `The subscription does not have enough quota` | Quota-Erhöhung über den Azure-Support beantragen |
| Modell in Region nicht verfügbar | Regionskatalog prüfen (s. o.), ggf. Region wechseln |
| OCR liefert Fehler in Keasy | `OcrApiEndpoint` muss exakt `https://{accountName}.services.ai.azure.com/providers/mistral/azure/ocr` lauten — **der Pfad ist Pflicht**; außerdem muss das Konto `AIServices` sein |

### Verbindungstest (GPT-Deployment)

```powershell
$headers = @{ "Content-Type" = "application/json"; "api-key" = "IHR_API_SCHLUESSEL" }
$body = @{
    messages   = @(@{ role = "user"; content = "Hallo, das ist ein Test." })
    max_tokens = 10
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Method POST -Headers $headers -Body $body -Uri `
  "https://{accountName}.cognitiveservices.azure.com/openai/deployments/gpt-5.4/chat/completions?api-version=2024-10-21"
```

```bash
curl -X POST "https://{accountName}.cognitiveservices.azure.com/openai/deployments/gpt-5.4/chat/completions?api-version=2024-10-21" \
  -H "Content-Type: application/json" -H "api-key: IHR_API_SCHLUESSEL" \
  -d '{"messages":[{"role":"user","content":"Hallo, das ist ein Test."}],"max_tokens":10}'
```

> Die Data-Plane-`api-version` entwickelt sich weiter — aktuelle Werte in der [Azure-OpenAI-Referenz](https://learn.microsoft.com/azure/ai-services/openai/reference).

## Keasy-spezifische Konfiguration

Die vom Assistenten erzeugte **`Setup-KeasyOpenAI.cmd`** trägt alle Werte automatisch (Keasy-verschlüsselt) in `[dbo].[Einstellungen]` ein. Bei manueller Pflege:

| Keasy-Einstellung | Wert |
|---|---|
| `AzureOpenAIEndpoint` | `https://{accountName}.cognitiveservices.azure.com/` — nach einem Foundry-Upgrade **diese** URL verwenden, nicht mehr die alte `…openai.azure.com` |
| `AzureOpenAIKey` | Schlüssel 1 (verschlüsselt abgelegt) |
| `DeploymentName` | `gpt-5.4` (bzw. Ihr GPT-Deployment-Name) |
| `OcrApiEndpoint` | `https://{accountName}.services.ai.azure.com/providers/mistral/azure/ocr` — **Pfad ist Pflicht!** |
| `OcrApiKey` | derselbe Schlüssel (verschlüsselt) |
| `OcrModel` | `mistral-document-ai-2512` |

Vollständige Chat-URL, die Keasy intern aufruft:

```
https://{accountName}.cognitiveservices.azure.com/openai/deployments/{deploymentName}/chat/completions?api-version={aktuelle api-version}
```

## Support-Kontakte

- **Keasy Support**: [support.keasy.de](https://support.keasy.de/ticket/add)
- **Azure Support**: [Azure Support Portal](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
- **Azure OpenAI / Foundry Doku**: [learn.microsoft.com/azure/ai-services/openai](https://learn.microsoft.com/azure/ai-services/openai/)
