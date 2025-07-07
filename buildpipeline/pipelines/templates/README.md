# Azure Pipeline Templates

This directory contains reusable Azure Pipeline templates for common CI/CD operations.

## Available Templates

### 1. `semantic-version.yml`
Generates semantic versions for builds.

**Parameters:**
- `versionType`: Type of version to generate (`semantic`, `pr`, `manual`)
- `manualVersion`: Manual version when type is `manual`
- `createGitTag`: Whether to create Git tags (default: `true`)

**Outputs:**
- `semanticVersion`: Full version (e.g., `v1.2.3`)
- `shortVersion`: Version without prefix (e.g., `1.2.3`)
- `imageTag`: Tag for Docker images

**Usage:**
```yaml
- template: templates/semantic-version.yml
  parameters:
    versionType: 'semantic'
    createGitTag: true
```

### 2. `docker-build-push.yml`
Builds and optionally pushes Docker images to ACR.

**Parameters:**
- `imageTag`: Tag for the image
- `imageName`: Name of the Docker image
- `dockerfilePath`: Path to Dockerfile (default: `app-src/`)
- `containerRegistry`: ACR name
- `serviceConnection`: Azure service connection
- `pushToRegistry`: Whether to push to registry (default: `true`)
- `additionalTags`: Array of additional tags
- `buildArgs`: Array of build arguments
- `platform`: Target platform (default: `linux/amd64`)

**Outputs:**
- `dockerBuildSuccess`: Build success status
- `dockerPushSuccess`: Push success status
- `builtImageName`: Full image name with tag

**Usage:**
```yaml
- template: templates/docker-build-push.yml
  parameters:
    imageTag: $(semanticVersion)
    imageName: $(DOCKER_IMAGE_NAME)
    containerRegistry: $(ADMIN_CONTAINER_REGISTRY_NAME)
    serviceConnection: $(ADMIN_SERVICE_CONNECTION_NAME)
    additionalTags:
      - 'latest'
```

### 3. `image-promotion.yml`
Copies/promotes images between container registries.

**Parameters:**
- `sourceRegistry`: Source ACR name
- `sourceSubscriptionId`: Source subscription ID
- `sourceResourceGroup`: Source resource group
- `sourceServiceConnection`: Source service connection
- `targetRegistry`: Target ACR name
- `targetSubscriptionId`: Target subscription ID
- `targetServiceConnection`: Target service connection
- `imageName`: Docker image name
- `imageTag`: Image tag to copy
- `additionalTags`: Additional tags to copy
- `checkIfExists`: Check if image exists before copying (default: `true`)
- `forceOverwrite`: Force overwrite existing images (default: `false`)

**Outputs:**
- `imageExistsInTarget`: Whether image exists in target
- `shouldCopyImage`: Whether image should be copied
- `imagePromotionSuccess`: Promotion success status

**Usage:**
```yaml
- template: templates/image-promotion.yml
  parameters:
    sourceRegistry: $(ADMIN_CONTAINER_REGISTRY_NAME)
    targetRegistry: $(DEV_CONTAINER_REGISTRY_NAME)
    imageName: $(DOCKER_IMAGE_NAME)
    imageTag: $(semanticVersion)
```

### 4. `app-deployment.yml`
Deploys applications to Azure App Service.

**Parameters:**
- `environment`: Target environment name
- `serviceConnection`: Azure service connection
- `resourceGroupName`: Resource group name
- `appServiceName`: App Service name
- `containerRegistry`: Container registry name
- `imageName`: Docker image name
- `imageTag`: Image tag to deploy
- `appSettings`: Array of app settings
- `deploymentSlot`: Deployment slot (optional)
- `restartApp`: Whether to restart app (default: `true`)

**Outputs:**
- `currentImage`: Previous image name
- `newImage`: New image name
- `containerUpdateSuccess`: Update success status
- `appRestartSuccess`: Restart success status

**Usage:**
```yaml
- template: templates/app-deployment.yml
  parameters:
    environment: 'dev'
    serviceConnection: $(TARGET_SERVICE_CONNECTION_NAME)
    resourceGroupName: $(DEV_RESOURCE_GROUP_NAME)
    appServiceName: $(DEV_APP_SERVICE_NAME)
    containerRegistry: $(DEV_CONTAINER_REGISTRY_NAME)
    imageName: $(DOCKER_IMAGE_NAME)
    imageTag: $(semanticVersion)
    appSettings:
      - name: 'BUILD_VERSION'
        value: $(semanticVersion)
```

