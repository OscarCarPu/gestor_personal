# Create the CloudFormation stack
aws --endpoint-url=http://localhost:4566 cloudformation create-stack `
    --stack-name gestor-personal-local `
    --template-body file://infrastructure/dynamodb.yaml `
    --parameters ParameterKey=Environment,ParameterValue=local

# Wait for stack creation to complete
aws --endpoint-url=http://localhost:4566 cloudformation wait stack-create-complete `
    --stack-name gestor-personal-local

# List created resources
Write-Host "`nCreated DynamoDB Tables:"
aws --endpoint-url=http://localhost:4566 dynamodb list-tables

Write-Host "`nCreated S3 Buckets:"
aws --endpoint-url=http://localhost:4566 s3 ls
