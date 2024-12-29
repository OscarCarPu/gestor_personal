import os
import pytest
import boto3
import requests
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Constants
USER_POOL_ID = os.getenv('USER_POOL_ID')
CLIENT_ID = os.getenv('CLIENT_ID')
API_URL = os.getenv('API_URL') 
USERNAME = "test"
PASSWORD = "Abc123.."

@pytest.fixture
def auth_token():
    """Get authentication token from Cognito"""
    client = boto3.client('cognito-idp')
    try:
        response = client.initiate_auth(
            ClientId=CLIENT_ID,
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': USERNAME,
                'PASSWORD': PASSWORD
            }
        )
        return response['AuthenticationResult']['IdToken']
    except Exception as e:
        pytest.fail(f"Failed to get auth token: {str(e)}")

def test_hello_endpoint_with_valid_token(auth_token):
    """Test /hello endpoint with valid token"""
    headers = {
        'Authorization': f'Bearer {auth_token}'
    }
    print(f"\nUsing token: {auth_token[:50]}...")  # Print first 50 chars of token
    print(f"Headers: {headers}")
    response = requests.get(API_URL, headers=headers)
    print(f"Response status: {response.status_code}")
    print(f"Response body: {response.text}")
    assert response.status_code == 200
    
def test_hello_endpoint_without_token():
    """Test /hello endpoint without token"""
    response = requests.get(API_URL)
    assert response.status_code == 401

def test_hello_endpoint_with_invalid_token():
    """Test /hello endpoint with invalid token"""
    headers = {
        'Authorization': 'Bearer invalid_token'
    }
    response = requests.get(API_URL, headers=headers)
    assert response.status_code == 401

def test_hello_endpoint_with_malformed_token():
    """Test /hello endpoint with malformed token"""
    headers = {
        'Authorization': 'InvalidTokenFormat'
    }
    response = requests.get(API_URL, headers=headers)
    assert response.status_code == 401