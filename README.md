# Vibes Infrastructure as Code

This repository contains the Terraform infrastructure code for the Vibes application, including Azure App Service, Container Registry, and networking components.

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://docs.docker.com/get-docker/)
- Azure subscription with appropriate permissions

## Quick Start

1. **Login to Azure**
   ```bash
   az login
   ```

2. **Bootstrap the remote state infrastructure**
   ```bash
   make bootstrap
   ```

3. **Deploy to development environment**
   ```bash
   make apply-dev
   ```

## Docker Commands

### Build and Push Application Image

```bash
# Build the Docker image for Linux/AMD64 platform with semantic versioning
cd app-src
docker build -t vibesacrdev/vibes-app:v1.0.0 . --platform=linux/amd64
docker build -t vibesacrdev/vibes-app:latest . --platform=linux/amd64

# Push to Azure Container Registry
docker push vibesacrdev.azurecr.io/vibes-app:v1.0.0
docker push vibesacrdev.azurecr.io/vibes-app:latest

# Alternative: Use Azure CLI to build and push directly
az acr build --registry vibesacrdev --image vibes-app:v1.0.0 .
az acr build --registry vibesacrdev --image vibes-app:latest .
```

## DevOps Pipelines

This project includes Azure DevOps pipelines for automated CI/CD with semantic versioning:

### Pipeline Features

1. **Build & Deploy Pipeline** (`pipelines/build-deploy.yml`):
   - Automatic semantic versioning (v1.2.3 format)
   - Docker image build and push to ACR
   - Automated deployment to dev environment
   - Optional promotion to production
   - Health checks after deployment

2. **Rollback Pipeline** (`pipelines/rollback.yml`):
   - Deploy any previous semantic version
   - Safety confirmations required
   - Verification that target image exists in ACR
   - Post-rollback health checks

### Semantic Versioning Strategy

- **Format**: `v{major}.{minor}.{patch}` (e.g., `v1.2.3`)
- **Auto-increment**: Patch version increments automatically on main branch commits
- **Manual versioning**: Create Git tags for major/minor version bumps
- **Latest tag**: Always points to the most recent stable release

### Using the DevOps Module

Add the DevOps pipeline module to your environment:

```hcl
module "devops_pipeline" {
  source = "../../modules/devops-pipeline"
  
  project_name             = var.project_name
  environment             = var.environment
  location                = var.location
  tags                    = local.common_tags
  
  subscription_id         = data.azurerm_client_config.current.subscription_id
  subscription_name       = "Your Subscription Name"
  tenant_id              = data.azurerm_client_config.current.tenant_id
  
  service_principal_id    = var.devops_service_principal_id
  service_principal_key   = var.devops_service_principal_key
  
  resource_group_name     = module.app_service.resource_group_name
  container_registry_name = module.container_registry.name
  app_service_name        = module.app_service.name
  
  acr_admin_username      = module.container_registry.admin_username
  acr_admin_password      = module.container_registry.admin_password
}
```

## Project Structure

```
├── bootstrap/          # Remote state infrastructure
├── environments/       # Environment-specific configurations
│   ├── dev/           # Development environment
│   └── prod/          # Production environment
├── modules/           # Reusable Terraform modules
│   ├── app-service/   # Azure App Service module
│   ├── container-registry/ # Azure Container Registry module
│   └── networking/    # Virtual network and security groups
└── app-src/          # Application source code and Dockerfile
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

### Building and Deploying the Sample Application

The project includes a sample .NET 8 web API in the `app-src/` directory.

**Step 1: Build and push the Docker image**

```bash
# Navigate to app source
cd app-src

# Build and test locally (optional)
dotnet build
dotnet run

# Build Docker image
docker build -t vibes-app:latest .

# Get your ACR name from terraform output
cd ../environments/dev
ACR_NAME=$(terraform output -raw container_registry_name)

# Login to ACR
az acr login --name $ACR_NAME

# Tag and push to ACR
docker tag vibes-app:latest $ACR_NAME.azurecr.io/vibes-app:latest
docker push $ACR_NAME.azurecr.io/vibes-app:latest
```

**Step 2: Deploy with Terraform**

The `docker_image` variable in your environment's `terraform.tfvars` should only contain the image name and tag:

```hcl
docker_image = "vibes-app:latest"
```

The ACR registry URL is automatically constructed by the Terraform configuration.

```bash
# Apply the infrastructure changes
terraform plan
terraform apply
```

**Important:** You must push the Docker image to ACR before the App Service can successfully start.

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
| Location | Australia East | Australia East |

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