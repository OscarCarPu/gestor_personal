function Write-ErrorAndExit {
    param([string]$message)
    Write-Host $message -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "../infrastructure")) {
    Write-ErrorAndExit "Error: infrastructure directory not found"
}

Write-Host "Deploying local infrastructure..." -ForegroundColor Cyan

# Deploy DynamoDB
try {
    Write-Host "Deploying DynamoDB stack..." -ForegroundColor Yellow
    aws --endpoint-url=http://localhost:4566 --region eu-south-2 cloudformation create-stack `
        --stack-name gestor-personal-dynamodb-local `
        --template-body file://../infrastructure/dynamodb.yaml `
        --parameters ParameterKey=Environment,ParameterValue=dev

    aws --endpoint-url=http://localhost:4566 --region eu-south-2 cloudformation wait stack-create-complete `
        --stack-name gestor-personal-dynamodb-local
} catch {
    Write-ErrorAndExit "Error deploying DynamoDB: $_"
}

# Get the User Pool ARN from AWS
$userPoolArn = aws cloudformation list-exports --query "Exports[?Name=='GestorPersonalUserPoolArn'].Value" --output text

if (-not $userPoolArn) {
    Write-ErrorAndExit "Error: Could not find Cognito User Pool ARN. Make sure the Cognito stack is deployed."
}

# Get the S3 bucket name from local DynamoDB stack
$s3BucketName = aws --endpoint-url=http://localhost:4566 --region eu-south-2 cloudformation describe-stacks `
    --stack-name gestor-personal-dynamodb-local `
    --query "Stacks[0].Outputs[?OutputKey=='ArchiveBucketName'].OutputValue" `
    --output text

if (-not $s3BucketName) {
    Write-ErrorAndExit "Error: Could not find S3 bucket name. Make sure the local DynamoDB stack is deployed."
}

# Deploy API (SAM template)
try {
    Write-Host "Deploying API stack..." -ForegroundColor Yellow
    
    # Build the SAM application
    sam build -t ../infrastructure/api.yaml

    # Deploy locally using SAM CLI
    sam local start-api --template-file .aws-sam/build/template.yaml `
        --parameter-overrides "ParameterKey=Environment,ParameterValue=dev ParameterKey=UserPoolArn,ParameterValue=$userPoolArn ParameterKey=DynamoDBUrl,ParameterValue=http://localhost:4566 ParameterKey=S3BucketName,ParameterValue=$s3BucketName" `
        --warm-containers EAGER
} catch {
    Write-ErrorAndExit "Error deploying API: $_"
}

Write-Host "Local deployment completed successfully!" -ForegroundColor Green
