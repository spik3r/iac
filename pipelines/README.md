# DevOps Pipelines

This directory contains Azure DevOps pipeline definitions for the Vibes application.

## Pipeline Overview

### 1. Build & Deploy Pipeline (`build-deploy.yml`)

**Triggers:**
- Commits to `main` or `develop` branches
- Changes to `app-src/*` or `pipelines/*`

**Stages:**
1. **Build**: 
   - Generate semantic version
   - Build Docker image with version tags
   - Push to Azure Container Registry
   - Create Git tag for version tracking

2. **Deploy to Dev**:
   - Update App Service with new image
   - Restart application
   - Health check verification

3. **Deploy to Prod** (main branch only):
   - Update production App Service
   - Health check verification

### 2. Rollback Pipeline (`rollback.yml`)

**Purpose:** Deploy any previous semantic version to dev or production

**Parameters:**
- `targetVersion`: Semantic version to deploy (e.g., "v1.2.3" or "1.2.3")
- `environment`: Target environment ("dev" or "prod")
- `confirmRollback`: Safety confirmation (must type "ROLLBACK")

**Stages:**
1. **Validate**: 
   - Verify parameters and confirmation
   - Check if target image exists in ACR
   - List available versions if target not found

2. **Rollback**:
   - Update App Service with target version
   - Restart application
   - Health check verification
   - Log rollback event

## Semantic Versioning

### Version Format
- **Pattern**: `v{major}.{minor}.{patch}`
- **Examples**: `v1.0.0`, `v1.2.3`, `v2.0.0`

### Version Generation
1. **Automatic**: Patch version increments on each main branch build
2. **Manual**: Create Git tags for major/minor version bumps:
   ```bash
   git tag v2.0.0
   git push origin v2.0.0
   ```

### Image Tagging Strategy
Each build creates two tags:
- **Semantic version**: `vibes-app:v1.2.3`
- **Latest**: `vibes-app:latest` (points to most recent)

## Pipeline Variables

### Variable Groups Required

1. **`{environment}-variables`** (e.g., `dev-variables`):
   - `AZURE_SUBSCRIPTION_ID`
   - `RESOURCE_GROUP_NAME`
   - `CONTAINER_REGISTRY_NAME`
   - `APP_SERVICE_NAME`
   - `DOCKER_IMAGE_NAME`
   - `ENVIRONMENT`
   - `SERVICE_CONNECTION_NAME`

2. **`{environment}-secrets`** (e.g., `dev-secrets`):
   - `ACR_USERNAME` (secret)
   - `ACR_PASSWORD` (secret)

### Environment-Specific Naming

The pipelines assume this naming convention:
- **Dev**: `app-service-dev`, `rg-project-dev`
- **Prod**: `app-service-prod`, `rg-project-prod`

## Usage Examples

### Triggering a Build
```bash
# Commit to main branch triggers automatic build and deploy
git checkout main
git add .
git commit -m "feat: add new feature"
git push origin main
```

### Manual Version Bump
```bash
# Create a major version bump
git tag v2.0.0
git push origin v2.0.0

# Next build will use v2.0.0 instead of auto-incrementing
```

### Rolling Back
1. Go to Azure DevOps
2. Run "Rollback" pipeline
3. Set parameters:
   - `targetVersion`: `v1.2.1`
   - `environment`: `prod`
   - `confirmRollback`: `ROLLBACK`
4. Run pipeline

### Checking Available Versions
```bash
# List all available image versions in ACR
az acr repository show-tags \
  --name vibesacrdev \
  --repository vibes-app \
  --output table
```

## Health Check Endpoints

The pipelines expect these endpoints to be available:

- **Health Check**: `https://{app-name}.azurewebsites.net/health`
  - Should return JSON with `Status: "Healthy"`
- **Info**: `https://{app-name}.azurewebsites.net/`
  - Should return application information

## Troubleshooting

### Common Issues

1. **Version Already Exists**:
   - Pipeline will use existing tag instead of creating new one
   - Check Git tags: `git tag -l`

2. **Image Not Found in ACR**:
   - Verify image was pushed successfully
   - Check ACR repository: `az acr repository list --name vibesacrdev`

3. **Health Check Failures**:
   - Check App Service logs in Azure Portal
   - Verify application is starting correctly
   - Check container registry authentication

4. **Permission Issues**:
   - Verify service principal has required permissions
   - Check Azure DevOps service connections

### Debugging Commands

```bash
# Check current app service image
az webapp config show \
  --name your-app-service \
  --resource-group your-rg \
  --query "linuxFxVersion"

# View app service logs
az webapp log tail \
  --name your-app-service \
  --resource-group your-rg

# Test health endpoint manually
curl https://your-app.azurewebsites.net/health
```

## Security Considerations

1. **Service Principal**: Use minimal required permissions
2. **Secrets**: Store in Azure DevOps variable groups as secrets
3. **Environments**: Use Azure DevOps environments for approval gates
4. **Branch Protection**: Require PR reviews for main branch
5. **Rollback Confirmation**: Always require explicit confirmation

## Next Steps

1. **Monitoring**: Add Application Insights integration
2. **Testing**: Add automated testing stages
3. **Notifications**: Configure Teams/Slack notifications
4. **Blue-Green**: Implement blue-green deployment strategy
5. **Database**: Add database migration handling