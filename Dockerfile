# Stage 1: Development/Build Stage
FROM node:18-slim AS builder

# Add build-time environment variables
ARG MONGODB_URI=mongodb://localhost:27017/easyshop
ARG REDIS_URI=redis://localhost:6379
ARG NEXTAUTH_URL
ARG NEXT_PUBLIC_API_URL
ARG NEXTAUTH_SECRET
ARG JWT_SECRET
ARG NODE_ENV=production

ENV MONGODB_URI=$MONGODB_URI \
    REDIS_URI=$REDIS_URI \
    NEXTAUTH_URL=$NEXTAUTH_URL \
    NEXT_PUBLIC_API_URL=$NEXT_PUBLIC_API_URL \
    NEXTAUTH_SECRET=$NEXTAUTH_SECRET \
    JWT_SECRET=$JWT_SECRET \
    NODE_ENV=$NODE_ENV \
    NEXT_PHASE=phase-production-build

RUN apt-get update && \
    apt-get upgrade -y && \
    for i in $(seq 1 3); do \
      echo "Attempt $i to install dependencies..." && \
      apt-get install -y --no-install-recommends \
        python3 \
        make \
        g++ && \
      break || \
      { echo "Retrying in 5 seconds..."; sleep 5; }; \
    done && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY package*.json ./
RUN for i in $(seq 1 3); do \
      echo "Attempt $i to install npm dependencies..." && \
      npm ci --include=dev && \
      break || \
      { echo "Retrying in 5 seconds..."; sleep 5; }; \
    done

COPY . .
RUN npm run build

# Stage 2: Production Stage
FROM node:18-slim AS runner

# Create a non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser -d /app -s /sbin/nologin appuser

# Set working directory
WORKDIR /app

ENV NODE_ENV=production \
    PORT=3000 \
    MONGODB_URI=mongodb://mongodb:27017/easyshop \
    REDIS_URI=redis://redis:6379

COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules

# Give ownership of the app directory to non-root user
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

EXPOSE 3000
CMD ["npm", "start"]
