# Pipeline Deployment Guide

## 🎯 Quick Start Checklist

### ✅ **Phase 1: Prerequisites (15 minutes)**

#### **1. Azure Subscriptions**
- [ ] Admin subscription created (`iac-admin`)
- [ ] Target subscription available (for dev/prod environments)
- [ ] Both subscriptions accessible via Azure CLI

#### **2. Service Principals**
```bash
# Create admin service principal
az ad sp create-for-rbac \
  --name "vibes-admin-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_ADMIN_SUBSCRIPTION_ID"

# Create target service principal  
az ad sp create-for-rbac \
  --name "vibes-target-sp" \
  --role "Contributor" \
  --scopes "/subscriptions/YOUR_TARGET_SUBSCRIPTION_ID"
```
- [ ] Admin service principal created
- [ ] Target service principal created
- [ ] Service principal credentials saved securely

#### **3. Azure DevOps**
- [ ] Azure DevOps organization created/available
- [ ] Personal Access Token generated with required scopes:
  - Build (read & execute)
  - Code (read)
  - Project and team (read, write & manage)
  - Service connections (read, query & manage)

#### **4. GitHub (Optional)**
- [ ] GitHub repository available
- [ ] GitHub Personal Access Token generated with `repo` scope

### ✅ **Phase 2: Configuration (10 minutes)**

#### **1. Configure Terraform Variables**
```bash
cd buildpipeline
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Edit with your values
```

**Required Variables:**
```hcl
# Project Configuration
project_name = "vibes"
location     = "East US"

# Admin Subscription
admin_subscription_id   = "12345678-1234-1234-1234-123456789012"
admin_subscription_name = "iac-admin"
admin_service_principal_id  = "your-admin-sp-app-id"
admin_service_principal_key = "your-admin-sp-password"

# Target Subscription
target_subscription_id   = "87654321-4321-4321-4321-210987654321"
target_subscription_name = "your-target-subscription"
target_service_principal_id  = "your-target-sp-app-id"
target_service_principal_key = "your-target-sp-password"

# Azure AD
tenant_id = "your-tenant-id"

# Azure DevOps
azuredevops_org_service_url       = "https://dev.azure.com/your-org"
azuredevops_personal_access_token = "your-devops-pat"

# GitHub
use_github_repo                = true
github_repo_name              = "your-org/your-repo"
github_personal_access_token  = "your-github-pat"

# Target Environment (from existing dev setup)
dev_resource_group_name      = "vibes-dev-rg"
dev_container_registry_name  = "vibesacrdev"
dev_app_service_name         = "vibes-dev-app"
```

- [ ] All required variables configured
- [ ] Service principal credentials added
- [ ] DevOps and GitHub tokens added
- [ ] Target environment details added

### ✅ **Phase 3: Deployment (5 minutes)**

#### **1. Validate Configuration**
```bash
# Format and validate
make fmt
make validate

# Plan deployment
make plan-buildpipeline
```
- [ ] Terraform validation passes
- [ ] Plan shows expected resources

#### **2. Deploy Infrastructure**
```bash
# Deploy the infrastructure
make apply-buildpipeline
```
- [ ] Terraform apply completes successfully
- [ ] No errors in deployment

### ✅ **Phase 4: Verification (10 minutes)**

#### **1. Check Azure DevOps**
- [ ] Project created: `vibes-build`
- [ ] Service connections created:
  - `Azure-Admin`
  - `Azure-Target`
  - `GitHub-Build` (if using GitHub)
- [ ] Variable groups created:
  - `vibes-admin-variables`
  - `vibes-admin-secrets`
  - `vibes-dev-variables`
- [ ] Pipelines created:
  - `vibes-build-deploy`
  - `vibes-pr`
  - `vibes-deploy`

#### **2. Check Azure Resources**
- [ ] Admin resource group: `vibes-admin-rg`
- [ ] Admin container registry: `vibesacradmin`
- [ ] ACR admin user enabled

