# Multi-stage Dockerfile for VLT Music Monorepo

# ================================
# Frontend Build Stage
# ================================
FROM oven/bun:1-alpine AS frontend-builder

WORKDIR /app/frontend

# Copy frontend package files
COPY frontend/package.json frontend/bun.lock ./

# Install frontend dependencies
RUN bun install --frozen-lockfile

# Copy frontend source code
COPY frontend/ ./

# Generate types and build frontend
RUN bun run build

# ================================
# Backend Build Stage
# ================================
FROM golang:1.21-alpine AS backend-builder

WORKDIR /app/backend

# Copy backend go mod files
COPY backend/go.mod backend/go.sum ./

# Download backend dependencies
RUN go mod download

# Copy backend source code
COPY backend/ ./

# Build backend with CGO disabled (for Alpine)
RUN CGO_ENABLED=0 GOOS=linux go build -o main .

# ================================
# Frontend Production Stage
# ================================
FROM oven/bun:1-alpine AS frontend-runner

WORKDIR /app

# Create non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Copy frontend package files
COPY frontend/package.json frontend/bun.lock ./

# Install only production dependencies
RUN bun install --frozen-lockfile --production

# Copy built frontend application
COPY --from=frontend-builder --chown=nextjs:nodejs /app/frontend/.output ./.output

# Set permissions
RUN mkdir -p /app/.output && chown -R nextjs:nodejs /app/.output

USER nextjs

EXPOSE 3000

ENV HOST=0.0.0.0
ENV PORT=3000
ENV NODE_ENV=production
ENV POCKETBASE_URL=http://backend:8090

CMD ["bun", ".output/server/index.mjs"]

# ================================
# Backend Production Stage
# ================================
FROM alpine:latest AS backend-runner

WORKDIR /app

# Install CA certificates for HTTPS
RUN apk --no-cache add ca-certificates && \
    addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Copy backend binary
COPY --from=backend-builder /app/backend/main .

# Create data directory and set permissions
RUN mkdir -p /app/pb_data && chown -R appuser:appgroup /app

USER appuser

EXPOSE 8090

ENV GO_ENV=production

CMD ["./main"]