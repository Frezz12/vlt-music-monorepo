FROM golang:1.25-alpine AS build-backend

WORKDIR /app

COPY backend/go.mod backend/go.sum ./

RUN go mod download

COPY ./backend ./

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o dist/main.bin .

EXPOSE 8090

ENTRYPOINT ["./main.bin", "serve", "--http=0.0.0.0:8090"]