#####################################
#BACKEND#
#####################################
FROM golang:1.25.5-alpine3.23 AS build-backend
WORKDIR /app
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY ./backend ./
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o dist/main.bin .

#####################################
# FRONTEND #
#####################################
FROM oven/bun:1.3 AS build-frontend
WORKDIR /app
COPY frontend/package.json frontend/bun.lock ./
RUN bun install --frozen-lockfile
COPY ./frontend ./
WORKDIR /app
ARG NUXT_PUBLIC_API_BASE
ENV NUXT_PUBLIC_API_BASE=$NUXT_PUBLIC_API_BASE
RUN bun run build

#####################################
# FINAL IMAGE #
#####################################
FROM oven/bun:1.3-alpine
WORKDIR /app

# Install nginx and required packages
RUN apk add --no-cache nginx ca-certificates && \
    mkdir -p /var/lib/nginx/logs /var/lib/nginx/tmp && \
    chown -R nginx:nginx /var/lib/nginx

# Copy backend binary
COPY --from=build-backend /app/dist/main.bin ./
RUN chmod +x ./main.bin

# Copy frontend build
COPY --from=build-frontend /app/.output ./frontend/.output
COPY --from=build-frontend /app/node_modules ./frontend/node_modules
COPY --from=build-frontend /app/package.json ./frontend/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create data directory for backend
RUN mkdir -p ./pb_data

RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup && \
    addgroup appuser nginx && \
    chown -R appuser:appgroup /app && \
    chown -R nginx:nginx /var/lib/nginx

# Expose port for Docploy
EXPOSE 8080

RUN mkdir -p /tmp/nginx/client_body \
             /tmp/nginx/proxy \
             /tmp/nginx/fastcgi \
             /tmp/nginx/uwsgi \
             /tmp/nginx/scgi && \
    chown -R appuser:appgroup /tmp/nginx

RUN apk add --no-cache nginx ca-certificates && \
    mkdir -p /var/lib/nginx/logs /var/lib/nginx/tmp && \
    chown -R nginx:nginx /var/lib/nginx

RUN mkdir -p /tmp/nginx && chown -R appuser:appgroup /tmp/nginx
# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "Starting backend..."' >> /start.sh && \
    echo 'chmod -R 777 ./backend/pb_data' >> /start.sh && \
    echo './main.bin serve --http=0.0.0.0:8090 &' >> /start.sh && \
    echo 'BACKEND_PID=$!' >> /start.sh && \
    echo 'echo "Starting frontend..."' >> /start.sh && \
    echo 'cd frontend && HOST=0.0.0.0 PORT=3001 NODE_ENV=production NUXT_PUBLIC_API_BASE=http://localhost:8090 bun .output/server/index.mjs &' >> /start.sh && \
    echo 'FRONTEND_PID=$!' >> /start.sh && \
    echo 'echo "Starting nginx..."' >> /start.sh && \
    echo 'nginx -g "daemon off; pid /tmp/nginx.pid; error_log /dev/stderr warn;" &' >> /start.sh && \
    echo 'NGINX_PID=$!' >> /start.sh && \
    echo 'echo "All services started. Waiting for termination..."' >> /start.sh && \
    echo 'trap "echo Stopping services...; kill $BACKEND_PID $FRONTEND_PID $NGINX_PID; exit" TERM INT' >> /start.sh && \
    echo 'wait' >> /start.sh && \
    chmod +x /start.sh

USER appuser

CMD ["/start.sh"]