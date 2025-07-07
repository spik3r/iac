# Build Pipeline Infrastructure

This directory contains Terraform infrastructure for managing Azure DevOps build pipelines and a centralized Container Registry in an admin subscription.

## Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Admin Sub     │    │   Target Sub    │    │   Target Sub    │
│   (iac-admin)   │    │     (dev)       │    │    (prod)       │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ Central ACR     │───▶│ Environment ACR │    │ Environment ACR │
│ Build Pipelines │    │ App Services    │    │ App Services    │
│ DevOps Project  │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Key Features

- **Centralized Build**: All builds happen in the admin subscription
- **Semantic Versioning**: Automatic version tagging based on Git tags
- **Multi-Environment**: Deploy to dev, uat, prod with image promotion
- **Security**: Images are scanned and tested before deployment
- **Rollback**: Easy deployment of previous versions

## Components

### Infrastructure (Terraform)
- **Admin ACR**: Central container registry for all built images
- **DevOps Project**: Azure DevOps project with pipelines
- **Service Connections**: Connections to admin and target subscriptions
- **Variable Groups**: Centralized configuration management

### Pipelines

#### 1. Build-Deploy Pipeline (`build-deploy.yml`)
- **Trigger**: Main/develop branch changes
- **Process**:
  1. Generate semantic version
  2. Build and push to admin ACR
  3. Copy image to dev ACR
  4. Deploy to dev environment
  5. Run health checks

#### 2. PR Pipeline (`pr.yml`)
- **Trigger**: Pull requests
- **Process**:
  1. Build image (no push)
  2. Run tests and security scans
  3. Optional manual deployment to dev for testing

#### 3. Deploy Pipeline (`deploy.yml`)
- **Trigger**: Manual only
- **Process**:
  1. Validate version exists in admin ACR
  2. Copy to target environment ACR (if needed)
  3. Deploy to specified environment
  4. Run health checks

## Setup Instructions

### 1. Prerequisites

- Azure CLI installed and configured
- Terraform >= 1.0
- Two Azure subscriptions:
  - Admin subscription (for builds and central ACR)
  - Target subscription (for environments)
- Service principals with appropriate permissions
- Azure DevOps organization
- GitHub repository (optional)

### 2. Configure Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and update:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 3. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="terraform.tfvars"

# Apply infrastructure
terraform apply -var-file="terraform.tfvars"
```

### 4. Configure Backend (Optional)

Create a backend configuration file:

```hcl
# backend.conf
resource_group_name  = "your-terraform-state-rg"
storage_account_name = "yourtfstate"
container_name       = "buildpipeline"
key                  = "terraform.tfstate"
```

Initialize with backend:
```bash
terraform init -backend-config="backend.conf"
```

## Usage

### Building and Deploying

1. **Automatic Build**: Push to main/develop branch triggers build-deploy pipeline
2. **Manual Deploy**: Use deploy pipeline to deploy specific versions
3. **PR Testing**: Create PR to trigger testing pipeline

### Version Management

- **Semantic Versioning**: `v1.2.3` format
- **Auto-increment**: Patch version incremented automatically
- **Manual Tagging**: Create Git tag for specific version
- **Latest**: Always available as `latest` tag

### Environment Promotion

```bash
# Deploy latest to dev (automatic)
git push origin main

# Deploy specific version to uat
# Use deploy pipeline with parameters:
# - targetVersion: v1.2.3
# - targetEnvironment: uat

# Deploy to production
# Use deploy pipeline with parameters:
# - targetVersion: v1.2.3
# - targetEnvironment: prod
```

## Pipeline Parameters

### Deploy Pipeline Parameters

| Parameter | Description | Default | Options |
|-----------|-------------|---------|---------|
| `targetVersion` | Version to deploy | `latest` | Any valid version tag |
| `targetEnvironment` | Target environment | `dev` | `dev`, `uat`, `prod` |
| `forceRedeploy` | Force redeploy existing version | `false` | `true`, `false` |

## Security Features

- **Image Scanning**: Trivy security scanning in PR pipeline
- **Access Control**: Service principals with minimal permissions
- **Secret Management**: Secrets stored in Azure DevOps variable groups
- **Environment Gates**: Manual approval for production deployments

## Monitoring and Troubleshooting

### Health Checks
All deployments include automatic health checks at `/version/health` endpoint.

### Rollback Process
1. Identify previous working version
2. Run deploy pipeline with previous version number
3. Verify health checks pass

### Common Issues

1. **Image not found**: Check if version exists in admin ACR
2. **Health check fails**: Check application logs in App Service
3. **Permission denied**: Verify service principal permissions

## Cost Optimization

- **Geo-replication**: Configure only for production workloads
- **ACR SKU**: Use Basic for dev, Standard/Premium for production
- **Image cleanup**: Implement retention policies for old images

## Next Steps

1. Add UAT and Production environment configurations
2. Implement automated testing in PR pipeline
3. Add monitoring and alerting
4. Configure retention policies for container images
5. Add approval gates for production deployments