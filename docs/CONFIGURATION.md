# ⚙️ Backstage Configuration Guide

## Overview

This guide covers all configuration aspects of the Backstage implementation, from basic setup to advanced production configurations.

## 📁 Configuration Files

### Core Configuration Files

```
backstage-implementation/
├── app-config.yaml              # Base configuration
├── app-config.production.yaml   # Production overrides
├── catalog-info.yaml           # Backstage catalog entity
├── .env.example               # Environment variables template
└── docker-compose.yml         # Local development setup
```

### Configuration Hierarchy

```
Environment Variables (highest priority)
    ↓
app-config.production.yaml (production overrides)
    ↓
app-config.yaml (base configuration)
    ↓
Default values (lowest priority)
```

## 🔧 Base Configuration (`app-config.yaml`)

### Application Settings

```yaml
app:
  title: Backstage Developer Portal
  baseUrl: http://localhost:3000
  # Custom branding
  branding:
    theme: light
    logo: /logo.png

organization:
  name: Your Company Name
```

### Backend Configuration

```yaml
backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0

  # Database configuration
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST:-localhost}
      port: ${POSTGRES_PORT:-5432}
      user: ${POSTGRES_USER:-backstage}
      password: ${POSTGRES_PASSWORD:-backstage}
      database: ${POSTGRES_DB:-backstage_catalog}

  # CORS configuration
  cors:
    origin: http://localhost:3000
    methods: [GET, POST, PUT, DELETE, PATCH]
    credentials: true

  # Content Security Policy
  csp:
    connect-src: ["'self'", 'http:', 'https:']
    script-src: ["'self'", "'unsafe-inline'"]
    style-src: ["'self'", "'unsafe-inline'"]
```

### Authentication Configuration

```yaml
auth:
  environment: development
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        enterpriseInstanceUrl: ${GITHUB_URL}
    google:
      development:
        clientId: ${AUTH_GOOGLE_CLIENT_ID}
        clientSecret: ${AUTH_GOOGLE_CLIENT_SECRET}
    microsoft:
      development:
        clientId: ${AUTH_MICROSOFT_CLIENT_ID}
        clientSecret: ${AUTH_MICROSOFT_CLIENT_SECRET}
        tenantId: ${AUTH_MICROSOFT_TENANT_ID}
```

### Integration Configuration

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
      apiBaseUrl: ${GITHUB_API_BASE_URL}
      rawBaseUrl: ${GITHUB_RAW_BASE_URL}
    - host: github.company.com
      token: ${GITHUB_ENTERPRISE_TOKEN}

  gitlab:
    - host: gitlab.com
      token: ${GITLAB_TOKEN}
    - host: gitlab.company.com
      token: ${GITLAB_ENTERPRISE_TOKEN}

  azure:
    - host: dev.azure.com
      token: ${AZURE_TOKEN}
      organization: ${AZURE_ORG}

  bitbucket:
    - host: bitbucket.org
      username: ${BITBUCKET_USERNAME}
      appPassword: ${BITBUCKET_APP_PASSWORD}
```

## 🚀 Production Configuration (`app-config.production.yaml`)

### Production-Specific Settings

```yaml
app:
  title: Backstage Developer Portal
  baseUrl: https://backstage.company.com

backend:
  baseUrl: https://backstage.company.com
  listen:
    port: 7007

  # Production database
  database:
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
      ssl: require

  # Enhanced security
  csp:
    upgrade-insecure-requests: false
    script-src: ["'self'"]
    style-src: ["'self'", "'unsafe-inline'"]

  # External services
  reading:
    allow:
      - host: backstagedocs.company.com
```

### Kubernetes Integration

```yaml
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - url: ${K8S_CLUSTER_URL}
          name: production-cluster
          authProvider: 'serviceAccount'
          skipTLSVerify: false
          caData: ${K8S_CA_DATA}
```

### External Services Integration

```yaml
# TechDocs configuration
techdocs:
  builder: 'external'
  generator:
    runIn: 'docker'
  publisher:
    type: 'awsS3'
    awsS3:
      bucketName: ${TECHDOCS_S3_BUCKET}
      region: ${AWS_REGION}
      credentials:
        accessKeyId: ${AWS_ACCESS_KEY_ID}
        secretAccessKey: ${AWS_SECRET_ACCESS_KEY}

# Scaffolder configuration
scaffolder:
  github:
    token: ${GITHUB_TOKEN}
    visibility: public

