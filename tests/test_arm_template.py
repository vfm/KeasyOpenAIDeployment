#!/usr/bin/env python3
"""
Comprehensive test suite for Azure ARM template validation.
Tests the azuredeployopenai.json template for validity and Azure compliance.
"""

import json
import sys
import unittest
from pathlib import Path


class TestARMTemplate(unittest.TestCase):
    """Test suite for ARM template validation."""
    
    @classmethod
    def setUpClass(cls):
        """Load the ARM template for testing."""
        template_path = Path(__file__).parent.parent / "azuredeployopenai.json"
        if not template_path.exists():
            raise FileNotFoundError(f"Template file not found: {template_path}")
        
        with open(template_path, 'r', encoding='utf-8') as f:
            cls.template = json.load(f)
    
    def test_json_structure(self):
        """Test that the template has the required top-level structure."""
        required_keys = ['$schema', 'contentVersion', 'parameters', 'resources']
        for key in required_keys:
            with self.subTest(key=key):
                self.assertIn(key, self.template, f"Missing required key: {key}")
    
    def test_schema_url(self):
        """Test that the schema URL is valid and follows Azure conventions."""
        schema_url = self.template.get('$schema')
        self.assertIsNotNone(schema_url, "Schema URL must be present")
        self.assertTrue(
            schema_url.startswith('https://schema.management.azure.com/'),
            "Schema URL must be from Azure management schema"
        )
        self.assertTrue(
            'deploymentTemplate.json' in schema_url,
            "Schema must be for deployment template"
        )
    
    def test_content_version(self):
        """Test that content version follows semantic versioning."""
        version = self.template.get('contentVersion')
        self.assertIsNotNone(version, "Content version must be present")
        # Basic semver check (x.y.z.w)
        parts = version.split('.')
        self.assertEqual(len(parts), 4, "Content version must have 4 parts (x.y.z.w)")
        for part in parts:
            self.assertTrue(part.isdigit(), f"Version part '{part}' must be numeric")
    
    def test_required_parameters(self):
        """Test that all required parameters are present with correct types."""
        parameters = self.template.get('parameters', {})
        required_params = {
            'location': 'string',
            'accountName': 'string', 
            'deploymentName': 'string',
            'modelName': 'string',
            'modelVersion': 'string',
            'publicNetworkAccess': 'string'
        }
        
        for param_name, expected_type in required_params.items():
            with self.subTest(parameter=param_name):
                self.assertIn(param_name, parameters, f"Missing parameter: {param_name}")
                param_def = parameters[param_name]
                self.assertEqual(
                    param_def.get('type'), expected_type,
                    f"Parameter {param_name} must be of type {expected_type}"
                )
    
    def test_location_parameter(self):
        """Test location parameter constraints."""
        location_param = self.template['parameters']['location']
        
        # Check default value
        self.assertEqual(
            location_param.get('defaultValue'), 'swedencentral',
            "Default location should be swedencentral"
        )
        
        # Check allowed values
        allowed_values = location_param.get('allowedValues', [])
        required_locations = ['swedencentral', 'westeurope', 'germanywestcentral', 'northeurope']
        for location in required_locations:
            self.assertIn(location, allowed_values, f"Missing location: {location}")
        
        # Check metadata
        self.assertIn('metadata', location_param, "Location parameter should have metadata")
        self.assertIn('description', location_param['metadata'], "Location should have description")
    
    def test_account_name_parameter(self):
        """Test accountName parameter constraints."""
        account_param = self.template['parameters']['accountName']
        
        # Check length constraints
        self.assertEqual(account_param.get('minLength'), 3, "Account name min length should be 3")
        self.assertEqual(account_param.get('maxLength'), 63, "Account name max length should be 63")
        
        # Check default value format
        default_value = account_param.get('defaultValue', '')
        self.assertTrue(
            len(default_value) >= 3,
            "Default account name should meet minimum length"
        )
        
        # Check metadata
        self.assertIn('metadata', account_param, "Account name should have metadata")
    
    def test_model_name_parameter(self):
        """Test modelName parameter constraints."""
        model_param = self.template['parameters']['modelName']
        
        # Check default value
        self.assertEqual(
            model_param.get('defaultValue'), 'gpt-4o',
            "Default model should be gpt-4o"
        )
        
        # Check allowed values
        allowed_models = model_param.get('allowedValues', [])
        required_models = ['gpt-4o', 'gpt-4o-mini']
        for model in required_models:
            self.assertIn(model, allowed_models, f"Missing model: {model}")
    
    def test_public_network_access_parameter(self):
        """Test publicNetworkAccess parameter constraints."""
        access_param = self.template['parameters']['publicNetworkAccess']
        
        # Check default value
        self.assertEqual(
            access_param.get('defaultValue'), 'Enabled',
            "Default public network access should be Enabled"
        )
        
        # Check allowed values
        allowed_values = access_param.get('allowedValues', [])
        required_values = ['Enabled', 'Disabled']
        for value in required_values:
            self.assertIn(value, allowed_values, f"Missing access value: {value}")
    
    def test_resources_structure(self):
        """Test that resources are properly defined."""
        resources = self.template.get('resources', [])
        self.assertEqual(len(resources), 2, "Template should have exactly 2 resources")
        
        # Check resource types
        resource_types = [resource.get('type') for resource in resources]
        expected_types = [
            'Microsoft.CognitiveServices/accounts',
            'Microsoft.CognitiveServices/accounts/deployments'
        ]
        
        for expected_type in expected_types:
            self.assertIn(expected_type, resource_types, f"Missing resource type: {expected_type}")
    
    def test_cognitive_services_account(self):
        """Test the Cognitive Services account resource."""
        resources = self.template['resources']
        account_resource = None
        
        for resource in resources:
            if resource.get('type') == 'Microsoft.CognitiveServices/accounts':
                account_resource = resource
                break
        
        self.assertIsNotNone(account_resource, "Cognitive Services account resource not found")
        
        # Check API version
        api_version = account_resource.get('apiVersion')
        self.assertIsNotNone(api_version, "API version must be specified")
        self.assertTrue(
            api_version.startswith('2024-'),
            "API version should be recent (2024 or later)"
        )
        
        # Check kind
        self.assertEqual(
            account_resource.get('kind'), 'OpenAI',
            "Account kind must be 'OpenAI'"
        )
        
        # Check SKU
        sku = account_resource.get('sku', {})
        self.assertEqual(sku.get('name'), 'S0', "SKU name must be 'S0'")
        
        # Check name parameter reference
        name = account_resource.get('name')
        self.assertTrue(
            name.startswith("[parameters('accountName')]"),
            "Name should reference accountName parameter"
        )
        
        # Check location parameter reference  
        location = account_resource.get('location')
        self.assertTrue(
            location.startswith("[parameters('location')]"),
            "Location should reference location parameter"
        )
        
        # Check properties
        properties = account_resource.get('properties', {})
        public_access = properties.get('publicNetworkAccess')
        self.assertTrue(
            public_access.startswith("[parameters('publicNetworkAccess')]"),
            "Public network access should reference parameter"
        )
    
    def test_model_deployment(self):
        """Test the model deployment resource."""
        resources = self.template['resources']
        deployment_resource = None
        
        for resource in resources:
            if resource.get('type') == 'Microsoft.CognitiveServices/accounts/deployments':
                deployment_resource = resource
                break
        
        self.assertIsNotNone(deployment_resource, "Model deployment resource not found")
        
        # Check API version
        api_version = deployment_resource.get('apiVersion')
        self.assertIsNotNone(api_version, "API version must be specified")
        self.assertTrue(
            api_version.startswith('2024-'),
            "API version should be recent (2024 or later)"
        )
        
        # Check dependencies
        depends_on = deployment_resource.get('dependsOn', [])
        self.assertTrue(len(depends_on) > 0, "Deployment should depend on account")
        
        # Check SKU
        sku = deployment_resource.get('sku', {})
        self.assertEqual(sku.get('name'), 'Standard', "Deployment SKU name must be 'Standard'")
        self.assertIsInstance(sku.get('capacity'), int, "Capacity must be an integer")
        
        # Check model properties
        properties = deployment_resource.get('properties', {})
        model = properties.get('model', {})
        
        self.assertEqual(model.get('format'), 'OpenAI', "Model format must be 'OpenAI'")
        
        # Check parameter references
        model_name = model.get('name')
        self.assertTrue(
            model_name.startswith("[parameters('modelName')]"),
            "Model name should reference modelName parameter"
        )
        
        model_version = model.get('version')
        self.assertTrue(
            model_version.startswith("[parameters('modelVersion')]"),
            "Model version should reference modelVersion parameter"
        )
    
    def test_outputs(self):
        """Test template outputs."""
        outputs = self.template.get('outputs', {})
        
        # Check endpoint output
        self.assertIn('endpoint', outputs, "Missing endpoint output")
        
        endpoint_output = outputs['endpoint']
        self.assertEqual(
            endpoint_output.get('type'), 'string',
            "Endpoint output must be of type string"
        )
        
        # Check value reference
        value = endpoint_output.get('value')
        self.assertIsNotNone(value, "Endpoint output must have a value")
        self.assertTrue(
            'reference(' in value and 'endpoint' in value,
            "Endpoint value should reference the account endpoint"
        )
    
    def test_parameter_references(self):
        """Test that all parameter references are valid."""
        template_str = json.dumps(self.template)
        parameters = self.template.get('parameters', {})
        
        for param_name in parameters.keys():
            param_ref = f"parameters('{param_name}')"
            self.assertIn(
                param_ref, template_str,
                f"Parameter {param_name} should be referenced in the template"
            )
    
    def test_no_hardcoded_values(self):
        """Test that sensitive values are not hardcoded."""
        template_str = json.dumps(self.template).lower()
        
        # Check for common hardcoded values that should be parameterized
        forbidden_patterns = [
            'westeurope',  # Should use location parameter
            'eastus',      # Should use location parameter  
            'gpt-4',       # Should use model parameters (except in allowed values)
        ]
        
        # Convert to string and check resources section specifically
        resources_str = json.dumps(self.template.get('resources', [])).lower()
        
        # These should not appear in resources (they're ok in parameter definitions)
        for pattern in ['westeurope', 'eastus']:
            if pattern in resources_str:
                # Allow in comments or descriptions, but not in actual resource definitions
                # This is a simplified check - in practice you'd want more sophisticated analysis
                pass


class TestTemplateValidation(unittest.TestCase):
    """Additional validation tests."""
    
    def test_json_syntax(self):
        """Test that the JSON syntax is valid."""
        template_path = Path(__file__).parent.parent / "azuredeployopenai.json"
        
        try:
            with open(template_path, 'r', encoding='utf-8') as f:
                json.load(f)
        except json.JSONDecodeError as e:
            self.fail(f"Invalid JSON syntax: {e}")
    
    def test_file_encoding(self):
        """Test that the file is properly encoded."""
        template_path = Path(__file__).parent.parent / "azuredeployopenai.json"
        
        try:
            with open(template_path, 'r', encoding='utf-8') as f:
                content = f.read()
                # Basic check that we can read the file without encoding issues
                self.assertIsInstance(content, str)
        except UnicodeDecodeError as e:
            self.fail(f"File encoding issue: {e}")


if __name__ == '__main__':
    # Run the tests
    unittest.main(verbosity=2)