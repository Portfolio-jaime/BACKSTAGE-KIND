# 📊 Backstage Monitoring Guide

## Overview

This guide covers monitoring, logging, and observability for the Backstage implementation.

## 🏥 Health Checks

### Application Health

The application exposes health check endpoints:

```bash
# Health check
curl http://localhost:7007/healthcheck

# Response
{
  "status": "ok",
  "timestamp": "2025-10-13T23:16:28.506Z",
  "version": "1.0.0"
}
```

### Database Health

```bash
# Check database connectivity
kubectl exec -it backstage-pod -- nc -z postgres-service 5432

# Database health query
kubectl exec -it postgres-pod -- psql -U backstage -d backstage_catalog -c "SELECT 1;"
```

## 📈 Metrics

### Prometheus Metrics

The application exposes Prometheus metrics at `/metrics`:

```bash
curl http://localhost:7007/metrics
```

### Key Metrics

#### HTTP Metrics
```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/api/catalog/entities",status="200"} 150

# HELP http_request_duration_seconds HTTP request duration in seconds
# TYPE http_request_duration_seconds histogram
http_request_duration_seconds_bucket{method="GET",route="/api/catalog/entities",le="0.1"} 120
```

#### Database Metrics
```
# HELP postgres_connections_total Total number of PostgreSQL connections
# TYPE postgres_connections_total gauge
postgres_connections_total{state="active"} 5

# HELP postgres_query_duration_seconds Query execution time
# TYPE postgres_query_duration_seconds histogram
postgres_query_duration_seconds_bucket{query="SELECT * FROM catalog_entities",le="0.1"} 95
```

#### Application Metrics
```
# HELP backstage_catalog_entities_total Total number of catalog entities
# TYPE backstage_catalog_entities_total gauge
backstage_catalog_entities_total{type="component"} 25

# HELP backstage_plugin_load_duration_seconds Plugin load duration
# TYPE backstage_plugin_load_duration_seconds histogram
backstage_plugin_load_duration_seconds_bucket{plugin="catalog",le="1.0"} 8
```

## 📝 Logging

### Log Configuration

Logs are configured in `app-config.yaml`:

```yaml
logging:
  level: info
  format:
    type: json
```

### Log Levels

- `error`: Error conditions
- `warn`: Warning conditions
- `info`: Informational messages (default)
- `debug`: Debug information
- `trace`: Detailed trace information

### Structured Logging

All logs follow JSON structure:

```json
{
  "level": "info",
  "message": "Request processed",
  "timestamp": "2025-10-13T23:16:28.506Z",
  "method": "GET",
  "url": "/api/catalog/entities",
  "status": 200,
  "duration": 150,
  "userAgent": "Mozilla/5.0...",
  "requestId": "abc-123-def"
}
```

### Log Aggregation

#### Loki Integration

```yaml
# In app-config.production.yaml
logging:
  format:
    type: json
  outputs:
    - type: loki
      url: http://loki.monitoring.svc.cluster.local:3100
      labels:
        app: backstage
        environment: production
```

#### ELK Stack

```yaml
logging:
  outputs:
    - type: elasticsearch
      url: http://elasticsearch.logging.svc.cluster.local:9200
      index: backstage-%{+YYYY.MM.dd}
```

## 🔍 Distributed Tracing

### Jaeger Integration

```yaml
# In app-config.production.yaml
backend:
  tracing:
    jaeger:
      host: jaeger.monitoring.svc.cluster.local
      port: 14268
```

### Trace Context

Traces include:

- HTTP request/response
- Database queries
- Plugin execution
- External API calls
- Authentication flows

## 📊 Dashboards

### Grafana Dashboards

#### Backstage Overview Dashboard

```json
{
  "title": "Backstage Overview",
  "panels": [
    {
      "title": "HTTP Request Rate",
      "type": "graph",
      "targets": [
        {
          "expr": "rate(http_requests_total[5m])",
          "legendFormat": "{{method}} {{route}}"
        }
      ]
    },
    {
      "title": "Response Time",
      "type": "graph",
      "targets": [
        {
          "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
          "legendFormat": "95th percentile"
        }
      ]
    },
    {
      "title": "Database Connections",
      "type": "graph",
      "targets": [
        {
          "expr": "postgres_connections_total",
          "legendFormat": "{{state}}"
        }
      ]
    }
  ]
}
```

### Custom Metrics

#### Catalog Metrics

