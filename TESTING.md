# Build & Test Pipeline Documentation

This document describes the automated build and test pipeline for the Azure ARM template validation.

## Overview

The pipeline ensures that the `azuredeployopenai.json` Azure Resource Manager template remains valid and deployable by running comprehensive validation tests on every change.

## Pipeline Components

### 1. GitHub Actions Workflow

**File**: `.github/workflows/validate-template.yml`

The workflow runs automatically on:
- Pushes to the `main` branch that modify JSON files
- Pull requests targeting `main` that modify JSON files
- Manual workflow dispatch

**Validation Steps**:
1. **JSON Syntax Validation** - Ensures the JSON is syntactically correct
2. **ARM Template Schema Validation** - Validates against Azure's official ARM template schema
3. **Azure CLI Validation** - Uses Azure CLI to validate template deployability (when credentials are available)
4. **Parameter Validation** - Ensures all parameters have correct constraints and types
5. **Resource Definition Validation** - Validates Azure resource configurations
6. **Output Validation** - Ensures template outputs are properly defined
7. **JSON Formatting Check** - Verifies consistent formatting

### 2. Local Validation Script

**File**: `scripts/validate-template.sh`

A bash script that can be run locally to validate the template before committing changes.

**Usage**:
```bash
# From repository root
./scripts/validate-template.sh
```

**Features**:
- Works offline for most validations
- Provides detailed feedback on validation failures
- Optional Azure CLI integration for deployment validation
- Color-coded output for easy reading

### 3. Python Test Suite

**File**: `tests/test_arm_template.py`

Comprehensive unit tests for the ARM template structure and content.

**Usage**:
```bash
# From repository root
python3 tests/test_arm_template.py
```

**Test Categories**:
- JSON structure validation
- Parameter constraint testing
- Resource definition validation
- Output validation
- Template reference validation
- Security checks (no hardcoded sensitive values)

## Validation Checks

### JSON Syntax Validation
- Verifies valid JSON format
- Checks file encoding (UTF-8)
- Ensures no syntax errors

### ARM Template Schema Validation
- Downloads and validates against official Azure ARM template schema
- Verifies `$schema` URL is correct and accessible
- Ensures template follows Azure ARM template structure

### Parameter Validation
- **location**: Must include 'swedencentral' in allowed values (for GPT-4o availability)
- **accountName**: Must have minLength=3, maxLength=63, alphanumeric only
- **modelName**: Must include 'gpt-4o' and 'gpt-4o-mini' in allowed values
- **modelVersion**: Must be specified with metadata about regional availability
- **publicNetworkAccess**: Must allow 'Enabled' and 'Disabled' values

### Resource Validation
- **Cognitive Services Account**:
  - Type: `Microsoft.CognitiveServices/accounts`
  - Kind: `OpenAI`
  - SKU: `S0`
  - API Version: 2024 or later
  
- **Model Deployment**:
  - Type: `Microsoft.CognitiveServices/accounts/deployments`
  - SKU: `Standard` with integer capacity
  - Model format: `OpenAI`
  - Proper dependency on Cognitive Services account

### Output Validation
- **endpoint**: Must be string type and reference the account endpoint

### Azure CLI Validation (Optional)
- Uses `az deployment group validate` for real Azure validation
- Tests actual deployability without creating resources
- Requires Azure authentication (skipped in external PRs)

## Running Tests Locally

### Prerequisites
```bash
# Install Python dependencies (optional, for schema validation)
pip install requests jsonschema

# Install Azure CLI (optional, for Azure validation)
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Quick Validation
```bash
# Basic JSON syntax check
python3 -m json.tool azuredeployopenai.json

# Full local validation
./scripts/validate-template.sh

# Python unit tests
python3 tests/test_arm_template.py
```

### Azure CLI Validation
```bash
# Login to Azure (optional)
az login

# Run validation with Azure CLI
az deployment group validate \
  --resource-group <your-rg> \
  --template-file azuredeployopenai.json \
  --parameters accountName=test
```

## Continuous Integration

### Branch Protection
The GitHub workflow should be configured as a required status check to prevent merging invalid templates.

### Automated Testing
- Every push and pull request triggers validation
- Failed validations block merging
- Clear error messages guide developers to fix issues

### Dependencies
- No external dependencies for basic JSON validation
- Internet access required for schema validation
- Azure credentials optional (gracefully skipped if not available)

## Error Handling

### Common Issues and Solutions

**JSON Syntax Error**:
```
❌ JSON syntax is invalid!
```
*Solution*: Fix JSON formatting using `python3 -m json.tool` or a JSON formatter

**Schema Validation Failure**:
```
❌ Schema validation failed: 'type' is a required property
```
*Solution*: Ensure all resources have required properties per ARM template schema

**Parameter Constraint Violation**:
```
❌ accountName minLength should be at least 3
```
*Solution*: Update parameter constraints to meet Azure requirements

**Missing Resource**:
```
❌ Missing Microsoft.CognitiveServices/accounts resource
```
*Solution*: Ensure template includes all required Azure resources

**Azure CLI Validation Failure**:
```
❌ Azure CLI validation failed
```
*Solution*: Run `az deployment group validate` manually for detailed error information

## Maintenance

### Updating API Versions
When Azure releases new API versions:
1. Update `apiVersion` in template resources
2. Test with the validation pipeline
3. Update documentation if new features are used

### Adding New Validation Rules
1. Add test cases to `tests/test_arm_template.py`
2. Update validation script if needed
3. Document new checks in this file

### Schema Updates
If Azure updates ARM template schemas:
1. Update `$schema` URL in template
2. Test validation pipeline
3. Update any schema-specific validation logic

## Security Considerations

### Credential Handling
- Azure credentials only used in GitHub Actions with secrets
- Local scripts gracefully handle missing credentials
- No credentials stored in repository

### Template Security
- No hardcoded sensitive values allowed
- All configurable values use parameters
- Public network access configurable via parameter

### Pipeline Security
- GitHub Actions runs in isolated environment
- No external scripts executed
- All validation tools from trusted sources (Python stdlib, Azure CLI)

## Performance

### Validation Speed
- JSON syntax: < 1 second
- Schema validation: 2-5 seconds (downloads schema)
- Azure CLI validation: 10-30 seconds (if authenticated)
- Python tests: 1-3 seconds

### Resource Usage
- Minimal CPU and memory requirements
- No persistent storage needed
- Network access only for schema download and Azure validation

## Future Enhancements

### Potential Improvements
1. **Template Linting**: Add ARM template linting tools
2. **Cost Analysis**: Validate resource costs against budgets
3. **Security Scanning**: Check for security misconfigurations
4. **Deployment Testing**: Test actual deployment in sandbox environment
5. **Documentation Generation**: Auto-generate parameter documentation
6. **Version Management**: Automatic versioning based on changes

### Integration Opportunities
1. **Azure DevOps**: Extend pipeline to Azure DevOps
2. **Terraform**: Add Terraform conversion validation
3. **Bicep**: Add Bicep template validation
4. **Monitoring**: Add deployment success monitoring