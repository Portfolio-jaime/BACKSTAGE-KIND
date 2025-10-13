# Multi-stage Dockerfile for Backstage
FROM node:18-bullseye-slim AS build

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./
COPY packages/backend/package.json ./packages/backend/
COPY packages/app/package.json ./packages/app/

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source code
COPY . .

# Build application
RUN yarn build

# Production stage
FROM node:18-bullseye-slim AS production

# Install runtime dependencies
RUN apt-get update && apt-get install -y \
    curl \
    netcat \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r backstage && useradd -r -g backstage backstage

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./

# Copy built artifacts
COPY --from=build /app/packages/backend/dist ./packages/backend/dist
COPY --from=build /app/packages/app/dist ./packages/app/dist
COPY --from=build /app/node_modules ./node_modules

# Copy configuration files
COPY app-config.yaml app-config.production.yaml ./

# Create necessary directories
RUN mkdir -p /app/tmp && chown -R backstage:backstage /app

# Switch to non-root user
USER backstage

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:7007/healthcheck || exit 1

# Expose port
EXPOSE 7007

# Set environment variables
ENV NODE_ENV=production
ENV NODE_OPTIONS="--max-old-space-size=1024"

# Start command
CMD ["node", "packages/backend/dist/index.cjs.js", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]