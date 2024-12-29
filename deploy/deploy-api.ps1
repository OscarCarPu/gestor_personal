# Get environment parameter with default value
param(
    [Parameter()]
    [ValidateSet('dev', 'prod')]
    [string]$Environment = 'dev'
)

function Write-ErrorAndExit {
    param([string]$message)
    Write-Host $message -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "../infrastructure")) {
    Write-ErrorAndExit "Error: infrastructure directory not found"
}

Write-Host "Deploying API infrastructure for environment: $Environment..." -ForegroundColor Cyan

# Get the User Pool ARN from AWS
$userPoolArn = aws cloudformation list-exports --query "Exports[?Name=='GestorPersonalUserPoolArn'].Value" --output text

if (-not $userPoolArn) {
    Write-ErrorAndExit "Error: Could not find Cognito User Pool ARN. Make sure the Cognito stack is deployed."
}

# Get the S3 bucket name from DynamoDB stack
$s3BucketName = aws cloudformation describe-stacks `
    --stack-name "gestor-personal-dynamodb-$Environment" `
    --query "Stacks[0].Outputs[?OutputKey=='BucketName'].OutputValue" `
    --output text

if (-not $s3BucketName) {
    Write-ErrorAndExit "Error: Could not find S3 bucket name. Make sure the DynamoDB stack is deployed."
}

# Deploy API (SAM template)
try {
    Write-Host "Deploying API stack..." -ForegroundColor Yellow
    
    # Validate SAM template
    Write-Host "Validating SAM template..." -ForegroundColor Yellow
    sam validate -t ../infrastructure/api.yaml --lint
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorAndExit "SAM template validation failed"
    }

    # Build the SAM application
    Write-Host "Building SAM application..." -ForegroundColor Yellow
    sam build -t ../infrastructure/api.yaml
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorAndExit "SAM build failed"
    }

    # Deploy to AWS
    $deployResult = sam deploy `
        --template-file .aws-sam/build/template.yaml `
        --stack-name "gestor-personal-api-$Environment" `
        --parameter-overrides "ParameterKey=Environment,ParameterValue=$Environment ParameterKey=UserPoolArn,ParameterValue=$userPoolArn ParameterKey=S3BucketName,ParameterValue=$s3BucketName" `
        --capabilities CAPABILITY_IAM `
        --s3-bucket $s3BucketName
    
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorAndExit "SAM deployment failed"
    }

    # Get and display the API URL
    $apiUrl = aws cloudformation describe-stacks `
        --stack-name "gestor-personal-api-$Environment" `
        --query 'Stacks[0].Outputs[?OutputKey==`HelloApi`].OutputValue' `
        --output text

    if (-not $apiUrl) {
        Write-ErrorAndExit "Failed to retrieve API URL after deployment"
    }

    Write-Host "`nAPI stack deployed successfully!" -ForegroundColor Green
    Write-Host "API URL: $apiUrl" -ForegroundColor Cyan
} catch {
    Write-ErrorAndExit "Error deploying API: $($_.Exception.Message)"
}
