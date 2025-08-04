# Pipeline MVP Terraform Commands
# Simplified Azure DevOps CI/CD setup for single environment

.PHONY: help setup-files init plan apply destroy fmt validate clean

# Default target
help:
	@echo "Pipeline MVP Terraform Commands:"
	@echo ""
	@echo "Setup Commands:"
	@echo "  make setup-files    - Copy example files to working files"
	@echo "  make init          - Initialize Terraform"
	@echo ""
	@echo "Planning Commands:"
	@echo "  make plan          - Plan infrastructure changes"
	@echo "  make plan-destroy  - Plan infrastructure destruction"
	@echo ""
	@echo "Apply Commands:"
	@echo "  make apply         - Apply infrastructure changes"
	@echo "  make destroy       - Destroy infrastructure (with confirmation)"
	@echo ""
	@echo "Maintenance Commands:"
	@echo "  make fmt           - Format Terraform files"
	@echo "  make validate      - Validate Terraform configuration"
	@echo "  make clean         - Clean Terraform cache and state"
	@echo ""
	@echo "Prerequisites:"
	@echo "  1. Edit terraform.tfvars with your configuration"
	@echo "  2. Edit secrets.tfvars with your sensitive values"
	@echo "  3. Ensure you have Azure CLI logged in"
	@echo "  4. Create service principal: az ad sp create-for-rbac --name 'vibes-pipeline-sp' --role 'Contributor'"

# Setup working files from examples
setup-files:
	@echo "Setting up configuration files..."
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "✓ Created terraform.tfvars from example"; \
	else \
		echo "✓ terraform.tfvars already exists"; \
	fi
	@if [ ! -f secrets.tfvars ]; then \
		cp secrets.tfvars.example secrets.tfvars; \
		echo "✓ Created secrets.tfvars from example"; \
	else \
		echo "✓ secrets.tfvars already exists"; \
	fi
	@echo ""
	@echo "⚠️  IMPORTANT: Edit terraform.tfvars and secrets.tfvars with your values before running 'make init'"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Edit terraform.tfvars with your Azure DevOps org and GitHub repo"
	@echo "  2. Edit secrets.tfvars with your service principal and PAT tokens"
	@echo "  3. Run 'make init' to initialize Terraform"

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	terraform init
	@echo "✓ Terraform initialized"

# Plan infrastructure changes
plan:
	@echo "Planning infrastructure changes..."
	terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Plan infrastructure destruction
plan-destroy:
	@echo "Planning infrastructure destruction..."
	terraform plan -destroy -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Apply infrastructure changes
apply:
	@echo "Applying infrastructure changes..."
	terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Destroy infrastructure with confirmation
destroy:
	@echo "⚠️  WARNING: This will destroy all pipeline infrastructure!"
	@echo "This includes:"
	@echo "  - Azure DevOps project and pipelines"
	@echo "  - Service connections"
	@echo "  - Variable groups"
	@echo ""
	@read -p "Are you sure you want to continue? (yes/no): " confirm; \
	if [ "$$confirm" = "yes" ]; then \
		terraform destroy -var-file="terraform.tfvars" -var-file="secrets.tfvars"; \
	else \
		echo "Destruction cancelled."; \
	fi

# Format Terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive
	@echo "✓ Terraform files formatted"

# Validate Terraform configuration
validate:
	@echo "Validating Terraform configuration..."
	terraform validate
	@echo "✓ Terraform configuration is valid"

# Clean Terraform cache and state
clean:
	@echo "Cleaning Terraform cache..."
	rm -rf .terraform
	rm -f .terraform.lock.hcl
	@echo "✓ Terraform cache cleaned"
	@echo ""
	@echo "⚠️  Note: This does not remove terraform.tfstate files"
	@echo "   Run 'terraform state list' to check if state exists"

# Quick validation of all files
check: fmt validate
	@echo "✓ All checks passed"

# Show current Terraform state
state:
	@echo "Current Terraform state:"
	terraform state list

# Show Terraform outputs
output:
	@echo "Terraform outputs:"
	terraform output