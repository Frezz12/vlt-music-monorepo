# Backend Dockerfile для PocketBase
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Установите зависимости для сборки
RUN apk add --no-cache git

# Копируем исходный код
COPY . .

# Собираем PocketBase
RUN go build -o main .

# Production stage
FROM alpine:latest

WORKDIR /app

# Создаем пользователя внутри контейнера
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Устанавливаем зависимости времени выполнения
RUN apk --no-cache add ca-certificates

# Копируем бинарник
COPY --from=builder --chown=appuser:appgroup /app/main .

# Создаем директорию для данных
RUN mkdir -p /app/pb_data && chown -R appuser:appgroup /app/pb_data

USER appuser

EXPOSE 8090

CMD ["./main", "serve", "--http=0.0.0.0:8090"]