# 🚀 Backstage Implementation

> Complete Backstage Developer Portal implementation with GitOps, monitoring, and production-ready deployment

## 📋 Overview

This folder contains a complete Backstage implementation designed for:
- **Development Environment**: Local development with hot reload
- **Production Environment**: Containerized deployment with Kubernetes
- **GitOps**: Automated deployments with ArgoCD
- **Monitoring**: Integrated with Prometheus and Grafana
- **Security**: Production-ready security configurations

## 🏗️ Architecture

```
backstage-implementation/
├── packages/
│   ├── app/                    # Frontend React application
│   └── backend/                # Node.js backend service
├── app-config.yaml             # Base configuration
├── app-config.production.yaml  # Production overrides
├── Dockerfile                  # Production container
├── docker-compose.yml          # Local development
└── package.json               # Dependencies and scripts
```

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Yarn
- Docker (for containerized deployment)

### Local Development

```bash
# Install dependencies
yarn install

# Start development server
yarn dev

# Access at http://localhost:3000
```

### Production Build

```bash
# Build for production
yarn build

# Start production server
yarn start
```

## 📦 Packages

### Frontend (`packages/app`)
- React-based developer portal
- Customizable UI components
- Plugin integrations

### Backend (`packages/backend`)
- Node.js/Express server
- API endpoints
- Database connections
- Authentication middleware

## ⚙️ Configuration

### Base Configuration (`app-config.yaml`)
```yaml
app:
  title: Backstage Developer Portal
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007

database:
  client: pg
  connection:
    host: localhost
    port: 5432
    user: backstage
    password: backstage
```

### Production Configuration (`app-config.production.yaml`)
```yaml
app:
  baseUrl: https://backstage.company.com

backend:
  baseUrl: https://backstage.company.com
  listen:
    port: 7007

database:
  connection:
    host: ${POSTGRES_HOST}
    port: ${POSTGRES_PORT}
    user: ${POSTGRES_USER}
    password: ${POSTGRES_PASSWORD}
```

## 🐳 Docker Deployment

### Build Image
```bash
docker build -t backstage-app .
```

### Run Container
```bash
docker run -p 7007:7007 backstage-app
```

### Docker Compose (Development)
```bash
docker-compose up -d
```

## ☸️ Kubernetes Deployment

### Using Helm
```bash
helm install backstage ./helm/backstage
```

### Using kubectl
```bash
kubectl apply -f kubernetes/
```

## 🔧 Development Scripts

```bash
# Install dependencies
yarn install

# Start development server
yarn dev

# Build for production
yarn build

# Run tests
yarn test

# Lint code
yarn lint

# Type checking
yarn tsc
```

## 📊 Monitoring

### Health Checks
- `/healthcheck` - Application health
- `/metrics` - Prometheus metrics

### Logging
- Structured JSON logs
- Configurable log levels
- External log aggregation support

## 🔒 Security

### Authentication
- OAuth 2.0 / OIDC support
- GitHub authentication
- LDAP integration

### Authorization
- Role-based access control
- Permission framework
- API authentication

### Security Headers
- HTTPS enforcement
- Content Security Policy
- CORS configuration

## 🔌 Plugins

### Core Plugins
- **Catalog**: Service catalog management
- **TechDocs**: Documentation site
- **Search**: Full-text search
- **Scaffolder**: Software templates

### Custom Plugins
- Company-specific integrations
- Internal tool connections
- Custom workflows

## 📚 Documentation

- [Architecture Overview](./docs/ARCHITECTURE.md)
- [Configuration Guide](./docs/CONFIGURATION.md)
- [Deployment Guide](./docs/DEPLOYMENT.md)
- [Plugin Development](./docs/PLUGINS.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the Apache 2.0 License.

---

**Happy coding! 🎉**