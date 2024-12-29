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

Write-Host "Deploying DynamoDB infrastructure for environment: $Environment..." -ForegroundColor Cyan

# Deploy DynamoDB
try {
    Write-Host "Deploying DynamoDB stack..." -ForegroundColor Yellow
    
    $deployResult = aws cloudformation deploy `
        --stack-name "gestor-personal-dynamodb-$Environment" `
        --template-file ../infrastructure/dynamodb.yaml `
        --parameter-overrides Environment=$Environment `
        --capabilities CAPABILITY_IAM

    if ($LASTEXITCODE -ne 0) {
        Write-ErrorAndExit "Failed to deploy DynamoDB stack"
    }

    Write-Host "DynamoDB stack deployed successfully!" -ForegroundColor Green
} catch {
    Write-ErrorAndExit "Error deploying DynamoDB: $($_.Exception.Message)"
}
