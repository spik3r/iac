# Vibes Infrastructure as Code

This repository contains the Terraform infrastructure code for the Vibes application, including Azure App Service, Container Registry, networking components, and Azure DevOps CI/CD pipelines with GitHub integration.

## 🚀 Current Status - DEPLOYED ✅

**The infrastructure is already deployed and ready to use:**

- **App Service**: https://vibes-dev-app.azurewebsites.net
- **Azure DevOps Project**: https://dev.azure.com/kaiftait/vibes-dev
- **Container Registry**: vibesacrdev.azurecr.io
- **GitHub Repository**: https://github.com/spik3r/iac

### Active Pipelines
- ✅ **Build-Deploy Pipeline**: Auto-triggers on commits to main branch
- ✅ **Rollback Pipeline**: Manual trigger for deploying previous versions
- ✅ **GitHub Integration**: Pipelines pull from private GitHub repo

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Docker](https://docs.docker.com/get-docker/)
- Azure subscription with appropriate permissions
- Azure DevOps organization (for CI/CD pipelines)
- GitHub repository (for source code)

## 📋 Complete Setup Process (Already Done)

The following steps have already been completed for this project:

### 1. Bootstrap Infrastructure ✅
```bash
cd bootstrap
terraform init
terraform apply
```

### 2. Deploy Development Environment ✅
```bash
cd environments/dev
terraform init -backend-config=backend.conf
terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"
```

### 3. Configure Azure DevOps Integration ✅
- Created Azure DevOps project: `vibes-dev`
- Set up GitHub service connection with PAT
- Created variable groups with ACR credentials
- Deployed build-deploy and rollback pipelines

### 4. GitHub Repository Setup ✅
- Repository: `spik3r/iac` (private)
- Pipeline YAML files committed and pushed
- GitHub PAT configured for Azure DevOps access

## 🔧 Current Configuration

### Infrastructure Components
- **Resource Group**: `vibes-dev-rg`
- **App Service Plan**: `vibes-dev-asp` (B1 SKU)
- **Web App**: `vibes-dev-app`
- **Container Registry**: `vibesacrdev` (Basic SKU)
- **Virtual Network**: `vibes-dev-vnet` (10.0.0.0/16)
- **Subnets**: App Service (10.0.1.0/24), Private Endpoints (10.0.2.0/24)

### DevOps Configuration
- **Organization**: https://dev.azure.com/kaiftait
- **Project**: vibes-dev
- **Source**: GitHub repository (spik3r/iac)
- **Pipelines**: Build-Deploy, Rollback
- **Versioning**: Semantic versioning (v1.x.x)

## 🚀 Quick Start (For New Changes)

Since the infrastructure is already deployed, you can:

1. **Make code changes** to your application
2. **Commit and push** to the main branch
3. **Watch the pipeline** automatically build and deploy

```bash
# Make your changes
git add .
git commit -m "Your changes"
git push origin main

# Monitor the pipeline at:
# https://dev.azure.com/kaiftait/vibes-dev/_build
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

## 🔄 DevOps Pipelines (Active)

This project includes Azure DevOps pipelines for automated CI/CD with semantic versioning and GitHub integration:

### Active Pipeline Features

1. **Build & Deploy Pipeline** (`pipelines/build-deploy.yml`) - **DEPLOYED** ✅:
   - **Trigger**: Automatic on commits to main branch
   - **Versioning**: Semantic versioning (v1.2.3 format)
   - **Build**: Docker image build and push to ACR
   - **Deploy**: Automated deployment to dev environment
   - **Promotion**: Optional promotion to production
   - **Verification**: Health checks after deployment

2. **Rollback Pipeline** (`pipelines/rollback.yml`) - **DEPLOYED** ✅:
   - **Trigger**: Manual execution only
   - **Target**: Deploy any previous semantic version
   - **Safety**: Confirmation prompts required
   - **Validation**: Verifies target image exists in ACR
   - **Monitoring**: Post-rollback health checks

### Semantic Versioning Strategy

- **Format**: `v{major}.{minor}.{patch}` (e.g., `v1.2.3`)
- **Auto-increment**: Patch version increments automatically on main branch commits
- **Manual versioning**: Create Git tags for major/minor version bumps
- **Latest tag**: Always points to the most recent stable release

### GitHub Integration (Active)

- **Source Repository**: `spik3r/iac` (private GitHub repo)
- **Service Connection**: GitHub PAT authentication
- **Branch Monitoring**: Main branch for automatic builds
- **Status Reporting**: Build status reported back to GitHub

### Pipeline URLs
- **Build-Deploy**: https://dev.azure.com/kaiftait/vibes-dev/_build?definitionId=3
- **Rollback**: https://dev.azure.com/kaiftait/vibes-dev/_build?definitionId=2

### How to Use

**Automatic Deployment:**
```bash
# Any commit to main triggers build-deploy pipeline
git add .
git commit -m "feat: add new feature"
git push origin main
```

**Manual Rollback:**
1. Go to Azure DevOps project
2. Run "vibes-rollback-dev" pipeline
3. Specify target version (e.g., v1.0.5)
4. Confirm deployment

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

## 📚 Setup Instructions (Reference)

**Note**: The infrastructure is already deployed. These instructions are for reference or replicating the setup.

### Step 1: Bootstrap Remote State ✅ COMPLETED

The bootstrap process creates the Azure Storage Account for Terraform remote state.

```bash
cd bootstrap
terraform init
terraform plan
terraform apply
terraform output  # Note the storage account name
```

### Step 2: Configure Backend for Environments ✅ COMPLETED

Backend configuration files are already created:
- `environments/dev/backend.conf`
- `environments/prod/backend.conf`

### Step 3: Deploy Development Environment ✅ COMPLETED

```bash
cd environments/dev
terraform init -backend-config=backend.conf

# Create secrets.tfvars with sensitive values (already done)
# terraform.tfvars contains public configuration

# Deploy infrastructure and DevOps pipelines
terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"
```

**Current dev environment outputs:**
- App Service URL: https://vibes-dev-app.azurewebsites.net
- Container Registry: vibesacrdev.azurecr.io
- DevOps Project: https://dev.azure.com/kaiftait/vibes-dev

### Step 4: Azure DevOps Integration ✅ COMPLETED - FULLY AUTOMATED

The DevOps module has been deployed with **zero manual steps required**:

```hcl
# Key configuration in terraform.tfvars
enable_devops_pipeline = true
devops_use_github_repo = true
github_repo_name = "spik3r/iac"
devops_create_pipelines = true

# Sensitive values in secrets.tfvars
azuredevops_personal_access_token = "***"  # Full access PAT
github_personal_access_token = "***"       # repo + admin:repo_hook permissions
devops_service_principal_key = "***"       # Service principal key
```

**Automated Features:**
- ✅ **CI Triggers**: Automatically enabled via `ci_trigger { use_yaml = true }`
- ✅ **Pipeline Authorization**: Auto-grants GitHub service connection access
- ✅ **Webhook Setup**: GitHub webhooks configured automatically
- ✅ **No Manual Steps**: No "Authorize" buttons to click in Azure DevOps

### Step 5: Production Environment (Optional)

Production environment can be deployed similarly:

```bash
cd environments/prod
terraform init -backend-config=backend.conf
terraform plan -var-file="terraform.tfvars"
terraform apply -var-file="terraform.tfvars"
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

## 🔧 Fully Automated Setup Features

This template provides **100% Infrastructure as Code** with zero manual steps:

### ✅ **Automated CI/CD Setup**
- **GitHub Integration**: Service connections auto-configured with PAT authentication
- **Pipeline Authorization**: Terraform automatically grants pipeline access to GitHub
- **CI Triggers**: Webhooks and triggers enabled automatically via YAML configuration
- **Variable Groups**: ACR credentials and Azure service connections pre-configured

### ✅ **Zero Manual Steps Required**
- ❌ No "Authorize" buttons to click in Azure DevOps
- ❌ No manual webhook configuration in GitHub
- ❌ No manual service connection setup
- ❌ No manual pipeline permissions configuration

### 🔑 **Required Permissions**
For full automation, ensure your tokens have these permissions:

**GitHub PAT** (`github_personal_access_token`):
- `repo` - Full repository access
- `admin:repo_hook` - Webhook management

**Azure DevOps PAT** (`azuredevops_personal_access_token`):
- Full access (or minimum: Build, Code, Project and Team, Service Connections)

## 🎯 Next Steps

### Immediate Actions Available
1. **Test the Pipeline**: Make a commit to trigger automatic build-deploy
2. **Monitor Deployments**: Watch pipeline runs in Azure DevOps
3. **Deploy to Production**: Apply the prod environment configuration
4. **Custom Application**: Replace sample app with your actual application

### Future Enhancements
1. **Monitoring**: Add Application Insights and Log Analytics
2. **Scaling**: Configure auto-scaling rules for production
3. **Security**: Implement Azure Key Vault for secrets management
4. **Backup**: Configure backup policies for critical resources
5. **Custom Domain**: Add custom domain and SSL certificates
6. **Multi-Environment**: Extend pipelines for staging/prod promotion

### Testing Your Setup

```bash
# Test the automatic pipeline
echo "# Test change" >> README.md
git add README.md
git commit -m "test: trigger pipeline"
git push origin main

# Monitor at: https://dev.azure.com/kaiftait/vibes-dev/_build
```

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