# Search configuration
search:
  elasticsearch:
    node: ${ELASTICSEARCH_NODE}
    auth:
      username: ${ELASTICSEARCH_USERNAME}
      password: ${ELASTICSEARCH_PASSWORD}
```

## 🔐 Environment Variables

### Required Variables

```bash
# Database Configuration
POSTGRES_HOST=your-postgres-host
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=your-secure-password
POSTGRES_DB=backstage_catalog

# GitHub Integration
GITHUB_TOKEN=ghp_your_github_token

# Authentication Providers
AUTH_GITHUB_CLIENT_ID=your_github_client_id
AUTH_GITHUB_CLIENT_SECRET=your_github_client_secret

# Application URLs
BACKSTAGE_BASE_URL=https://backstage.company.com
BACKSTAGE_BACKEND_URL=https://backstage.company.com
```

### Optional Variables

```bash
# TechDocs (AWS S3)
TECHDOCS_S3_BUCKET=your-techdocs-bucket
AWS_REGION=us-east-1
AWS_ACCESS_KEY_ID=your_access_key
AWS_SECRET_ACCESS_KEY=your_secret_key

# Search (Elasticsearch)
ELASTICSEARCH_NODE=https://elasticsearch.company.com:9200
ELASTICSEARCH_USERNAME=backstage
ELASTICSEARCH_PASSWORD=your_password

# Redis (Caching)
REDIS_HOST=redis.company.com
REDIS_PORT=6379
REDIS_PASSWORD=your_password

# Monitoring
PROMETHEUS_PUSHGATEWAY_URL=http://prometheus.company.com:9091

# Logging
LOG_LEVEL=info
LOG_FORMAT=json
```

## 📊 Plugin Configuration

### Catalog Plugin

```yaml
catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  rules:
    - allow:
      - Component
      - System
      - API
      - Resource
      - Location
      - User
      - Group
      - Domain
  locations:
    - type: url
      target: https://github.com/company/backstage-catalog/blob/main/all.yaml
    - type: github
      target: https://github.com/company/*/blob/main/catalog-info.yaml
      rules:
        - allow: [Component, API]
    - type: github-discovery
      target: https://github.com/company
```

### TechDocs Plugin

```yaml
techdocs:
  builder: 'external'
  generator:
    runIn: 'docker'
    dockerImage: 'spotify/techdocs:v1.2.0'
    pullImage: true
  publisher:
    type: 'awsS3'
    awsS3:
      bucketName: ${TECHDOCS_S3_BUCKET}
      region: ${AWS_REGION}
      credentials:
        accessKeyId: ${AWS_ACCESS_KEY_ID}
        secretAccessKey: ${AWS_SECRET_ACCESS_KEY}
      sse: 'AES256'
```

### Search Plugin

```yaml
search:
  collators:
    - type: 'software-catalog'
    - type: 'techdocs'
  locations:
    - type: 'elasticsearch'
      target: ${ELASTICSEARCH_NODE}
```

### Scaffolder Plugin

```yaml
scaffolder:
  github:
    token: ${GITHUB_TOKEN}
    visibility: public
  azure:
    host: dev.azure.com
    token: ${AZURE_TOKEN}
    organization: ${AZURE_ORG}
  gitlab:
    api:
      baseUrl: ${GITLAB_BASE_URL}
      token: ${GITLAB_TOKEN}
```

## 🔍 Logging Configuration

### Basic Logging

```yaml
logging:
  level: info
  format:
    type: json
  timestamp: true
```

### Advanced Logging

```yaml
logging:
  level: info
  format:
    type: json
  timestamp: true
  outputs:
    - type: console
      format:
        type: json
    - type: file
      format:
        type: json
      filename: /var/log/backstage/app.log
      maxsize: 10m
      maxfiles: 5
    - type: loki
      url: http://loki.monitoring.svc.cluster.local:3100/loki/api/v1/push
      labels:
        app: backstage
        environment: production
```

## 📈 Monitoring Configuration

### Health Checks

```yaml
healthcheck:
  readiness:
    checks:
      - type: database
        database: main
      - type: http-get
        url: https://api.github.com
  liveness:
    checks:
      - type: database
        database: main
```

### Metrics

```yaml
metrics:
  prometheus:
    prefix: backstage_
    labels:
      environment: production
      region: us-east-1
```

## 🔒 Security Configuration

### HTTPS and TLS

```yaml
backend:
  https:
    certificate:
      cert: ${TLS_CERT_PATH}
      key: ${TLS_KEY_PATH}
    ca:
      cert: ${TLS_CA_CERT_PATH}
