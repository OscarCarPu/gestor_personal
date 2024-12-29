# Testing Environment

This directory contains the testing environment setup and test suites for the application.

## Environment Setup

1. Create and activate a virtual environment:
```bash
# Windows
python -m venv .venv
.venv\Scripts\activate

# Linux/MacOS
python -m venv .venv
source .venv/bin/activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Make sure LocalStack is running and the stacks are deployed:
```bash
docker-compose up -d
./deploy-local.ps1
```

## Test Suites

### API Authentication Tests (`api_auth/`)
Tests to verify the integration between Cognito authentication and the API Gateway endpoint.

Test cases include:
1. `test_hello_endpoint_without_token`: Verifies that the endpoint requires authentication
2. `test_hello_endpoint_with_invalid_token`: Verifies that the endpoint rejects invalid tokens
3. `test_hello_endpoint_with_valid_token`: Verifies that the endpoint works with a valid Cognito token

## Directory Structure

- `api_auth/` - API authentication test suite
- `deploy-local.ps1` - Script for deploying the local testing environment
- `docker-compose.yml` - Docker configuration for local testing services
- `requirements.txt` - Python dependencies for testing

## Running Tests

Run all tests using pytest:
```bash
pytest tests/
```

