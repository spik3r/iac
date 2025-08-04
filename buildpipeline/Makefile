# Build Pipeline Infrastructure Makefile

.PHONY: help init plan apply destroy clean outputs

# Default target
help:
	@echo "Build Pipeline Infrastructure Commands:"
	@echo "  init     - Initialize Terraform"
	@echo "  plan     - Plan infrastructure changes"
	@echo "  apply    - Apply infrastructure changes"
	@echo "  destroy  - Destroy all infrastructure"
	@echo "  outputs  - Show Terraform outputs"
	@echo "  clean    - Clean Terraform files"
	@echo ""
	@echo "Setup process:"
	@echo "  1. cp terraform.tfvars.example terraform.tfvars"
	@echo "  2. cp secrets.tfvars.example secrets.tfvars"
	@echo "  3. Edit both files with your values"
	@echo "  4. make init && make plan && make apply"
	@echo ""
	@echo "See SETUP_GUIDE.md for detailed instructions"

# Initialize Terraform
init:
	terraform init

# Plan infrastructure changes
plan:
	@if [ ! -f "terraform.tfvars" ]; then \
		echo "❌ terraform.tfvars not found. Copy from terraform.tfvars.example"; \
		exit 1; \
	fi
	@if [ ! -f "secrets.tfvars" ]; then \
		echo "❌ secrets.tfvars not found. Copy from secrets.tfvars.example"; \
		exit 1; \
	fi
	terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Apply infrastructure changes
apply:
	@if [ ! -f "terraform.tfvars" ]; then \
		echo "❌ terraform.tfvars not found. Copy from terraform.tfvars.example"; \
		exit 1; \
	fi
	@if [ ! -f "secrets.tfvars" ]; then \
		echo "❌ secrets.tfvars not found. Copy from secrets.tfvars.example"; \
		exit 1; \
	fi
	terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Destroy infrastructure
destroy:
	@echo "⚠️  WARNING: This will destroy ALL build pipeline infrastructure!"
	@echo "This includes:"
	@echo "  - Azure DevOps project and pipelines"
	@echo "  - Admin container registry"
	@echo "  - Service connections"
	@echo "  - Variable groups"
	@echo ""
	@echo "Are you sure? Press Ctrl+C to cancel, or Enter to continue..."
	@read
	@if [ -f "terraform.tfvars" ] && [ -f "secrets.tfvars" ]; then \
		terraform destroy -var-file="terraform.tfvars" -var-file="secrets.tfvars"; \
	else \
		echo "❌ Configuration files not found"; \
		exit 1; \
	fi

# Show outputs
outputs:
	terraform output

# Clean Terraform files (keeps state)
clean:
	rm -rf .terraform/
	rm -f .terraform.lock.hcl
	rm -f *.tfplan

# Validate configuration
validate:
	terraform validate

# Format Terraform files
fmt:
	terraform fmt -recursive

# Get Azure DevOps project URL
devops-url:
	@terraform output -raw devops_project_url 2>/dev/null || echo "Run 'make apply' first"

# Get admin container registry
admin-registry:
	@terraform output -raw admin_container_registry_login_server 2>/dev/null || echo "Run 'make apply' first"