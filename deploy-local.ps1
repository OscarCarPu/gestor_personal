# Create the DynamoDB stack

Write-Host "Creating DynamoDB stack..."
aws --endpoint-url=http://localhost:4566 --region eu-souht-2 cloudformation create-stack `
    --stack-name gestor-personal-dynamodb-local `
    --template-body file://infrastructure/dynamodb.yaml `
    --parameters ParameterKey=Environment,ParameterValue=dev

# Wait for DynamoDB stack creation to complete
Write-Host "Waiting for DynamoDB stack creation to complete..."
aws --endpoint-url=http://localhost:4566 --region eu-souht-2 cloudformation wait stack-create-complete `
    --stack-name gestor-personal-dynamodb-local

# If stack creation failed, get the error and exit
$stackStatus = $(aws --endpoint-url=http://localhost:4566 --region eu-souht-2 cloudformation describe-stacks --stack-name gestor-personal-dynamodb-local --query 'Stacks[0].StackStatus' --output text)
if ($stackStatus -eq "CREATE_FAILED") {
    Write-Host "Stack creation failed. Getting error details..."
    aws --endpoint-url=http://localhost:4566 --region eu-souht-2 cloudformation describe-stack-events `
        --stack-name gestor-personal-dynamodb-local `
        --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].ResourceStatusReason' `
        --output text
    exit 1
}

# List created resources
Write-Host "`nCreated DynamoDB Tables:"
aws --endpoint-url=http://localhost:4566 --region eu-south-2 dynamodb list-tables

Write-Host "`nCreated S3 Buckets:"
aws --endpoint-url=http://localhost:4566 --region eu-south-2 s3 ls
