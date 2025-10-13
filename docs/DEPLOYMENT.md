# 🚀 Backstage Deployment Guide

## Prerequisites

- **Node.js**: 18.x or later
- **Yarn**: 1.x
- **Docker**: 20.x or later
- **Kubernetes**: 1.24+ (for production)
- **Helm**: 3.x (for production)

## 🏠 Local Development

### 1. Clone and Setup

```bash
git clone <repository-url>
cd backstage-implementation
cp .env.example .env
# Edit .env with your configuration
```

### 2. Install Dependencies

```bash
make install
# or
yarn install
```

### 3. Start Development Environment

```bash
make dev
# or
yarn dev
```

This starts both frontend (port 3000) and backend (port 7007).

### 4. Access Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:7007
- **Health Check**: http://localhost:7007/healthcheck

## 🐳 Docker Development

### Using Docker Compose

```bash
# Start all services
make docker-compose-up

# View logs
make logs

# Stop services
make docker-compose-down
```

### Manual Docker Build

```bash
# Build image
make docker-build

# Run container
make docker-run
```

## ☸️ Production Deployment

### Option 1: Helm Chart

```bash
# Install
make helm-install

# Upgrade
make helm-upgrade

# Uninstall
make helm-uninstall
```

### Option 2: Kubernetes Manifests

```bash
# Deploy
make k8s-deploy

# Remove
make k8s-undeploy
```

### Option 3: ArgoCD (GitOps)

The application is configured for ArgoCD deployment with the following applications:

- `backstage-utility-dev`: Development environment
- `backstage-utility-prod`: Production environment

## ⚙️ Configuration

### Environment Variables

Create a `.env` file with the following variables:

```bash
# Database
POSTGRES_HOST=your-postgres-host
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=your-password
POSTGRES_DB=backstage_catalog

# GitHub Integration
GITHUB_TOKEN=your-github-token

# Authentication
AUTH_GITHUB_CLIENT_ID=your-client-id
AUTH_GITHUB_CLIENT_SECRET=your-client-secret

# AWS (for TechDocs)
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
TECHDOCS_S3_BUCKET=your-bucket-name
AWS_REGION=us-east-1
```

### Production Configuration

For production, update `app-config.production.yaml`:

```yaml
app:
  baseUrl: https://your-domain.com

backend:
  baseUrl: https://your-domain.com

# Add production database and integrations
```

## 🔒 Security Setup

### 1. GitHub OAuth App

1. Go to GitHub Settings → Developer settings → OAuth Apps
2. Create new OAuth App
3. Set Authorization callback URL: `https://your-domain.com/api/auth/github/handler/frame`
4. Copy Client ID and Client Secret to environment variables

### 2. Database Setup

```sql
CREATE DATABASE backstage_catalog;
CREATE USER backstage WITH PASSWORD 'your-password';
GRANT ALL PRIVILEGES ON DATABASE backstage_catalog TO backstage;
```

### 3. SSL/TLS Certificate

For production, configure SSL certificates:

```yaml
# In ingress configuration
tls:
  - hosts:
      - your-domain.com
    secretName: backstage-tls
```

## 📊 Monitoring Setup

### Health Checks

The application exposes health check endpoints:

- `GET /healthcheck` - Application health
- `GET /metrics` - Prometheus metrics

### Logging

Logs are structured in JSON format:

```json
{
  "level": "info",
  "message": "Request processed",
  "method": "GET",
  "url": "/api/catalog/entities",
  "status": 200,
  "duration": 150
}
```

### Metrics

Prometheus metrics are available at `/metrics`:

```
# HELP http_requests_total Total number of HTTP requests
# TYPE http_requests_total counter
http_requests_total{method="GET",route="/api/catalog/entities",status="200"} 150
```

## 🔄 CI/CD Pipeline

### GitHub Actions

The repository includes a CI/CD pipeline (`.github/workflows/ci-cd.yaml`) that:

1. Runs tests and linting
2. Builds Docker image
3. Pushes to registry
4. Triggers ArgoCD sync

### Manual Deployment

```bash
# Build and push
make deploy

# Or step by step
make build
make docker-build
make docker-push
```

## 🧪 Testing

### Unit Tests

```bash
make test
# or
yarn test
```

### Integration Tests

```bash
yarn test:integration
```

### End-to-End Tests

```bash
yarn test:e2e
```

## 🚨 Troubleshooting

### Common Issues

#### Database Connection Failed

```bash
# Check database connectivity
kubectl exec -it postgres-pod -- psql -U backstage -d backstage_catalog

# Verify environment variables
kubectl get configmap backstage-config -o yaml
kubectl get secret backstage-secret -o yaml
```

#### Application Won't Start

```bash
# Check logs
kubectl logs -f deployment/backstage

# Verify configuration
kubectl exec -it backstage-pod -- cat /app/app-config.yaml
```

#### Health Check Failing

```bash
# Manual health check
curl -f http://localhost:7007/healthcheck

# Check database connectivity from app
kubectl exec -it backstage-pod -- nc -z postgres-service 5432
```

### Performance Issues

#### High Memory Usage

```bash
# Check memory limits
kubectl describe pod backstage-pod

# Adjust resource limits in values.yaml
resources:
  limits:
    memory: 1Gi
  requests:
    memory: 512Mi
```

#### Slow Response Times

```bash
# Check database query performance
kubectl exec -it postgres-pod -- psql -U backstage -d backstage_catalog -c "SELECT * FROM pg_stat_activity;"

# Enable query logging in PostgreSQL
log_statement = 'all'
log_duration = on
```

## 📈 Scaling

### Horizontal Scaling

```yaml
# In values.yaml
replicaCount: 3

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
```

### Database Scaling

```yaml
# PostgreSQL read replicas
postgresql:
  readReplicas:
    enabled: true
    replicaCount: 2
```

## 🔄 Backup and Recovery

### Database Backup

```bash
# Manual backup
kubectl exec -it postgres-pod -- pg_dump -U backstage backstage_catalog > backup.sql

# Automated backup (configure cron job)
kubectl create job backup --from=cronjob/postgres-backup
```

### Application Backup

```bash
# Backup configuration
kubectl get configmap,secret -l app=backstage -o yaml > backup-config.yaml

# Backup persistent volumes
kubectl get pvc -l app=backstage
```

## 📞 Support

### Health Check Commands

```bash
# Application health
curl -f https://your-domain.com/healthcheck

# Database connectivity
kubectl exec -it backstage-pod -- nc -z postgres-service 5432

# Kubernetes status
kubectl get pods -l app=backstage
kubectl get ingress backstage
```

### Log Analysis

```bash
# Application logs
kubectl logs -f deployment/backstage

# Database logs
kubectl logs -f statefulset/postgres

# Ingress logs
kubectl logs -f deployment/nginx-ingress-controller
```

---

## 🎯 Quick Reference

### Development
```bash
make install && make dev
```

### Production
```bash
make build && make helm-install
```

### Monitoring
```bash
kubectl port-forward svc/backstage 7007:80
curl http://localhost:7007/healthcheck
```

### Troubleshooting
```bash
kubectl logs -f deployment/backstage
kubectl describe pod backstage-pod
```

---

*Last updated: October 2025*