```javascript
// In backend plugin
const catalogMetrics = {
  entitiesTotal: new promClient.Gauge({
    name: 'backstage_catalog_entities_total',
    help: 'Total number of catalog entities',
    labelNames: ['type']
  }),

  entitiesCreated: new promClient.Counter({
    name: 'backstage_catalog_entities_created_total',
    help: 'Total number of entities created',
    labelNames: ['type']
  })
};
```

## 🚨 Alerting

### Alert Rules

#### Application Alerts

```yaml
# PrometheusRule for Backstage
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: backstage-alerts
  namespace: monitoring
spec:
  groups:
  - name: backstage
    rules:
    - alert: BackstageDown
      expr: up{job="backstage"} == 0
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Backstage is down"
        description: "Backstage has been down for more than 5 minutes"

    - alert: BackstageHighErrorRate
      expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.05
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High error rate in Backstage"
        description: "Error rate is {{ $value | printf "%.2f" }}%"

    - alert: BackstageHighLatency
      expr: histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m])) > 2
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "High latency in Backstage"
        description: "95th percentile latency is {{ $value }}s"
```

#### Database Alerts

```yaml
- alert: BackstageDatabaseDown
  expr: up{job="postgres"} == 0
  for: 5m
  labels:
    severity: critical
  annotations:
    summary: "PostgreSQL is down"
    description: "PostgreSQL database is not responding"

- alert: BackstageDatabaseHighConnections
  expr: postgres_connections_total{state="active"} > 50
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High database connections"
    description: "Active connections: {{ $value }}"
```

## 🔧 Monitoring Setup

### ServiceMonitor for Prometheus

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: backstage
  namespace: backstage-utility
spec:
  selector:
    matchLabels:
      app: backstage
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
  - port: http
    path: /healthcheck
    interval: 30s
```

### PodMonitor for Detailed Metrics

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: backstage-pods
  namespace: backstage-utility
spec:
  selector:
    matchLabels:
      app: backstage
  podMetricsEndpoints:
  - port: http
    path: /metrics
    interval: 30s
    relabelings:
    - sourceLabels: [__meta_kubernetes_pod_name]
      targetLabel: pod
```

## 📈 Performance Monitoring

### Key Performance Indicators

#### Application Performance
- **Response Time**: < 500ms for API calls
- **Error Rate**: < 1% of total requests
- **Throughput**: > 100 requests/second
- **Availability**: > 99.9% uptime

#### Database Performance
- **Connection Pool Utilization**: < 80%
- **Query Response Time**: < 100ms average
- **Active Connections**: < 20 concurrent
- **Deadlocks**: 0 per hour

### Performance Testing

```bash
# Load testing with k6
k6 run --vus 10 --duration 30s script.js

# script.js
import http from 'k6/http';
import { check } from 'k6';

export default function () {
  const response = http.get('http://backstage.utility.local/api/catalog/entities');
  check(response, {
    'status is 200': (r) => r.status === 200,
    'response time < 500ms': (r) => r.timings.duration < 500,
  });
}
```

## 🔍 Troubleshooting

### Common Issues

#### High Error Rates

```bash
# Check application logs
kubectl logs -f deployment/backstage -n backstage-utility

# Check database logs
kubectl logs -f statefulset/postgres -n backstage-utility

# Check metrics
curl http://backstage.utility.local/metrics | grep "http_requests_total"
```

#### High Latency

```bash
# Check database query performance
kubectl exec -it postgres-pod -n backstage-utility -- psql -U backstage -d backstage_catalog -c "SELECT * FROM pg_stat_activity;"

# Check application profiling
kubectl exec -it backstage-pod -n backstage-utility -- curl http://localhost:7007/debug/pprof/profile
```

#### Memory Issues

```bash
# Check memory usage
kubectl top pods -n backstage-utility

# Check memory limits
kubectl describe pod backstage-pod -n backstage-utility

# Enable heap dump
kubectl exec -it backstage-pod -n backstage-utility -- kill -USR2 1
```

## 📋 Monitoring Checklist

### Daily Checks
- [ ] Health check endpoints responding
- [ ] Error rate < 1%
- [ ] Response time < 500ms
- [ ] Database connections normal
- [ ] Disk space > 20% free

### Weekly Checks
- [ ] Review error logs
- [ ] Check performance trends
- [ ] Update alert thresholds
- [ ] Review security events

### Monthly Checks
- [ ] Performance testing
- [ ] Load testing
- [ ] Security audit
- [ ] Dependency updates

## 🔗 External Links

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)

---

*Last updated: October 2025*