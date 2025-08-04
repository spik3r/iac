# Pipeline MVP - Simplified Azure DevOps Setup

A simplified Azure DevOps pipeline setup for a single environment (dev) without the complexity of multi-subscription architecture.

## 🎯 **What This Creates**

- **Azure DevOps Project** with Git repository
- **Azure Service Connection** to your dev subscription
- **Variable Groups** for configuration and secrets
- **Build Pipeline** that builds and deploys to dev
- **Simple CI/CD workflow** from code to deployment

## 📋 **Prerequisites**

1. **Azure Subscription** (your existing dev subscription)
2. **Azure DevOps Organization** (free tier is fine)
3. **Service Principal** with Contributor access to your subscription

## 🚀 **Quick Setup**

### **Step 1: Get Your Credentials**

#### **Create Service Principal**
```bash
# Login to Azure
az login
az account set --subscription "f9dc50e2-b88a-4c20-b3ad-0c6add93a139"

# Create service principal
az ad sp create-for-rbac --name "vibes-pipeline-sp" --role "Contributor" --scopes "/subscriptions/f9dc50e2-b88a-4c20-b3ad-0c6add93a139"

# Note down:
# - appId (service_principal_id)
# - password (service_principal_key)
# - tenant (tenant_id)
```

#### **Get Azure DevOps PAT**
1. Go to **Azure DevOps** → **User Settings** → **Personal Access Tokens**
2. Create token with **Full access** or these scopes:
   - Project and Team (Read, write, & manage)
   - Build (Read & execute)
   - Service Connections (Read, query, & manage)
   - Variable Groups (Read, create, & manage)

#### **Get GitHub PAT**
1. Go to **GitHub** → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)**
2. Create token with these scopes:
   - `repo` (Full repository access)
   - `admin:repo_hook` (if using webhooks)

### **Step 2: Configure and Deploy**

```bash
cd pipeline-mvp

# Copy and edit configuration files
make setup-files

# Edit terraform.tfvars with your Azure DevOps org and subscription
# Edit secrets.tfvars with your service principal and PAT

# Deploy the pipeline infrastructure
make init
make plan
make apply
```

### **Step 3: Set Up Your GitHub Repository**

1. **Push your code to GitHub** (if not already there):
```bash
# If you haven't already, create a GitHub repo and push your code
git remote add origin https://github.com/your-username/your-repo.git
git push -u origin main
```

2. **Update terraform.tfvars** with your GitHub repository:
```hcl
git_repository_url = "https://github.com/your-username/your-repo"
github_username    = "your-github-username"
```

3. **Update secrets.tfvars** with your GitHub PAT:
```hcl
github_personal_access_token = "your-github-pat"
```

### **Step 4: Copy Pipeline File**

Copy the pipeline YAML to your repository root:
```bash
# Copy from pipeline-mvp to your repo root
cp pipeline-mvp/azure-pipelines.yml ./azure-pipelines.yml
git add azure-pipelines.yml
git commit -m "Add Azure DevOps pipeline"
git push
```

## 📁 **File Structure**

```
pipeline-mvp/
├── main.tf                    # Infrastructure definition
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output values
├── terraform.tfvars.example   # Configuration template
├── secrets.tfvars.example     # Secrets template
├── azure-pipelines.yml        # Pipeline definition
├── Makefile                   # Helper commands
├── .gitignore                 # Git ignore rules
└── README.md                  # This file
```

## 🔧 **Configuration**

### **terraform.tfvars**
```hcl
project_name = "vibes"
subscription_id = "f9dc50e2-b88a-4c20-b3ad-0c6add93a139"
azuredevops_org_service_url = "https://dev.azure.com/your-org"
git_repository_url = "https://github.com/your-username/your-repo"
github_username = "your-github-username"
dev_resource_group_name = "vibes-dev-rg"
dev_container_registry_name = "vibesacrdev"
dev_app_service_name = "vibes-dev-app"
```

### **secrets.tfvars**
```hcl
service_principal_id = "your-sp-app-id"
service_principal_key = "your-sp-password"
tenant_id = "your-tenant-id"
azuredevops_personal_access_token = "your-devops-pat"
github_personal_access_token = "your-github-pat"
```

## 🔄 **Pipeline Workflow**

1. **Code Push** → Triggers pipeline automatically
2. **Build Stage**:
   - Checkout code
   - Build Docker image
   - Push to your existing ACR
3. **Deploy Stage**:
   - Deploy to your existing App Service
   - Update app settings with build metadata
   - Perform health check
   - Verify deployment

## 📊 **After Deployment**

### **Access Your Pipeline**
```bash
# Get project URL
make devops-url

# Get pipeline URL
make pipeline-url

# Check status
make status
```

### **Monitor Your Pipeline**
1. Go to **Azure DevOps** → **Pipelines**
2. Click on your pipeline to see runs
3. Monitor builds and deployments
4. View logs and artifacts

## 🔍 **Troubleshooting**

### **Common Issues**

1. **Service Principal Permissions**
   ```bash
   # Verify SP has access
   az login --service-principal -u "your-sp-id" -p "your-sp-key" --tenant "your-tenant"
   az account show
   ```

2. **Azure DevOps PAT Issues**
   - Check PAT hasn't expired
   - Verify correct scopes
   - Test with curl:
   ```bash
   curl -u ":your-pat" "https://dev.azure.com/your-org/_apis/projects?api-version=6.0"
   ```

3. **Pipeline Failures**
   - Check variable groups have correct values
   - Verify service connection is authorized
   - Check Docker build context in pipeline

### **Useful Commands**
```bash
make status          # Check setup status
make outputs         # Show all outputs
make devops-url      # Get DevOps project URL
make pipeline-url    # Get pipeline URL
make validate        # Validate Terraform config
```

## 🎯 **Next Steps**

Once this MVP is working:

1. **Add Tests** - Include unit tests in the pipeline
2. **Add Environments** - Create staging/prod environments
3. **Add Approvals** - Require manual approval for deployments
4. **Add Notifications** - Set up Teams/email notifications
5. **Scale Up** - Move to the full multi-subscription setup

## 🔗 **Related Files**

- `azure-pipelines.yml` - Copy this to your repository root
- Your existing infrastructure in `mvp/` or `environments/dev/`
- Application code in `app-src/`

This MVP setup gets you from zero to working CI/CD in about 15 minutes!