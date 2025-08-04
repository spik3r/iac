# Build Pipeline Setup Guide

This guide walks you through setting up the Azure DevOps build pipeline infrastructure.

## 🎯 **What This Creates**

- **Azure DevOps Project** with pipelines
- **Admin Container Registry** (central build registry)
- **Service Connections** to Azure subscriptions
- **GitHub Integration** for source control
- **Build Pipelines** for CI/CD
- **Variable Groups** with secrets

## 📋 **Prerequisites**

### **1. Azure Subscriptions**
You need access to:
- **Admin Subscription** (for build infrastructure)
- **Target Subscription** (where your dev/prod environments live)

### **2. Azure DevOps Organization**
- Create or have access to an Azure DevOps organization
- Admin permissions to create projects and pipelines

### **3. GitHub Repository**
- Repository with your code (this repo)
- Admin access to create webhooks and tokens

## 🔑 **Required Credentials**

### **Step 1: Get Azure Subscription Information**

```bash
# Login and list subscriptions
az login
az account list --output table

# Note down:
# - Subscription IDs
# - Subscription Names
# - Tenant ID
```

### **Step 2: Create Service Principals**

You need **two service principals** - one for each subscription:

#### **Admin Subscription Service Principal**
```bash
# Set the admin subscription
az account set --subscription "your-admin-subscription-id"

# Create service principal
az ad sp create-for-rbac --name "vibes-admin-sp" --role "Contributor" --scopes "/subscriptions/your-admin-subscription-id"

# Note down:
# - appId (client_id)
# - password (client_secret)
# - tenant
```

#### **Target Subscription Service Principal**
```bash
# Set the target subscription
az account set --subscription "your-target-subscription-id"

# Create service principal
az ad sp create-for-rbac --name "vibes-target-sp" --role "Contributor" --scopes "/subscriptions/your-target-subscription-id"

# Note down:
# - appId (client_id)
# - password (client_secret)
# - tenant
```

### **Step 3: Get Azure DevOps Personal Access Token**

1. Go to **Azure DevOps** → **User Settings** → **Personal Access Tokens**
2. Click **"New Token"**
3. Set **Name**: `vibes-terraform-pat`
4. Set **Expiration**: 1 year
5. Set **Scopes**: **Full access** (or custom with these permissions):
   - **Project and Team**: Read, write, & manage
   - **Build**: Read & execute
   - **Release**: Read, write, execute, & manage
   - **Service Connections**: Read, query, & manage
   - **Variable Groups**: Read, create, & manage

6. **Copy the token** - you won't see it again!

### **Step 4: Get GitHub Personal Access Token**

1. Go to **GitHub** → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Click **"Generate new token (classic)"**
3. Set **Note**: `vibes-azure-devops`
4. Set **Expiration**: 1 year
5. Select **Scopes**:
   - `repo` (Full control of private repositories)
   - `admin:repo_hook` (Full control of repository hooks)
   - `read:user` (Read user profile data)

6. **Copy the token**

## 📝 **Configuration Files**

### **Step 5: Create Configuration Files**

```bash
cd buildpipeline

# Copy example files
cp terraform.tfvars.example terraform.tfvars
cp secrets.tfvars.example secrets.tfvars  # If it exists, or create it
```

### **Step 6: Fill in terraform.tfvars**

```hcl
# Project Configuration
project_name = "vibes"
location     = "Australia East"  # Or your preferred region

# Admin Subscription (where build infrastructure lives)
admin_subscription_id   = "your-admin-subscription-id"
admin_subscription_name = "iac-admin"  # Or your admin subscription name

# Target Subscription (where dev/prod environments live)
target_subscription_id   = "your-target-subscription-id"
target_subscription_name = "your-target-subscription-name"

# Azure AD Tenant
tenant_id = "your-tenant-id"

# Azure DevOps Configuration
azuredevops_org_service_url = "https://dev.azure.com/your-org-name"

# GitHub Configuration
use_github_repo = true
github_repo_name = "spik3r/iac"  # Your GitHub repo

# Container Registry Configuration
admin_acr_sku = "Standard"
docker_image_name = "vibes-app"

# Target Environment Configuration (from your existing dev environment)
dev_resource_group_name     = "vibes-dev-rg"
dev_container_registry_name = "vibesacrdev"
dev_app_service_name        = "vibes-dev-app"

# Pipeline Configuration
create_pipelines = true

# Tags
tags = {
  Environment = "admin"
  Project     = "vibes"
  ManagedBy   = "terraform"
  Purpose     = "build-pipeline"
}
```