#### **3. Test Service Connections**
In Azure DevOps:
1. Go to Project Settings → Service connections
2. Test each connection:
   - [ ] `Azure-Admin` connection works
   - [ ] `Azure-Target` connection works
   - [ ] `GitHub-Build` connection works (if applicable)

### ✅ **Phase 5: First Pipeline Run (15 minutes)**

#### **1. Trigger Build Pipeline**
```bash
# Push to main branch or manually trigger
git push origin main
```
- [ ] Build pipeline triggers automatically
- [ ] Docker image builds successfully
- [ ] Image pushes to admin ACR
- [ ] Image copies to dev ACR
- [ ] App deploys to dev environment
- [ ] Health checks pass

#### **2. Test PR Pipeline**
```bash
# Create a test PR
git checkout -b test-pipeline
git push origin test-pipeline
# Create PR in GitHub/Azure DevOps
```
- [ ] PR pipeline triggers
- [ ] Build and tests complete
- [ ] Security scan runs
- [ ] Manual approval option available

#### **3. Test Deploy Pipeline**
In Azure DevOps:
1. Go to Pipelines → `vibes-deploy`
2. Run pipeline with parameters:
   - Target Version: `latest`
   - Target Environment: `dev`
- [ ] Deploy pipeline runs successfully
- [ ] Version validation works
- [ ] Deployment completes
- [ ] Health checks pass

## 🔧 **Troubleshooting Common Issues**

### **Service Principal Permissions**
```bash
# If you get permission errors, ensure SPs have correct roles
az role assignment create \
  --assignee "your-sp-app-id" \
  --role "Contributor" \
  --scope "/subscriptions/your-subscription-id"

# For ACR operations, you might need AcrPush/AcrPull roles
az role assignment create \
  --assignee "your-sp-app-id" \
  --role "AcrPush" \
  --scope "/subscriptions/your-subscription-id/resourceGroups/your-rg/providers/Microsoft.ContainerRegistry/registries/your-acr"
```

### **DevOps PAT Issues**
- Ensure PAT hasn't expired
- Verify all required scopes are selected
- Try regenerating the token

### **GitHub Connection Issues**
- Verify GitHub PAT has `repo` scope
- Ensure repository name format is `owner/repo`
- Check if repository is accessible

### **ACR Login Issues**
```bash
# Test ACR access manually
az acr login --name your-acr-name
docker pull your-acr-name.azurecr.io/hello-world:latest
```

### **Pipeline Variable Issues**
- Check variable group permissions
- Verify variable names match exactly
- Ensure secrets are marked as secret

## 📋 **Post-Deployment Tasks**

### **1. Set Up Environments**
In Azure DevOps:
1. Go to Pipelines → Environments
2. Configure approval gates for production
3. Add environment-specific variables

### **2. Configure Branch Policies**
1. Set up branch protection rules
2. Require PR reviews
3. Require status checks to pass

### **3. Set Up Monitoring**
- Configure pipeline failure notifications
- Set up Azure Monitor for ACR and App Services
- Configure log analytics

### **4. Documentation**
- [ ] Update team documentation
- [ ] Share pipeline URLs with team
- [ ] Document deployment process
- [ ] Create runbooks for common operations

## 🎯 **Next Steps**

1. **Add More Environments**: Extend to UAT and Production
2. **Enhanced Security**: Add approval gates and security scanning
3. **Monitoring**: Set up comprehensive monitoring and alerting
4. **Automation**: Add automated testing and quality gates
5. **Optimization**: Implement caching and parallel execution

## 📞 **Getting Help**

If you encounter issues:
1. Check the troubleshooting section above
2. Review Azure DevOps pipeline logs
3. Check Terraform state and outputs
4. Verify all prerequisites are met
5. Test individual components (ACR, service connections, etc.)

## 🎉 **Success Criteria**

You'll know everything is working when:
- ✅ Main branch pushes trigger automatic builds and deployments
- ✅ PRs trigger testing pipelines with optional dev deployment
- ✅ Manual deployments work for any version to any environment
- ✅ Health checks pass consistently
- ✅ Images are properly versioned and stored in ACRs
- ✅ Rollbacks work by deploying previous versions