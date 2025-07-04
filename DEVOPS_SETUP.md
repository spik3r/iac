# Azure DevOps Setup Guide

This guide walks you through setting up Azure DevOps pipelines with Terraform for automated CI/CD with semantic versioning.

## Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Azure DevOps Organization** (free at https://dev.azure.com)
3. **Service Principal** for Azure DevOps service connection
4. **Personal Access Token** for Azure DevOps API access

## Step 1: Create Azure DevOps Organization

1. Go to https://dev.azure.com
2. Sign in with your Azure account
3. Create a new organization (e.g., `yourcompany-devops`)
4. Note your organization URL: `https://dev.azure.com/yourcompany-devops`

## Step 2: Create Personal Access Token (PAT)

1. In Azure DevOps, click your profile picture → **Personal access tokens**
2. Click **+ New Token**
3. Configure:
   - **Name**: `Terraform-DevOps-Setup`
   - **Expiration**: 90 days (or custom)
   - **Scopes**: Select **Full access** (or custom with these permissions):
     - Project and team: Read, write, & manage
     - Code: Read & write
     - Build: Read & execute
     - Variable Groups: Read, create, & manage
     - Service Connections: Read, query, & manage
4. Click **Create** and **copy the token** (you won't see it again!)

## Step 3: Create Service Principal for Azure Connection

```bash
# Create service principal for DevOps
az ad sp create-for-rbac \
  --name "sp-devops-vibes-dev" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"

# Output will look like:
# {
#   "appId": "12345678-1234-1234-1234-123456789012",
#   "displayName": "sp-devops-vibes-dev",
#   "password": "your-secret-here",
#   "tenant": "87654321-4321-4321-4321-210987654321"
# }
```

**Save these values:**
- `appId` = Service Principal ID
- `password` = Service Principal Key
- `tenant` = Tenant ID

## Step 4: Configure Terraform Variables

1. Copy the example terraform.tfvars:
   ```bash
   cd environments/dev
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Edit `terraform.tfvars` with your values:
   ```hcl
   # Enable DevOps pipeline creation
   enable_devops_pipeline = true
   
   # Azure DevOps Configuration
   azuredevops_org_service_url       = "https://dev.azure.com/yourcompany-devops"
   azuredevops_personal_access_token = "your-pat-token-from-step-2"
   azure_subscription_name           = "Your Azure Subscription Name"
   
   # Service Principal from Step 3
   devops_service_principal_id  = "12345678-1234-1234-1234-123456789012"
   devops_service_principal_key = "your-secret-here"
   
   # DevOps Settings
   devops_min_reviewers = 1
   ```

## Step 5: Deploy Infrastructure with DevOps

```bash
# Initialize Terraform (if not already done)
terraform init

# Plan the deployment
terraform plan -var-file="terraform.tfvars"

# Apply the configuration
terraform apply -var-file="terraform.tfvars"
```

## What Gets Created

The Terraform deployment will create:

### Azure DevOps Resources
- **Project**: `vibes-dev` (or your project name)
- **Git Repository**: Empty repository for your code
- **Service Connection**: Links Azure DevOps to your Azure subscription
- **Variable Groups**: 
  - `vibes-dev-variables` (common pipeline variables)
  - `vibes-dev-secrets` (ACR credentials)
- **Build Pipelines**:
  - `vibes-build-deploy-dev` (CI/CD pipeline)
  - `vibes-rollback-dev` (rollback pipeline)
- **Branch Policies**: PR requirements and build validation

### Azure Resources
- All existing resources (App Service, ACR, etc.)
- Role assignments for service principal

## Step 6: Push Your Code

1. **Get the Git repository URL** from Terraform output:
   ```bash
   terraform output git_repository_url
   ```

2. **Add the remote and push your code**:
   ```bash
   # In your project root
   git remote add azure-devops <git-repository-url>
   
   # Push your code (including pipeline files)
   git push azure-devops main
   ```

3. **The build pipeline will automatically trigger** when you push to main!

## Step 7: Verify Setup

1. **Check Azure DevOps Project**:
   - Go to your organization URL
   - Open the `vibes-dev` project
   - Verify pipelines are created under **Pipelines**

2. **Test the Build Pipeline**:
   - Make a small change to `app-src/Program.cs`
   - Commit and push to main branch
   - Watch the pipeline run automatically

3. **Test the Rollback Pipeline**:
   - Go to **Pipelines** → **vibes-rollback-dev**
   - Click **Run pipeline**
   - Set parameters and test rollback

## Troubleshooting

### Common Issues

1. **"Personal access token is invalid"**
   - Verify PAT has correct permissions
   - Check PAT hasn't expired
   - Ensure organization URL is correct

2. **"Service principal authentication failed"**
   - Verify service principal has Contributor role
   - Check subscription ID is correct
   - Ensure service principal key is valid

3. **"Project already exists"**
   - Choose a different project name
   - Or delete existing project in Azure DevOps

4. **Pipeline fails with "Repository not found"**
   - Ensure you've pushed code to the Azure DevOps repository
   - Check pipeline YAML files exist in `pipelines/` directory

### Useful Commands

```bash
# Check current Azure context
az account show

# List service principals
az ad sp list --display-name "sp-devops-vibes-dev"

# Test Azure DevOps connection
az devops project list --organization https://dev.azure.com/yourorg

# View Terraform state
terraform state list | grep devops
```

## Security Best Practices

1. **Rotate PAT regularly** (every 90 days)
2. **Use minimal permissions** for service principal
3. **Store secrets securely** in variable groups
4. **Enable branch protection** policies
5. **Review pipeline permissions** regularly

## Next Steps

1. **Set up production environment** with similar configuration
2. **Configure approval gates** for production deployments
3. **Add monitoring and alerting** to pipelines
4. **Implement automated testing** stages
5. **Set up notifications** for build failures

## Cost Considerations

- **Azure DevOps**: Free for up to 5 users with unlimited private repos
- **Build minutes**: 1,800 free minutes/month for private repos
- **Additional costs**: Only if you exceed free tiers

The DevOps setup is now complete! Your infrastructure will automatically build, version, and deploy when you push code to the main branch.