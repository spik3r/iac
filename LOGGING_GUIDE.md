# Azure Logging Guide - CloudWatch Alternative

## 🔧 **FIXED: Native Application Insights Integration**
Changed from Serilog-only to **native .NET Application Insights** integration so logs appear in Transaction Search like your other apps.

## 🔍 **Azure Alternatives to AWS CloudWatch**

### **1. Application Insights (Current Setup)**
- **Transaction Search**: Correlation IDs, request tracing across services
- **Logs (KQL)**: Powerful querying like CloudWatch Insights
- **Live Metrics**: Real-time monitoring
- **Dependency tracking**: Automatic service correlation

### **2. Azure Monitor Logs (Log Analytics)**
- **Workspace-based**: Centralized logging across all Azure resources
- **KQL Queries**: More powerful than CloudWatch Insights
- **Cross-service correlation**: Better than CloudWatch for microservices
- **Custom dashboards**: Pin queries to Azure dashboards

### **3. Container Insights (for Docker/K8s)**
- **Container-specific**: Like CloudWatch Container Insights
- **Node and pod metrics**: Resource utilization
- **Log aggregation**: Automatic container log collection

## 🎯 **For Your Use Case (Correlation IDs & Service Tracing)**

### **Transaction Search** (Now Fixed!)
```
Application Insights → Transaction Search
- Filter by correlation ID
- See request flow across services
- Click any request to see related logs
- Dependency mapping
```

### **KQL Queries for Correlation**
```kql
// Find all logs for a correlation ID
union traces, requests, dependencies
| where timestamp > ago(24h)
| where operation_Id == "your-correlation-id"
| order by timestamp asc

// Trace a request across services
requests
| where timestamp > ago(1h)
| where name contains "your-endpoint"
| join kind=inner (traces) on operation_Id
| project timestamp, name, message, operation_Id
| order by timestamp asc
```

### **Service Map**
```
Application Insights → Application Map
- Visual service dependencies
- Automatic discovery
- Performance bottlenecks
- Failure rates
```

## 📊 **Recommended Setup for Multi-Service Tracing**

1. **Application Insights per service** (current)
2. **Shared Log Analytics Workspace** (optional)
3. **Correlation IDs in all logs** (automatic with native integration)
4. **Custom dimensions for business context**

## 🚀 **Next Steps**
1. Deploy the fixed version
2. Test Transaction Search correlation
3. Set up cross-service correlation IDs
4. Create KQL queries for your specific use cases

## 📝 **Test Endpoints**
- `GET /version/test-logs` - Multiple log levels
- `GET /version` - Version info with correlation
- `GET /weatherforecast` - Business logic logs