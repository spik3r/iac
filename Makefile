.PHONY: help fmt validate plan-dev apply-dev plan-prod apply-prod destroy-dev destroy-prod bootstrap clean

# Default target
help:
	@echo "Available targets:"
	@echo "  fmt          - Format all Terraform files"
	@echo "  validate     - Validate all Terraform configurations"
	@echo "  bootstrap    - Create remote state infrastructure"
	@echo "  plan-dev     - Plan development environment"
	@echo "  apply-dev    - Apply development environment"
	@echo "  plan-prod    - Plan production environment"
	@echo "  apply-prod   - Apply production environment"
	@echo "  destroy-dev  - Destroy development environment"
	@echo "  destroy-prod - Destroy production environment"
	@echo "  clean        - Clean Terraform cache files"

# Format all Terraform files
fmt:
	@echo "Formatting Terraform files..."
	terraform fmt -recursive

# Validate all configurations
validate:
	@echo "Validating bootstrap configuration..."
	cd bootstrap && terraform init -backend=false && terraform validate
	@echo "Validating dev environment..."
	cd environments/dev && terraform init -backend=false && terraform validate
	@echo "Validating prod environment..."
	cd environments/prod && terraform init -backend=false && terraform validate

# Bootstrap remote state
bootstrap:
	@echo "Creating remote state infrastructure..."
	cd bootstrap && terraform init && terraform plan && terraform apply

# Development environment operations
plan-dev:
	@echo "Planning development environment..."
	cd environments/dev && terraform plan -var-file="terraform.tfvars"

apply-dev:
	@echo "Applying development environment..."
	cd environments/dev && terraform apply -var-file="terraform.tfvars"

destroy-dev:
	@echo "WARNING: This will destroy the development environment!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		cd environments/dev && terraform destroy -var-file="terraform.tfvars"; \
	fi

# Production environment operations
plan-prod:
	@echo "Planning production environment..."
	cd environments/prod && terraform plan -var-file="terraform.tfvars"

apply-prod:
	@echo "Applying production environment..."
	cd environments/prod && terraform apply -var-file="terraform.tfvars"

destroy-prod:
	@echo "WARNING: This will destroy the production environment!"
	@echo "This action is IRREVERSIBLE and will delete all production data!"
	@read -p "Type 'DELETE PRODUCTION' to confirm: " confirm; \
	if [ "$$confirm" = "DELETE PRODUCTION" ]; then \
		cd environments/prod && terraform destroy -var-file="terraform.tfvars"; \
	else \
		echo "Confirmation failed. Aborting."; \
	fi

# Clean Terraform cache files
clean:
	@echo "Cleaning Terraform cache files..."
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tfstate*" -not -path "./bootstrap/*" -delete 2>/dev/null || true
	find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true