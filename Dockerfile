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

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "Starting backend..."' >> /start.sh && \
    echo 'chmod -R 777 ./pb_data' >> /start.sh && \
    echo './main.bin serve --http=0.0.0.0:8090 &' >> /start.sh && \
    echo 'BACKEND_PID=$!' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "Starting frontend..."' >> /start.sh && \
    echo 'cd frontend && HOST=0.0.0.0 PORT=3001 NODE_ENV=production bun .output/server/index.mjs &' >> /start.sh && \
    echo 'FRONTEND_PID=$!' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "Waiting 3 seconds for services to start..."' >> /start.sh && \
    echo 'sleep 3' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "Starting nginx..."' >> /start.sh && \
    # Запускаем nginx от имени пользователя nginx
    echo 'nginx -c /etc/nginx/nginx.conf -g "daemon off; user nginx appgroup;" &' >> /start.sh && \
    echo 'NGINX_PID=$!' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "All services started successfully!"' >> /start.sh && \
    echo 'echo "Backend PID: $BACKEND_PID"' >> /start.sh && \
    echo 'echo "Frontend PID: $FRONTEND_PID"' >> /start.sh && \
    echo 'echo "Nginx PID: $NGINX_PID"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'trap "echo \"Stopping services...\"; kill $BACKEND_PID $FRONTEND_PID $NGINX_PID; exit" TERM INT' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'wait' >> /start.sh && \
    chmod +x /start.sh

USER appuser

CMD ["/start.sh"]