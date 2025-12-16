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

# Установка nginx и создание нужных директорий
RUN apk add --no-cache nginx ca-certificates && \
    mkdir -p /var/lib/nginx/logs /var/lib/nginx/tmp /var/log/nginx /run/nginx && \
    chown -R nginx:nginx /var/lib/nginx && \
    chmod -R 755 /var/lib/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chmod -R 755 /var/log/nginx && \
    chown -R nginx:nginx /run/nginx && \
    chmod -R 755 /run/nginx

COPY --from=build-backend /app/dist/main.bin ./
RUN chmod +x ./main.bin

COPY --from=build-frontend /app/.output ./frontend/.output
COPY --from=build-frontend /app/node_modules ./frontend/node_modules
COPY --from=build-frontend /app/package.json ./frontend/

COPY nginx.conf /etc/nginx/nginx.conf

# Create data directory for backend
RUN mkdir -p ./pb_data

# Создаем пользователя и группу
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup && \
    # Добавляем appuser в группу nginx
    addgroup nginx appgroup && \
    # Назначаем права
    chown -R appuser:appgroup /app && \
    chown -R nginx:appgroup /var/lib/nginx && \
    chown -R nginx:appgroup /var/log/nginx && \
    chown -R nginx:appgroup /run/nginx && \
    chmod -R 775 /var/lib/nginx && \
    chmod -R 775 /var/log/nginx && \
    chmod -R 775 /run/nginx

EXPOSE 8090

# Создаем временные директории с правильными правами
RUN mkdir -p /tmp/nginx/client_body \
             /tmp/nginx/proxy \
             /tmp/nginx/fastcgi \
             /tmp/nginx/uwsgi \
             /tmp/nginx/scgi && \
    chown -R nginx:appgroup /tmp/nginx && \
    chmod -R 775 /tmp/nginx

# Исправляем конфигурацию nginx, чтобы логи писались в stdout/stderr
RUN sed -i 's|error_log .*;|error_log /dev/stderr warn;|' /etc/nginx/nginx.conf && \
    sed -i 's|access_log .*;|access_log /dev/stdout main;|' /etc/nginx/nginx.conf

RUN echo '<html><body><h1>Test Page</h1><p>If you see this, nginx works!</p></body></html>' > /app/test.html


# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "=== STARTING APPLICATION ==="' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Запускаем backend' >> /start.sh && \
    echo 'echo "1. Starting backend (PocketBase)..."' >> /start.sh && \
    echo 'chmod -R 777 ./pb_data' >> /start.sh && \
    echo './main.bin serve --http=0.0.0.0:8090 > /tmp/backend.log 2>&1 &' >> /start.sh && \
    echo 'BACKEND_PID=$!' >> /start.sh && \
    echo 'sleep 2' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Запускаем frontend' >> /start.sh && \
    echo 'echo "2. Starting frontend (Nuxt)..."' >> /start.sh && \
    echo 'cd frontend' >> /start.sh && \
    echo 'HOST=0.0.0.0 PORT=3001 NODE_ENV=production bun .output/server/index.mjs > /tmp/frontend.log 2>&1 &' >> /start.sh && \
    echo 'FRONTEND_PID=$!' >> /start.sh && \
    echo 'sleep 5' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Проверяем, что сервисы работают' >> /start.sh && \
    echo 'echo "3. Checking services..."' >> /start.sh && \
    echo 'if curl -s http://127.0.0.1:8090/api/ > /dev/null; then' >> /start.sh && \
    echo '  echo "   ✓ Backend is running on port 8090"' >> /start.sh && \
    echo 'else' >> /start.sh && \
    echo '  echo "   ✗ Backend failed to start"' >> /start.sh && \
    echo '  cat /tmp/backend.log' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'if curl -s http://127.0.0.1:3001 > /dev/null; then' >> /start.sh && \
    echo '  echo "   ✓ Frontend is running on port 3001"' >> /start.sh && \
    echo 'else' >> /start.sh && \
    echo '  echo "   ✗ Frontend failed to start"' >> /start.sh && \
    echo '  cat /tmp/frontend.log' >> /start.sh && \
    echo 'fi' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Запускаем nginx' >> /start.sh && \
    echo 'echo "4. Starting nginx..."' >> /start.sh && \
    echo 'nginx -g "daemon off; error_log /dev/stderr warn;" &' >> /start.sh && \
    echo 'NGINX_PID=$!' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo ""' >> /start.sh && \
    echo 'echo "=== ALL SERVICES STARTED ==="' >> /start.sh && \
    echo 'echo "Backend:  http://localhost:8090"' >> /start.sh && \
    echo 'echo "Frontend: http://localhost:3001"' >> /start.sh && \
    echo 'echo "Nginx:    http://localhost:80 (proxy)"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'trap "echo \"Shutting down...\"; kill $BACKEND_PID $FRONTEND_PID $NGINX_PID 2>/dev/null; exit 0" TERM INT' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'wait' >> /start.sh && \
    chmod +x /start.sh

USER appuser

CMD ["/start.sh"]