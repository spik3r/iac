# MVP Infrastructure Setup

This directory contains a simplified version of the infrastructure setup without pipelines, using local Terraform state for quick environment provisioning.

## 🎯 **What This Creates**

- **Resource Group**: Container for all resources
- **Virtual Network**: Secure networking with subnets
- **Container Registry**: For Docker images
- **App Service**: Web application hosting
- **Application Insights**: Monitoring and logging
- **Log Analytics Workspace**: Centralized logging

## 📋 **Prerequisites**

1. **Azure CLI** installed and logged in
2. **Terraform** installed (>= 1.0)
3. **Azure subscription** with appropriate permissions

## 🚀 **Quick Setup**

### **1. Login to Azure**
```bash
az login
az account set --subscription "your-subscription-id"
```

### **2. Navigate to MVP Directory**
```bash
cd mvp
```

### **3. Initialize Terraform**
```bash
make init
# OR manually: terraform init
```

### **4. Review and Customize Configuration**
Edit `terraform.tfvars` to customize:
- Environment name
- Resource names
- Location
- SKU sizes

### **5. Plan the Deployment**
```bash
make plan
# OR manually: terraform plan -var-file="terraform.tfvars"
```

### **6. Deploy the Infrastructure**
```bash
make apply
# OR manually: terraform apply -var-file="terraform.tfvars"
```

Type `yes` when prompted to confirm.

### **7. Get Important Values**
```bash
make outputs
# Get specific values:
make connection-string  # Application Insights connection string
make registry          # Container registry URL
make url              # App Service URL
```

## 📝 **Configuration Files**

### **terraform.tfvars**
Main configuration file with all customizable values:
- Environment settings
- Resource names and locations
- SKU sizes and configurations

### **variables.tf**
Variable definitions with defaults and validation rules.

### **main.tf**
Infrastructure definition using existing modules.

### **outputs.tf**
Important values displayed after deployment.

## 🔧 **Customization Options**

### **Change Environment**
```hcl
environment = "staging"  # or "prod"
name_prefix = "vibes-staging"
resource_group_name = "vibes-staging-rg"
```

### **Change Location**
```hcl
location = "East US"  # or any Azure region
```

### **Upgrade SKUs**
```hcl
app_service_plan_sku = "S1"      # Standard tier
container_registry_sku = "Standard"  # More features
```

### **Disable VNet Integration**
```hcl
enable_vnet_integration = false
```

## 📊 **After Deployment**

### **Get Important URLs and Keys**
```bash
terraform output
```

### **Get Application Insights Connection String**
```bash
terraform output application_insights_connection_string
```

### **Get Container Registry Login Server**
```bash
terraform output container_registry_login_server
```

## 🐳 **Deploy Your Application**

### **1. Build and Push Docker Image**
```bash
# Login to ACR
az acr login --name $(terraform output -raw container_registry_name)

# Build and push from app-src directory
cd ../app-src
docker build -t $(terraform output -raw container_registry_login_server)/vibes-app:latest .
docker push $(terraform output -raw container_registry_login_server)/vibes-app:latest
```

### **2. Update App Service**
```bash
az webapp config container set \
  --name $(terraform output -raw app_service_name) \
  --resource-group $(terraform output -raw resource_group_name) \
  --docker-custom-image-name $(terraform output -raw container_registry_login_server)/vibes-app:latest
```

## 🧹 **Cleanup**

To destroy all resources:
```bash
terraform destroy
```

Type `yes` when prompted.

## 🔍 **Troubleshooting**

### **Permission Issues**
Ensure your Azure account has:
- Contributor role on the subscription
- Ability to create resource groups

### **Resource Name Conflicts**
If resources already exist, modify the `name_prefix` in `terraform.tfvars`.

### **State File Issues**
The state file (`terraform.tfstate`) is stored locally. Don't delete it unless you want to lose track of your resources.

## 📁 **File Structure**
```
mvp/
├── main.tf              # Infrastructure definition
├── variables.tf         # Variable definitions
├── outputs.tf          # Output values
├── terraform.tfvars    # Configuration values
├── terraform.tfstate   # State file (created after apply)
└── README.md           # This file
```

## 🔗 **Related Modules**
This setup uses the same modules as the main infrastructure:
- `../modules/networking`
- `../modules/container-registry`
- `../modules/app-service`
- `../modules/application-insights`

## 🎯 **Next Steps**
1. Deploy your application container
2. Configure custom domains (if needed)
3. Set up monitoring alerts
4. Scale resources as needed