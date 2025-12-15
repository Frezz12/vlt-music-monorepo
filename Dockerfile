# Multi-stage Dockerfile for docploy deployment
# Combines frontend, backend, and nginx in a single container

# -------- Backend Build --------
FROM golang:1.25.5-alpine3.23 AS backend-builder

WORKDIR /app/backend

RUN apk add --no-cache git

COPY backend/go.mod backend/go.sum ./
RUN go mod download

COPY backend/ ./
RUN CGO_ENABLED=0 go build -o main .

# -------- Frontend Build --------
FROM oven/bun:1.3 AS frontend-builder

WORKDIR /app/frontend

COPY frontend/package.json frontend/bun.lock ./
RUN bun install --frozen-lockfile

COPY frontend/ ./
RUN bun run build

# -------- Final Runtime --------
FROM alpine:latest

# Install nginx and required packages
RUN apk add --no-cache nginx ca-certificates

# Create app directories
RUN mkdir -p /app/backend/pb_data /app/frontend

# Copy backend binary
COPY --from=backend-builder /app/backend/main /app/backend/
RUN chmod +x /app/backend/main

# Copy frontend build
COPY --from=frontend-builder /app/frontend/.output /app/frontend/.output
COPY --from=frontend-builder /app/frontend/node_modules /app/frontend/node_modules
COPY --from=frontend-builder /app/frontend/package.json /app/frontend/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup && \
    chown -R appuser:appgroup /app

# Expose port for Docploy
EXPOSE 3000

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'chmod -R 777 ./app/backend/pb_data' >> /start.sh && \
    echo 'echo "Starting backend..."' >> /start.sh && \
    echo 'cd /app/backend && ./main serve --http=0.0.0.0:8090 &' >> /start.sh && \
    echo 'BACKEND_PID=$!' >> /start.sh && \
    echo 'echo "Starting frontend..."' >> /start.sh && \
    echo 'cd /app/frontend && HOST=0.0.0.0 PORT=3001 NODE_ENV=production NUXT_PUBLIC_API_BASE=http://localhost:8090 bun .output/server/index.mjs &' >> /start.sh && \
    echo 'FRONTEND_PID=$!' >> /start.sh && \
    echo 'echo "Starting nginx..."' >> /start.sh && \
    echo 'nginx -g "daemon off;" &' >> /start.sh && \
    echo 'NGINX_PID=$!' >> /start.sh && \
    echo 'echo "All services started. Waiting for termination..."' >> /start.sh && \
    echo 'trap "echo Stopping services...; kill $BACKEND_PID $FRONTEND_PID $NGINX_PID; exit" TERM INT' >> /start.sh && \
    echo 'wait' >> /start.sh && \
    chmod +x /start.sh

USER appuser

CMD ["/start.sh"]