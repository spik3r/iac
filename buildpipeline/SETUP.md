# Build Pipeline Setup Guide

## Quick Start

### 1. Prerequisites Setup

Create two Azure subscriptions:
- **Admin Subscription** (`iac-admin`): For build infrastructure and central ACR
- **Target Subscription**: For your environments (dev, uat, prod)

### 2. Service Principal Setup

Create service principals for both subscriptions:

```bash
# For admin subscription
az ad sp create-for-rbac --name "vibes-admin-sp" --role "Contributor" --scopes "/subscriptions/YOUR_ADMIN_SUBSCRIPTION_ID"

# For target subscription  
az ad sp create-for-rbac --name "vibes-target-sp" --role "Contributor" --scopes "/subscriptions/YOUR_TARGET_SUBSCRIPTION_ID"
```

### 3. Azure DevOps Setup

1. Create Azure DevOps organization
2. Generate Personal Access Token with:
   - Build (read & execute)
   - Code (read)
   - Project and team (read, write & manage)
   - Service connections (read, query & manage)

### 4. Configuration

```bash
# Copy example configuration
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
vim terraform.tfvars
```

Required values:
- Subscription IDs and names
- Service principal credentials
- Azure DevOps organization URL and PAT
- GitHub repository (if using GitHub)

### 5. Deploy Infrastructure

```bash
# Validate configuration
make validate

# Plan deployment
make plan-buildpipeline

# Apply infrastructure
make apply-buildpipeline
```

### 6. Verify Setup

After deployment:
1. Check Azure DevOps project is created
2. Verify service connections work
3. Check admin ACR is accessible
4. Test pipeline creation

## Environment Variables Required

| Variable | Description | Example |
|----------|-------------|---------|
| `admin_subscription_id` | Admin subscription ID | `12345678-1234-1234-1234-123456789012` |
| `target_subscription_id` | Target subscription ID | `87654321-4321-4321-4321-210987654321` |
| `azuredevops_org_service_url` | DevOps org URL | `https://dev.azure.com/myorg` |
| `github_repo_name` | GitHub repo | `myorg/myrepo` |

## Next Steps

1. Configure your existing dev environment variables in `terraform.tfvars`
2. Run the build pipeline to test image building
3. Set up additional environments (uat, prod)
4. Configure approval gates for production deployments

## Troubleshooting

### Common Issues

1. **Service Principal Permissions**: Ensure SPs have Contributor role on respective subscriptions
2. **DevOps PAT**: Verify PAT has correct scopes and hasn't expired
3. **GitHub Access**: Check GitHub PAT has repo access if using GitHub integration
4. **ACR Access**: Verify admin user is enabled on container registries

### Validation Commands

```bash
# Test Azure CLI access
az account show --subscription YOUR_ADMIN_SUBSCRIPTION_ID
az account show --subscription YOUR_TARGET_SUBSCRIPTION_ID

# Test service principal login
az login --service-principal -u SP_ID -p SP_SECRET --tenant TENANT_ID

# Test DevOps access
az extension add --name azure-devops
az devops project list --organization YOUR_DEVOPS_ORG
```