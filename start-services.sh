#!/bin/bash

echo "Starting backend..."
docker-compose up -d backend

echo "Waiting for backend to be ready..."
until curl -f http://localhost:8090/api/health > /dev/null 2>&1; do
    echo "Backend not ready yet, waiting..."
    sleep 5
done

echo "Backend is ready! Starting frontend..."
docker-compose up -d frontend

echo "Starting nginx..."
docker-compose up -d nginx

echo "All services started!"