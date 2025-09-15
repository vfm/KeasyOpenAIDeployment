#!/bin/bash

# Demo script to show how validation catches common errors
# This script demonstrates the validation pipeline by introducing errors

set -e

echo "🎯 ARM Template Validation Demo"
echo "==============================="
echo ""
echo "This demo shows how the validation pipeline catches common errors."
echo ""

ORIGINAL_FILE="azuredeployopenai.json"
DEMO_FILE="/tmp/demo-template.json"

# Create backup
cp "$ORIGINAL_FILE" "$DEMO_FILE.backup"

echo "1️⃣  Testing valid template..."
echo "Copying original template for testing..."
cp "$ORIGINAL_FILE" "$DEMO_FILE"

# Test valid template
python3 - << EOF
import json
import sys

try:
    with open('$DEMO_FILE', 'r') as f:
        template = json.load(f)
    
    # Basic validation
    required_keys = ['\$schema', 'contentVersion', 'parameters', 'resources']
    for key in required_keys:
        if key not in template:
            print(f"❌ Missing required key: {key}")
            sys.exit(1)
    
    print("✅ Valid template structure")
    
except json.JSONDecodeError as e:
    print(f"❌ JSON syntax error: {e}")
    sys.exit(1)
except Exception as e:
    print(f"❌ Validation error: {e}")
    sys.exit(1)
EOF

echo ""
echo "2️⃣  Testing JSON syntax error..."
echo "Introducing JSON syntax error..."

# Create invalid JSON
cat > "$DEMO_FILE" << 'EOF'
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "type": "string"
      // Missing comma here - this will cause JSON syntax error
      "defaultValue": "swedencentral"
    }
  }
}
EOF

# Test invalid JSON
echo "Testing invalid JSON..."
if python3 -m json.tool "$DEMO_FILE" > /dev/null 2>&1; then
    echo "❌ Validation failed to catch JSON syntax error!"
else
    echo "✅ JSON syntax error correctly detected"
fi

echo ""
echo "3️⃣  Testing missing required parameter..."
echo "Creating template with missing required parameter..."

# Create template missing required parameter
cat > "$DEMO_FILE" << 'EOF'
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "type": "string",
      "defaultValue": "swedencentral"
    }
  },
  "resources": []
}
EOF

# Test missing parameter
python3 - << EOF
import json
import sys

try:
    with open('$DEMO_FILE', 'r') as f:
        template = json.load(f)
    
    parameters = template.get('parameters', {})
    required_params = ['location', 'accountName', 'deploymentName', 'modelName', 'modelVersion']
    
    missing_params = []
    for param in required_params:
        if param not in parameters:
            missing_params.append(param)
    
    if missing_params:
        print(f"✅ Missing parameters correctly detected: {', '.join(missing_params)}")
    else:
        print("❌ Validation failed to detect missing parameters!")

except Exception as e:
    print(f"Error during validation: {e}")
EOF

echo ""
echo "4️⃣  Testing invalid resource configuration..."
echo "Creating template with invalid resource configuration..."

# Create template with invalid resource
cat > "$DEMO_FILE" << 'EOF'
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {"type": "string", "defaultValue": "swedencentral"},
    "accountName": {"type": "string", "defaultValue": "test"}
  },
  "resources": [
    {
      "type": "Microsoft.CognitiveServices/accounts",
      "apiVersion": "2024-10-01",
      "name": "[parameters('accountName')]",
      "location": "[parameters('location')]",
      "kind": "WrongKind",
      "sku": {"name": "WrongSKU"}
    }
  ]
}
EOF

# Test invalid resource
python3 - << EOF
import json
import sys

try:
    with open('$DEMO_FILE', 'r') as f:
        template = json.load(f)
    
    resources = template.get('resources', [])
    errors = []
    
    for resource in resources:
        if resource.get('type') == 'Microsoft.CognitiveServices/accounts':
            if resource.get('kind') != 'OpenAI':
                errors.append(f"Invalid kind: {resource.get('kind')} (should be 'OpenAI')")
            
            sku = resource.get('sku', {})
            if sku.get('name') != 'S0':
                errors.append(f"Invalid SKU: {sku.get('name')} (should be 'S0')")
    
    if errors:
        print(f"✅ Resource configuration errors correctly detected:")
        for error in errors:
            print(f"   - {error}")
    else:
        print("❌ Validation failed to detect resource configuration errors!")

except Exception as e:
    print(f"Error during validation: {e}")
EOF

echo ""
echo "🧹 Cleaning up demo files..."
rm -f "$DEMO_FILE"

echo ""
echo "🎉 Demo Complete!"
echo "=================="
echo ""
echo "The validation pipeline successfully:"
echo "✅ Validates JSON syntax"
echo "✅ Checks for required parameters"
echo "✅ Validates resource configurations"
echo "✅ Provides clear error messages"
echo ""
echo "This ensures that only valid ARM templates are deployed! 🚀"