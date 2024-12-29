# Create the Cognito stack
Write-Host "Creating Cognito stack..."
aws cloudformation create-stack `
    --stack-name gestor-personal-auth-dev `
    --template-body file://infrastructure/cognito.yaml `
    --parameters ParameterKey=Environment,ParameterValue=dev `
    --capabilities CAPABILITY_IAM

# Wait for Cognito stack creation to complete
Write-Host "Waiting for Cognito stack creation to complete..."
aws cloudformation wait stack-create-complete `
    --stack-name gestor-personal-auth-dev

# If stack creation failed, get the error and exit
$stackStatus = $(aws cloudformation describe-stacks --stack-name gestor-personal-auth-dev --query 'Stacks[0].StackStatus' --output text)
if ($stackStatus -eq "CREATE_FAILED") {
    Write-Host "Stack creation failed. Getting error details..."
    aws cloudformation describe-stack-events `
        --stack-name gestor-personal-auth-dev `
        --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`].ResourceStatusReason' `
        --output text
    exit 1
}

# Get the User Pool ID and Client ID from stack outputs
$USER_POOL_ID = $(aws cloudformation describe-stacks --stack-name gestor-personal-auth-dev --query 'Stacks[0].Outputs[?ExportName==`GestorPersonalUserPoolId`].OutputValue' --output text)
$CLIENT_ID = $(aws cloudformation describe-stacks --stack-name gestor-personal-auth-dev --query 'Stacks[0].Outputs[?ExportName==`GestorPersonalUserPoolClientId`].OutputValue' --output text)
$POOL_ARN = $(aws cloudformation describe-stacks --stack-name gestor-personal-auth-dev --query 'Stacks[0].Outputs[?ExportName==`GestorPersonalUserPoolArn`].OutputValue' --output text)

# Create a test user in Cognito
Write-Host "`nCreating test user in Cognito..."
aws cognito-idp sign-up `
    --client-id $CLIENT_ID `
    --username "test" `
    --password "Abc123.." `
    --user-attributes Name=name,Value="Test User"

# Auto-confirm the test user (bypass email verification)
aws cognito-idp admin-confirm-sign-up `
    --user-pool-id $USER_POOL_ID `
    --username "test"

Write-Host "Test user created successfully with:"
Write-Host "Username: test"
Write-Host "Password: Abc123.."

# Update .env file with USER_POOL_ID and CLIENT_ID
Write-Host "`nUpdating .env file with Cognito credentials..."
$envContent = Get-Content .env
$envContent = $envContent | ForEach-Object {
    if ($_ -match '^USER_POOL_ID=') {
        "USER_POOL_ID=`"$USER_POOL_ID`""
    }
    elseif ($_ -match '^CLIENT_ID=') {
        "CLIENT_ID=`"$CLIENT_ID`""
    }
    elseif ($_ -match '^POOL_ARN=') {
        "POOL_ARN=`"$POOL_ARN`""
    }
    else {
        $_
    }
}
$envContent | Set-Content .env

Write-Host "Environment variables updated successfully!"
