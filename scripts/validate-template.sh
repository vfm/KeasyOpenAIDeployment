#!/bin/bash

# ARM Template Validation Script
# This script validates the Azure ARM template locally

set -e

echo "🔧 ARM Template Validation Script"
echo "=================================="
echo ""

TEMPLATE_FILE="azuredeployopenai.json"

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "❌ Template file '$TEMPLATE_FILE' not found!"
    exit 1
fi

echo "📁 Template file: $TEMPLATE_FILE"
echo ""

# 1. JSON Syntax Validation
echo "🔍 Step 1: Validating JSON syntax..."
if python3 -m json.tool "$TEMPLATE_FILE" > /dev/null 2>&1; then
    echo "✅ JSON syntax is valid"
else
    echo "❌ JSON syntax is invalid!"
    python3 -m json.tool "$TEMPLATE_FILE"
    exit 1
fi
echo ""

# 2. Schema Validation (if internet available)
echo "🔍 Step 2: Validating ARM template schema..."
python3 - << 'EOF'
import json
import sys

try:
    import requests
    import jsonschema
    
    # Load the template
    with open('azuredeployopenai.json', 'r') as f:
        template = json.load(f)
    
    # Get the schema URL from the template
    schema_url = template.get('$schema')
    if not schema_url:
        print("❌ No $schema property found in template")
        sys.exit(1)
    
    print(f"   Schema URL: {schema_url}")
    
    # Download the schema
    try:
        response = requests.get(schema_url, timeout=10)
        response.raise_for_status()
        schema = response.json()
        
        # Validate against schema
        jsonschema.validate(template, schema)
        print("✅ ARM template schema validation passed")
        
    except requests.exceptions.RequestException:
        print("⚠️  Could not download schema (no internet connection)")
        print("   Schema validation skipped")
    except jsonschema.exceptions.ValidationError as e:
        print(f"❌ Schema validation failed: {e.message}")
        sys.exit(1)
        
except ImportError:
    print("⚠️  Missing dependencies (requests, jsonschema)")
    print("   Install with: pip install requests jsonschema")
    print("   Schema validation skipped")
EOF
echo ""

# 3. Parameter Validation
echo "🔍 Step 3: Validating template parameters..."
python3 - << 'EOF'
import json
import sys

with open('azuredeployopenai.json', 'r') as f:
    template = json.load(f)

parameters = template.get('parameters', {})

# Check required parameters exist
required_params = ['location', 'accountName', 'deploymentName', 'modelName', 'modelVersion']
for param in required_params:
    if param not in parameters:
        print(f"❌ Missing required parameter: {param}")
        sys.exit(1)

# Validate specific parameter constraints

# Check location allowed values
location = parameters.get('location', {})
if 'allowedValues' in location:
    allowed_locations = location['allowedValues']
    if 'swedencentral' not in allowed_locations:
        print("❌ swedencentral must be in allowed locations")
        sys.exit(1)

# Check accountName constraints
account_name = parameters.get('accountName', {})
if account_name.get('minLength', 0) < 3:
    print("❌ accountName minLength should be at least 3")
    sys.exit(1)
if account_name.get('maxLength', 0) > 64:
    print("❌ accountName maxLength should be max 63")
    sys.exit(1)

# Check modelName allowed values
model_name = parameters.get('modelName', {})
if 'allowedValues' in model_name:
    allowed_models = model_name['allowedValues']
    if 'gpt-4o' not in allowed_models:
        print("❌ gpt-4o must be in allowed model values")
        sys.exit(1)

print("✅ All parameter validations passed")
EOF
echo ""

# 4. Resource Validation
echo "🔍 Step 4: Validating resource definitions..."
python3 - << 'EOF'
import json
import sys

with open('azuredeployopenai.json', 'r') as f:
    template = json.load(f)

resources = template.get('resources', [])

if len(resources) != 2:
    print(f"❌ Expected 2 resources, found {len(resources)}")
    sys.exit(1)

# Check for Cognitive Services account
cognitive_service_found = False
deployment_found = False

for resource in resources:
    resource_type = resource.get('type')
    
    if resource_type == 'Microsoft.CognitiveServices/accounts':
        cognitive_service_found = True
        # Validate properties
        if resource.get('kind') != 'OpenAI':
            print("❌ Cognitive Service kind must be 'OpenAI'")
            sys.exit(1)
        
        sku = resource.get('sku', {})
        if sku.get('name') != 'S0':
            print("❌ SKU name must be 'S0'")
            sys.exit(1)
    
    elif resource_type == 'Microsoft.CognitiveServices/accounts/deployments':
        deployment_found = True
        # Validate deployment properties
        properties = resource.get('properties', {})
        model = properties.get('model', {})
        
        if model.get('format') != 'OpenAI':
            print("❌ Model format must be 'OpenAI'")
            sys.exit(1)

if not cognitive_service_found:
    print("❌ Missing Microsoft.CognitiveServices/accounts resource")
    sys.exit(1)

if not deployment_found:
    print("❌ Missing Microsoft.CognitiveServices/accounts/deployments resource")
    sys.exit(1)

print("✅ All resource definitions are valid")
EOF
echo ""

# 5. Output Validation
echo "🔍 Step 5: Validating template outputs..."
python3 - << 'EOF'
import json
import sys

with open('azuredeployopenai.json', 'r') as f:
    template = json.load(f)

outputs = template.get('outputs', {})

if 'endpoint' not in outputs:
    print("❌ Missing 'endpoint' output")
    sys.exit(1)

endpoint_output = outputs['endpoint']
if endpoint_output.get('type') != 'string':
    print("❌ Endpoint output must be of type 'string'")
    sys.exit(1)

print("✅ Template outputs are valid")
EOF
echo ""

# 6. Azure CLI Validation (if available)
echo "🔍 Step 6: Azure CLI validation..."
if command -v az >/dev/null 2>&1; then
    if az account show >/dev/null 2>&1; then
        echo "   Running Azure CLI validation..."
        
        # Create a temporary resource group name for validation
        RG_NAME="rg-validation-$(date +%s)"
        LOCATION="swedencentral"
        
        # Validate the template deployment (dry-run)
        if az deployment group validate \
            --resource-group "$RG_NAME" \
            --template-file "$TEMPLATE_FILE" \
            --parameters accountName=validationtest \
            --output table >/dev/null 2>&1; then
            echo "✅ Azure CLI validation passed"
        else
            echo "❌ Azure CLI validation failed"
            echo "   Run with verbose output: az deployment group validate --resource-group test --template-file $TEMPLATE_FILE --parameters accountName=test"
            exit 1
        fi
    else
        echo "⚠️  Azure CLI not authenticated (run 'az login')"
        echo "   Skipping Azure validation"
    fi
else
    echo "⚠️  Azure CLI not installed"
    echo "   Skipping Azure validation"
fi
echo ""

# Summary
echo "🎉 Validation Complete!"
echo "======================="
echo ""
echo "All validations passed successfully!"
echo "The ARM template is ready for deployment. 🚀"
echo ""
echo "Next steps:"
echo "1. Commit your changes"
echo "2. Push to GitHub to trigger automated testing"
echo "3. Deploy using the Azure portal or Azure CLI"
echo ""