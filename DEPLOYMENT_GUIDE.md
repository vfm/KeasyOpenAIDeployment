# Detaillierte Deployment-Anleitung

## Technische Details zur Azure OpenAI Bereitstellung

Diese Anleitung richtet sich an technische Administratoren, die eine Azure OpenAI-Instanz für die Keasy-Software bereitstellen möchten.

## ARM Template Details

### Was wird bereitgestellt?

Das ARM Template erstellt folgende Azure-Ressourcen:

1. **Cognitive Services Account** (OpenAI)
   - SKU: S0 (Standard)
   - Kind: OpenAI
   - Öffentlicher Netzwerkzugang: Aktiviert (für Keasy-Integration erforderlich)

2. **Model Deployment**
   - Standard-Deployment mit Kapazität 1
   - Modell: GPT-4o (Standard) oder GPT-4o-mini
   - Format: OpenAI

### Parameter-Details

```json
{
  "location": "germanywestcentral",      // EU-DSGVO-konforme Region
  "accountName": "openaiIHRMAKLERNAME",  // Eindeutiger Name (3-63 Zeichen)
  "deploymentName": "gpt-4o",            // Name des Model-Deployments
  "modelName": "gpt-4o",                 // OpenAI-Modell
  "modelVersion": "2024-08-06",          // Spezifische Modell-Version
  "publicNetworkAccess": "Enabled"       // Für Keasy-Integration erforderlich
}
```

## Regionale Verfügbarkeit

### Empfohlene EU-Regionen für DSGVO-Compliance:

| Region | GPT-4o Verfügbarkeit | GPT-4o-mini Verfügbarkeit | Empfehlung |
|--------|---------------------|---------------------------|------------|
| `swedencentral` | ✅ Verfügbar | ✅ Verfügbar | **Empfohlen** |
| `westeurope` | ✅ Verfügbar | ✅ Verfügbar | Alternative |
| `germanywestcentral` | ✅ Verfügbar | ✅ Verfügbar | Alternative |

## Kosten-Kalkulation

### Standard-Pricing (GPT-4o):
- **Input**: ~$5.00 pro 1M Token
- **Output**: ~$15.00 pro 1M Token

### Mini-Pricing (GPT-4o-mini):
- **Input**: ~$0.15 pro 1M Token  
- **Output**: ~$0.60 pro 1M Token

> **Hinweis**: Preise können sich ändern. Aktuelle Preise in der [Azure-Preisübersicht](https://azure.microsoft.com/pricing/details/cognitive-services/openai-service/) prüfen.

## Sicherheitsüberlegungen

### Netzwerkzugang
- **Öffentlicher Zugang**: Erforderlich für Keasy-Integration
- **Alternative**: Private Endpoints möglich, erfordern aber VPN/ExpressRoute

### API-Schlüssel Management
- Rotieren Sie API-Schlüssel regelmäßig
- Verwenden Sie Azure Key Vault für sichere Speicherung
- Implementieren Sie Monitoring für ungewöhnliche Nutzung

### DSGVO-Compliance
- Daten werden in EU-Regionen verarbeitet
- OpenAI-Datenrichtlinien beachten
- Protokollierung und Audit-Funktionen aktivieren

## Monitoring und Wartung

### Azure Monitor Integration
```bash
# Beispiel: Überwachung der API-Aufrufe
az monitor metrics list \
  --resource "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.CognitiveServices/accounts/{account-name}" \
  --metric "TotalCalls"
```

### Empfohlene Metriken:
- `TotalCalls`: Gesamtanzahl API-Aufrufe
- `TotalTokens`: Verbrauchte Token
- `Errors`: Fehlerrate
- `Latency`: Antwortzeiten

## Troubleshooting

### Häufige Deployment-Fehler

#### 1. Quota-Überschreitung
```
Error: The subscription does not have enough quota
```
**Lösung**: Quota-Erhöhung über Azure Support beantragen

#### 2. Regionale Verfügbarkeit
```
Error: The model 'gpt-4o' is not available in region 'westeurope'
```
**Lösung**: Region auf `swedencentral` ändern

#### 3. Namenskonflikt
```
Error: Account name already exists
```
**Lösung**: Eindeutigen Account-Namen wählen - dieser Accountname ist bereits schon bei einer anderen Bereitstellung vergeben.

### Verbindungstests

#### PowerShell-Test:
```powershell
$headers = @{
    "Content-Type" = "application/json"
    "api-key" = "IHR_API_SCHLUESSEL"
}

$body = @{
    "messages" = @(
        @{
            "role" = "user"
            "content" = "Hallo, das ist ein Test."
        }
    )
    "max_tokens" = 10
} | ConvertTo-Json -Depth 3

Invoke-RestMethod -Uri "https://IHR_ENDPOINT.openai.azure.com/openai/deployments/IHR_DEPLOYMENT/chat/completions?api-version=2024-08-01-preview" -Method POST -Headers $headers -Body $body
```

#### cURL-Test:
```bash
curl -X POST "https://IHR_ENDPOINT.openai.azure.com/openai/deployments/IHR_DEPLOYMENT/chat/completions?api-version=2024-08-01-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: IHR_API_SCHLUESSEL" \
  -d '{
    "messages": [
      {
        "role": "user",
        "content": "Hallo, das ist ein Test."
      }
    ],
    "max_tokens": 10
  }'
```

## Keasy-spezifische Konfiguration

### Erforderliche Werte für Keasy:

1. **Azure Open AI Endpoint**: 
   ```
   https://{accountName}.openai.azure.com
   ```

2. **Azure Open AI Key**: 
   ```
   *** <secret> ***
   ```

3. **Deployment Name**:
   ```
   gpt-4o
   ```

### Vollständige URL für Keasy:
```
https://{accountName}.openai.azure.com/openai/deployments/{deploymentName}/chat/completions?api-version=2024-08-01-preview
```

## Support-Kontakte

- **Azure Support**: [Azure Support Portal](https://portal.azure.com/#blade/Microsoft_Azure_Support/HelpAndSupportBlade)
- **Keasy Support**: [support.keasy.de](https://support.keasy.de/ticket/add)
- **OpenAI API Dokumentation**: [Azure OpenAI Docs](https://docs.microsoft.com/azure/cognitive-services/openai/)