```

### Authentication

```yaml
auth:
  session:
    secret: ${SESSION_SECRET}
  providers:
    github:
      production:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        enterpriseInstanceUrl: ${GITHUB_ENTERPRISE_URL}
```

### Authorization

```yaml
permission:
  enabled: true
  rbac:
    policies-csv-file: ./rbac/rbac-policy.csv
  rules:
    - name: 'read'
      description: 'Read access'
    - name: 'write'
      description: 'Write access'
    - name: 'admin'
      description: 'Admin access'
```

## 🐳 Docker Configuration

### Dockerfile

```dockerfile
FROM node:18-bullseye-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source
COPY . .

# Build application
RUN yarn build

# Expose port
EXPOSE 7007

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:7007/healthcheck || exit 1

# Start application
CMD ["yarn", "start"]
```

### Docker Compose

```yaml
version: '3.8'

services:
  backstage:
    build: .
    ports:
      - "7007:7007"
    environment:
      - POSTGRES_HOST=postgres
      - POSTGRES_PASSWORD=backstage
    depends_on:
      postgres:
        condition: service_healthy

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=backstage
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres_data:
```

## ☸️ Kubernetes Configuration

### ConfigMap

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backstage-config
data:
  app-config.yaml: |
    app:
      title: Backstage Developer Portal
    # ... configuration content
```

### Secret

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: backstage-secret
type: Opaque
data:
  postgres-password: <base64-encoded-password>
  github-token: <base64-encoded-token>
  session-secret: <base64-encoded-secret>
```

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backstage
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: backstage
        image: backstage:latest
        envFrom:
        - configMapRef:
            name: backstage-config
        - secretRef:
            name: backstage-secret
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## 🔧 Advanced Configuration

### Custom Plugins

```yaml
# In app-config.yaml
plugins:
  - package: '@company/backstage-plugin-custom'
    pluginConfig:
      apiUrl: ${CUSTOM_API_URL}
      apiKey: ${CUSTOM_API_KEY}
```

### Feature Flags

```yaml
featureFlags:
  - name: 'custom-feature'
    description: 'Enable custom feature'
    defaultValue: false
  - name: 'experimental-ui'
    description: 'Enable experimental UI'
    defaultValue: false
```

### Custom Themes

```yaml
app:
  branding:
    theme:
      primaryColor: '#FF6B35'
      headerColor1: '#FF6B35'
      headerColor2: '#F7931E'
      navigationIndicatorColor: '#FF6B35'
```

## 📋 Configuration Validation

### Validate Configuration

```bash
# Validate YAML syntax
yamllint app-config.yaml

# Validate with Backstage CLI
npx @backstage/cli config:check

# Test configuration loading
node -e "require('./packages/backend/dist/index.cjs.js').loadConfig()"
```

### Configuration Testing

```javascript
// Test configuration in code
import { loadConfig } from '@backstage/config';

async function testConfig() {
  try {
    const config = await loadConfig({
      configRoot: process.cwd(),
      configTargets: [
        { path: 'app-config.yaml' },
        { path: 'app-config.production.yaml' }
      ]
    });

    console.log('Configuration loaded successfully');
    console.log('App title:', config.getString('app.title'));
  } catch (error) {
    console.error('Configuration error:', error);
  }
}
```

## 🚨 Troubleshooting Configuration

### Common Issues

#### Configuration Not Loading

```bash
# Check file permissions
ls -la app-config.yaml

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('app-config.yaml'))"

# Check environment variables
env | grep -E "(POSTGRES|GITHUB|AUTH)"
```

#### Database Connection Issues

```bash
# Test database connection
psql "postgresql://backstage:password@localhost:5432/backstage_catalog"

# Check connection string
node -e "console.log(process.env.POSTGRES_HOST)"
```

#### Authentication Problems

```bash
# Check OAuth callback URL
curl "https://github.com/login/oauth/authorize?client_id=YOUR_CLIENT_ID"

# Validate tokens
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
```

---

## 📚 Additional Resources

- [Backstage Configuration Documentation](https://backstage.io/docs/conf/)
- [Plugin Configuration](https://backstage.io/docs/plugins/)
- [Authentication Setup](https://backstage.io/docs/auth/)
- [Kubernetes Integration](https://backstage.io/docs/features/kubernetes/)

---

*Last updated: October 2025*