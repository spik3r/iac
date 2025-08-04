# Pipeline MVP Infrastructure Makefile

.PHONY: help init plan apply destroy clean outputs setup-files

# Default target
help:
	@echo "Pipeline MVP Infrastructure Commands:"
	@echo "  setup-files - Copy example files to get started"
	@echo "  init        - Initialize Terraform"
	@echo "  plan        - Plan infrastructure changes"
	@echo "  apply       - Apply infrastructure changes"
	@echo "  destroy     - Destroy all infrastructure"
	@echo "  outputs     - Show Terraform outputs"
	@echo "  clean       - Clean Terraform files"
	@echo ""
	@echo "Quick start:"
	@echo "  make setup-files"
	@echo "  # Edit terraform.tfvars and secrets.tfvars"
	@echo "  make init && make plan && make apply"
	@echo ""
	@echo "See README.md for detailed instructions"

# Copy example files
setup-files:
	@if [ ! -f "terraform.tfvars" ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "✅ Created terraform.tfvars from example"; \
	else \
		echo "⚠️  terraform.tfvars already exists"; \
	fi
	@if [ ! -f "secrets.tfvars" ]; then \
		cp secrets.tfvars.example secrets.tfvars; \
		echo "✅ Created secrets.tfvars from example"; \
	else \
		echo "⚠️  secrets.tfvars already exists"; \
	fi
	@echo ""
	@echo "📝 Next steps:"
	@echo "1. Edit terraform.tfvars with your Azure DevOps org and subscription details"
	@echo "2. Edit secrets.tfvars with your service principal and PAT credentials"
	@echo "3. Run: make init && make plan && make apply"

# Initialize Terraform
init:
	terraform init

# Plan infrastructure changes
plan:
	@if [ ! -f "terraform.tfvars" ]; then \
		echo "❌ terraform.tfvars not found. Run 'make setup-files' first"; \
		exit 1; \
	fi
	@if [ ! -f "secrets.tfvars" ]; then \
		echo "❌ secrets.tfvars not found. Run 'make setup-files' first"; \
		exit 1; \
	fi
	terraform plan -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Apply infrastructure changes
apply:
	@if [ ! -f "terraform.tfvars" ]; then \
		echo "❌ terraform.tfvars not found. Run 'make setup-files' first"; \
		exit 1; \
	fi
	@if [ ! -f "secrets.tfvars" ]; then \
		echo "❌ secrets.tfvars not found. Run 'make setup-files' first"; \
		exit 1; \
	fi
	terraform apply -var-file="terraform.tfvars" -var-file="secrets.tfvars"

# Destroy infrastructure
destroy:
	@echo "⚠️  WARNING: This will destroy the Azure DevOps project and all pipelines!"
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

# Get build pipeline URL
pipeline-url:
	@terraform output -raw build_pipeline_url 2>/dev/null || echo "Run 'make apply' first"

# Show setup status
status:
	@echo "Setup Status:"
	@echo "============="
	@if [ -f "terraform.tfvars" ]; then \
		echo "✅ terraform.tfvars exists"; \
	else \
		echo "❌ terraform.tfvars missing - run 'make setup-files'"; \
	fi
	@if [ -f "secrets.tfvars" ]; then \
		echo "✅ secrets.tfvars exists"; \
	else \
		echo "❌ secrets.tfvars missing - run 'make setup-files'"; \
	fi
	@if [ -f ".terraform.lock.hcl" ]; then \
		echo "✅ Terraform initialized"; \
	else \
		echo "❌ Terraform not initialized - run 'make init'"; \
	fi
	@if [ -f "terraform.tfstate" ]; then \
		echo "✅ Infrastructure deployed"; \
		echo ""; \
		echo "🔗 Quick Links:"; \
		make devops-url 2>/dev/null | sed 's/^/   DevOps Project: /' || true; \
		make pipeline-url 2>/dev/null | sed 's/^/   Build Pipeline: /' || true; \
	else \
		echo "❌ Infrastructure not deployed - run 'make apply'"; \
	fi