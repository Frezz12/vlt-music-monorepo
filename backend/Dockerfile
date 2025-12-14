# -------- Builder --------
# Используем стабильную версию (1.25 еще нет)
FROM golang:1.25.5-alpine3.23 AS builder

WORKDIR /app

# Устанавливаем git (нужен для скачивания зависимостей Go)
RUN apk add --no-cache git

# Сначала копируем файлы зависимостей (для кеширования слоев Docker)
COPY go.mod go.sum ./
RUN go mod download

# Теперь копируем исходный код (благодаря .dockerignore папка pb_data НЕ скопируется)
COPY . .

# Собираем бинарник (CGO_ENABLED=0 для статической линковки на Alpine)
RUN CGO_ENABLED=0 go build -o main .

# -------- Runner --------
FROM alpine:latest

WORKDIR /app

# Устанавливаем сертификаты (для отправки почты и внешних запросов)
RUN apk --no-cache add ca-certificates

# Создаем пользователя, чтобы не запускать от root
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Копируем бинарник из билдера
COPY --from=builder /app/main .

# Если нужны JS-миграции или статика, раскомментируйте:
# COPY --from=builder /app/migrations ./migrations
# COPY --from=builder /app/pb_hooks ./pb_hooks

RUN mkdir -p /app/pb_data && \
    chown -R appuser:appgroup /app

USER appuser

EXPOSE 8090

# Запускаем
CMD ["./main", "serve", "--http=0.0.0.0:8090"]