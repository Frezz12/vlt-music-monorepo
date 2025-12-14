@echo off
echo Starting backend...
docker-compose up -d backend

echo Waiting for backend to be ready...
:wait
curl -f http://localhost:8090/api/health >nul 2>&1
if %errorlevel% equ 0 (
    echo Backend is ready! Starting frontend...
    docker-compose up -d frontend
    
    echo Starting nginx...
    docker-compose up -d nginx
    
    echo All services started!
    goto end
) else (
    echo Backend not ready yet, waiting...
    timeout /t 5 /nobreak >nul
    goto wait
)

:end