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

# НЕ устанавливаем nginx - Docploy сам проксирует

COPY --from=build-backend /app/dist/main.bin ./
RUN chmod +x ./main.bin

COPY --from=build-frontend /app/.output ./frontend/.output
COPY --from=build-frontend /app/node_modules ./frontend/node_modules
COPY --from=build-frontend /app/package.json ./frontend/

# Create data directory for backend
RUN mkdir -p ./pb_data

# Простой стартовый скрипт БЕЗ nginx
RUN echo '#!/bin/sh' > /start.sh && \
    echo '' >> /start.sh && \
    echo '# Запускаем backend' >> /start.sh && \
    echo './main.bin serve --http=0.0.0.0:8090 &' >> /start.sh && \
    echo 'BACKEND_PID=$!' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Запускаем frontend' >> /start.sh && \
    echo 'cd frontend' >> /start.sh && \
    echo 'HOST=0.0.0.0 NODE_ENV=production bun .output/server/index.mjs &' >> /start.sh && \
    echo 'FRONTEND_PID=$!' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'echo "Backend: http://0.0.0.0:8090"' >> /start.sh && \
    echo 'echo "Frontend: http://0.0.0.0:3000"' >> /start.sh && \
    echo '' >> /start.sh && \
    echo '# Ждем сигнала завершения' >> /start.sh && \
    echo 'trap "kill $BACKEND_PID $FRONTEND_PID; exit" TERM INT' >> /start.sh && \
    echo '' >> /start.sh && \
    echo 'wait' >> /start.sh && \
    chmod +x /start.sh

EXPOSE 3001 8090

CMD ["/start.sh"]