### **Step 7: Create secrets.tfvars**

```hcl
# Service Principal Credentials
admin_service_principal_id  = "your-admin-sp-app-id"
admin_service_principal_key = "your-admin-sp-password"

target_service_principal_id  = "your-target-sp-app-id"
target_service_principal_key = "your-target-sp-password"

# Azure DevOps PAT
azuredevops_personal_access_token = "your-azure-devops-pat"

# GitHub PAT
github_personal_access_token = "your-github-pat"
```

## 🚀 **Deploy the Build Pipeline**

### **Step 8: Initialize and Deploy**

```bash
cd buildpipeline

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Apply the deployment
terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"
```

### **Step 9: Verify Deployment**

After successful deployment, check:

1. **Azure DevOps Project**: Go to your Azure DevOps org and verify the project was created
2. **Service Connections**: Check that Azure service connections are working
3. **GitHub Connection**: Verify GitHub service connection
4. **Pipelines**: Check that build pipelines were created
5. **Container Registry**: Verify admin ACR was created

## 🔧 **Post-Deployment Configuration**

### **Step 10: Test the Pipeline**

1. **Trigger a Build**: Push a commit to your GitHub repo
2. **Check Pipeline**: Go to Azure DevOps → Pipelines and watch the build
3. **Verify ACR**: Check that Docker images are pushed to the admin ACR
4. **Test Deployment**: Verify deployment to your dev environment

### **Step 11: Configure Branch Policies** (Optional)

1. Go to **Azure DevOps** → **Repos** → **Branches**
2. Set up **branch policies** for main branch
3. Require **pull request reviews**
4. Require **build validation**

## 🔍 **Troubleshooting**

### **Common Issues**

1. **Service Principal Permissions**
   - Ensure SPs have Contributor role on their respective subscriptions
   - Check that tenant ID is correct

2. **Azure DevOps PAT Issues**
   - Verify PAT has correct scopes
   - Check PAT hasn't expired
   - Ensure you're using the correct organization URL

3. **GitHub Integration Issues**
   - Verify GitHub PAT has correct permissions
   - Check repository name format (owner/repo)
   - Ensure repository is accessible

4. **Resource Naming Conflicts**
   - ACR names must be globally unique
   - Modify project_name if resources already exist

### **Validation Commands**

```bash
# Test Azure CLI access
az account show

# Test service principal login
az login --service-principal -u "your-sp-app-id" -p "your-sp-password" --tenant "your-tenant-id"

# Test Azure DevOps connection
curl -u ":your-pat" "https://dev.azure.com/your-org/_apis/projects?api-version=6.0"
```

## 📊 **What Happens After Setup**

1. **Code Push** → GitHub webhook triggers Azure DevOps pipeline
2. **Build Stage** → Docker image built and pushed to admin ACR
3. **Test Stage** → Automated tests run (if configured)
4. **Deploy Stage** → Image promoted to target environment ACR and deployed
5. **Notifications** → Teams/email notifications on success/failure

## 🔗 **Related Documentation**

- [Azure DevOps Service Connections](https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints)
- [GitHub Service Connections](https://docs.microsoft.com/en-us/azure/devops/pipelines/repos/github)
- [Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/)
- [Pipeline Templates](./pipelines/templates/README.md)

## 🎯 **Next Steps**

1. **Set up additional environments** (UAT, Production)
2. **Configure monitoring and alerts**
3. **Set up automated testing**
4. **Configure deployment approvals**
5. **Set up branch policies and PR workflows**