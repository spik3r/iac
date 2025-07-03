# Vibes Infrastructure as Code

A comprehensive Terraform project for deploying a .NET 8 web application to Azure App Service with multiple environments (dev/prod), using Azure remote state with the bootstrap pattern.

## Project Structure

```
├── bootstrap/              # Bootstrap infrastructure for Terraform state
├── environments/
│   ├── dev/                # Development environment
│   └── prod/               # Production environment
├── modules/
│   ├── app-service/        # App Service module for .NET 8 web apps
│   ├── container-registry/ # Azure Container Registry module
│   └── networking/         # Virtual network and security groups
├── app-src/                # Example .NET 8 application source code
├── Makefile               # Common operations
└── README.md              # This file
```

## Architecture Overview

This project implements a multi-environment Azure infrastructure with:

- **Bootstrap Pattern**: Separate Terraform configuration to create remote state storage
- **Modular Design**: Reusable modules for networking, container registry, and app services
- **Environment Separation**: Isolated dev and prod environments with different configurations
- **Security**: VNet integration, managed identities, and proper RBAC
- **Container Support**: Azure Container Registry with App Service integration

### Key Components

1. **Azure Container Registry (ACR)**: Stores Docker images for the application
2. **App Service**: Linux-based web app running containerized .NET 8 application
3. **Virtual Network**: Provides network isolation and security
4. **Managed Identity**: Secure authentication between services
5. **Remote State**: Centralized Terraform state management in Azure Storage

## Prerequisites (macOS)

### 1. Install Required Tools

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Terraform
brew install terraform

# Install Azure CLI
brew install azure-cli

# Install .NET 8 SDK (for building the sample app)
brew install --cask dotnet

# Install Docker (for building container images)
brew install --cask docker
```

### 2. Verify Installations

```bash
terraform --version    # Should show v1.0+
az --version          # Should show Azure CLI
dotnet --version      # Should show .NET 8.x
docker --version      # Should show Docker
```

### 3. Azure Authentication

```bash
# Login to Azure
az login

# Set your subscription (replace with your subscription ID)
az account set --subscription "your-subscription-id"

# Verify current subscription
az account show
```

## Setup Instructions

### Step 1: Bootstrap Remote State

The bootstrap process creates the Azure Storage Account for Terraform remote state.

```bash
# Navigate to bootstrap directory
cd bootstrap

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the bootstrap configuration
terraform apply

# Note the outputs - you'll need these for the next steps
terraform output
```

### Step 2: Configure Backend for Environments

After bootstrap completes, create backend configuration files for each environment:

```bash
# Create backend config for dev environment
cat > environments/dev/backend.conf << EOF
resource_group_name  = "rg-terraform-state"
storage_account_name = "tfstate[random-suffix]"  # Use output from bootstrap
container_name       = "tfstate"
key                  = "dev/terraform.tfstate"
EOF

# Create backend config for prod environment
cat > environments/prod/backend.conf << EOF
resource_group_name  = "rg-terraform-state"
storage_account_name = "tfstate[random-suffix]"  # Use output from bootstrap
container_name       = "tfstate"
key                  = "prod/terraform.tfstate"
EOF
```

### Step 3: Deploy Development Environment

```bash
# Navigate to dev environment
cd environments/dev

# Initialize with remote backend
terraform init -backend-config=backend.conf

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Note the app service URL from outputs
terraform output app_service_url
```

### Step 4: Deploy Production Environment

```bash
# Navigate to prod environment
cd environments/prod

# Initialize with remote backend
terraform init -backend-config=backend.conf

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Note the app service URL from outputs
terraform output app_service_url
```

## Building and Deploying Custom Application

### Option 1: Using the Sample Application

The project includes a sample .NET 8 web API in the `app-src/` directory.

```bash
# Navigate to app source
cd app-src

# Build and test locally
dotnet build
dotnet run

# Build Docker image
docker build -t vibes-app:latest .

# Tag for ACR (replace with your ACR name from terraform output)
docker tag vibes-app:latest [your-acr-name].azurecr.io/vibes-app:latest

# Login to ACR
az acr login --name [your-acr-name]

# Push to ACR
docker push [your-acr-name].azurecr.io/vibes-app:latest
```

### Option 2: Update Terraform to Use Custom Image

Update the `docker_image` variable in your environment's `terraform.tfvars`:

```hcl
docker_image = "[your-acr-name].azurecr.io/vibes-app:latest"
```

Then apply the changes:

```bash
terraform plan
terraform apply
```

## Common Operations

### Using the Makefile

```bash
# Format all Terraform files
make fmt

# Validate all configurations
make validate

# Plan dev environment
make plan-dev

# Apply dev environment
make apply-dev

# Plan prod environment
make plan-prod

# Apply prod environment
make apply-prod

# Destroy dev environment (be careful!)
make destroy-dev
```

### Manual Operations

```bash
# Format Terraform files
terraform fmt -recursive

# Validate configuration
terraform validate

# Plan with variable file
terraform plan -var-file="terraform.tfvars"

# Apply with auto-approve
terraform apply -var-file="terraform.tfvars" -auto-approve

# Show current state
terraform show

# List resources
terraform state list

# Destroy infrastructure (be very careful!)
terraform destroy -var-file="terraform.tfvars"
```

## Environment Differences

| Component | Development | Production |
|-----------|-------------|------------|
| App Service SKU | B1 (Basic) | P1v3 (Premium) |
| ACR SKU | Basic | Standard |
| Always On | Disabled | Enabled |
| Admin User | Enabled | Disabled |
| Logging Level | Information | Warning |
| VNet Address | 10.0.0.0/16 | 10.1.0.0/16 |

## Security Considerations

1. **Managed Identity**: App Service uses system-assigned managed identity for ACR access
2. **VNet Integration**: App Service is integrated with a dedicated subnet
3. **Private Networking**: Container registry can be configured for private access
4. **RBAC**: Minimal required permissions using Azure RBAC
5. **Secrets**: No hardcoded secrets; uses Azure Key Vault integration where needed

## Troubleshooting

### Common Issues

1. **Terraform State Lock**: If state is locked, use `terraform force-unlock [LOCK_ID]`
2. **ACR Authentication**: Ensure `az acr login` is successful before pushing images
3. **App Service Deployment**: Check deployment logs in Azure Portal
4. **Network Connectivity**: Verify VNet integration and NSG rules

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Import existing resource
terraform import azurerm_resource_group.example /subscriptions/[sub-id]/resourceGroups/[rg-name]

# Refresh state
terraform refresh

# Show specific resource
terraform state show azurerm_linux_web_app.main
```

## Next Steps

1. **CI/CD Pipeline**: Implement Azure DevOps or GitHub Actions for automated deployments
2. **Monitoring**: Add Application Insights and Log Analytics
3. **Scaling**: Configure auto-scaling rules for production
4. **Security**: Implement Azure Key Vault for secrets management
5. **Backup**: Configure backup policies for critical resources
6. **Custom Domain**: Add custom domain and SSL certificates

## Contributing

1. Follow the existing module structure
2. Update documentation for any new features
3. Test changes in development environment first
4. Use consistent naming conventions
5. Add appropriate tags to all resources

## Support

For issues and questions:
1. Check the troubleshooting section above
2. Review Azure documentation for specific services
3. Check Terraform Azure provider documentation
4. Create an issue in the project repository