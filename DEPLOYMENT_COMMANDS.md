# Terraform Deployment Commands

## 📋 **Variable Files Structure**

The project uses two variable files for security and organization:

```
environments/dev/
├── terraform.tfvars         # Main configuration (committed to git)
├── terraform.tfvars.example # Template for main config
├── secrets.tfvars          # Sensitive data (NOT committed to git)
└── secrets.tfvars.example  # Template for secrets
```

## 🔐 **Variable Files Usage**

### **terraform.tfvars** (Public Configuration)
Contains non-sensitive configuration like:
- Project names and locations
- SKU sizes and resource configurations
- Feature flags and settings
- Public URLs and names

### **secrets.tfvars** (Sensitive Configuration)
Contains sensitive data like:
- Service principal credentials
- Personal access tokens
- Connection strings
- API keys

## 🚀 **Correct Deployment Commands**

### **Development Environment**
```bash
cd environments/dev

# Validate configuration
terraform validate

# Plan with both variable files
terraform plan \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"

# Apply with both variable files
terraform apply \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"

# Destroy (if needed)
terraform destroy \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"
```

### **Production Environment**
```bash
cd environments/prod

# Plan with both variable files
terraform plan \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"

# Apply with both variable files
terraform apply \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"
```

### **Build Pipeline Infrastructure**
```bash
cd buildpipeline

# Plan with both variable files
terraform plan \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"

# Apply with both variable files
terraform apply \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"
```

## 🛠️ **Makefile Updates**

The Makefile should be updated to use both variable files:

```makefile
# Development environment operations
plan-dev:
	@echo "Planning development environment..."
	cd environments/dev && terraform plan \
		-var-file="terraform.tfvars" \
		-var-file="secrets.tfvars"

apply-dev:
	@echo "Applying development environment..."
	cd environments/dev && terraform apply \
		-var-file="terraform.tfvars" \
		-var-file="secrets.tfvars"

# Production environment operations
plan-prod:
	@echo "Planning production environment..."
	cd environments/prod && terraform plan \
		-var-file="terraform.tfvars" \
		-var-file="secrets.tfvars"

apply-prod:
	@echo "Applying production environment..."
	cd environments/prod && terraform apply \
		-var-file="terraform.tfvars" \
		-var-file="secrets.tfvars"

# Build pipeline operations
plan-buildpipeline:
	@echo "Planning build pipeline infrastructure..."
	cd buildpipeline && terraform plan \
		-var-file="terraform.tfvars" \
		-var-file="secrets.tfvars"

apply-buildpipeline:
	@echo "Applying build pipeline infrastructure..."
	cd buildpipeline && terraform apply \
		-var-file="terraform.tfvars" \
		-var-file="secrets.tfvars"
```

## 🔧 **Troubleshooting**

### **Terraform Lock Issues**
If you encounter a Terraform lock:

```bash
# Check for lock
terraform plan

# If locked, get the lock ID from the error message and force unlock
terraform force-unlock -force <LOCK_ID>

# Example:
terraform force-unlock -force 17f81397-d219-a442-0d74-b7c50ce90727
```

### **Module Installation**
After adding new modules, always run:

```bash
terraform init
```

### **Variable File Validation**
Test your variable files:

```bash
# Validate syntax
terraform validate

# Check what will be created
terraform plan \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"
```

## 📁 **File Setup Checklist**

### **Initial Setup**
1. Copy example files:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   cp secrets.tfvars.example secrets.tfvars
   ```

2. Edit `terraform.tfvars` with your public configuration
3. Edit `secrets.tfvars` with your sensitive data
4. Ensure `secrets.tfvars` is in `.gitignore`

### **Security Check**
- ✅ `terraform.tfvars` - Safe to commit
- ❌ `secrets.tfvars` - NEVER commit this file
- ✅ `*.tfvars.example` - Safe to commit as templates

## 🎯 **Quick Commands**

```bash
# Full deployment with proper variable files
make apply-dev

# Or manually:
cd environments/dev && terraform apply \
  -var-file="terraform.tfvars" \
  -var-file="secrets.tfvars"
```