### 5. `health-check.yml`
Performs application health checks.

**Parameters:**
- `appServiceName`: App Service name
- `healthEndpoint`: Health check endpoint (default: `/version/health`)
- `deploymentSlot`: Deployment slot (optional)
- `maxAttempts`: Maximum attempts (default: `15`)
- `delayBetweenAttempts`: Delay between attempts in seconds (default: `30`)
- `timeoutPerRequest`: Timeout per request in seconds (default: `30`)
- `expectedStatus`: Expected status response (default: `Healthy`)
- `customValidation`: Custom PowerShell validation expression
- `failOnError`: Whether to fail on health check failure (default: `true`)

**Outputs:**
- `healthCheckPassed`: Health check success status
- `healthCheckAttempts`: Number of attempts made
- `healthCheckLastError`: Last error message

**Usage:**
```yaml
- template: templates/health-check.yml
  parameters:
    appServiceName: $(DEV_APP_SERVICE_NAME)
    healthEndpoint: '/version/health'
    maxAttempts: 10
    expectedStatus: 'Healthy'
```

### 6. `security-testing.yml`
Performs security scanning and container testing.

**Parameters:**
- `imageName`: Docker image name
- `imageTag`: Image tag to test
- `runSecurityScan`: Whether to run security scan (default: `true`)
- `runContainerTest`: Whether to run container test (default: `true`)
- `testPort`: Port for testing (default: `8080`)
- `containerPort`: Container port (default: `80`)
- `testEndpoint`: Test endpoint (default: `/version/health`)
- `expectedResponse`: Expected response (default: `Healthy`)
- `securitySeverity`: Security severity levels (default: `HIGH,CRITICAL`)
- `failOnSecurityIssues`: Whether to fail on security issues (default: `false`)

**Outputs:**
- `securityScanPassed`: Security scan success status
- `containerTestPassed`: Container test success status

**Usage:**
```yaml
- template: templates/security-testing.yml
  parameters:
    imageName: $(DOCKER_IMAGE_NAME)
    imageTag: $(prVersion)
    runSecurityScan: true
    runContainerTest: true
    failOnSecurityIssues: false
```

## Template Benefits

### 🔄 **Reusability**
- Common operations defined once
- Consistent behavior across pipelines
- Easy to maintain and update

### 📝 **Expressiveness**
- High-level, declarative syntax
- Clear parameter names and documentation
- Self-documenting pipeline code

### 🛡️ **Reliability**
- Tested and proven templates
- Error handling and validation
- Consistent output variables

### 🚀 **Productivity**
- Faster pipeline development
- Reduced code duplication
- Easier troubleshooting

## Best Practices

1. **Parameter Validation**: Always validate required parameters
2. **Output Variables**: Use consistent naming for output variables
3. **Error Handling**: Include proper error handling and cleanup
4. **Documentation**: Document all parameters and outputs
5. **Versioning**: Consider versioning templates for breaking changes

## Template Development

When creating new templates:

1. **Single Responsibility**: Each template should have one clear purpose
2. **Parameterization**: Make templates flexible with parameters
3. **Default Values**: Provide sensible defaults for optional parameters
4. **Output Variables**: Expose useful information via output variables
5. **Conditional Logic**: Use conditions to handle different scenarios
6. **Error Messages**: Provide clear error messages for failures

## Example Pipeline Structure

```yaml
stages:
- stage: Build
  jobs:
  - job: Build
    steps:
    - template: templates/semantic-version.yml
      parameters:
        versionType: 'semantic'
    
    - template: templates/docker-build-push.yml
      parameters:
        imageTag: $(semanticVersion)
        containerRegistry: $(ACR_NAME)

- stage: Deploy
  jobs:
  - deployment: Deploy
    steps:
    - template: templates/image-promotion.yml
      parameters:
        sourceRegistry: $(ADMIN_ACR)
        targetRegistry: $(ENV_ACR)
    
    - template: templates/app-deployment.yml
      parameters:
        environment: 'dev'
        appServiceName: $(APP_SERVICE_NAME)
    
    - template: templates/health-check.yml
      parameters:
        appServiceName: $(APP_SERVICE_NAME)
```