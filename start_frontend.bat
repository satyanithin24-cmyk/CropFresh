@echo off
cd /d "%~dp0"
set "PATH=C:\Users\ASUS\.local\bin;%USERPROFILE%\.local\bin;%PATH%"

netstat -ano | findstr ":8000 " | findstr "LISTENING" >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
  echo Backend not detected on port 8000. Starting CropFresh Backend automatically...
  start "CropFresh Backend" cmd /c call "%~dp0start_backend.bat"
  timeout /t 5 /nobreak >nul
)

where npm >nul 2>&1
if %ERRORLEVEL% EQU 0 (
  echo Node/npm detected. Starting Next.js dev server on http://localhost:3000 ...
  cd frontend
  if not exist node_modules call npm install
  call npm run dev
) else (
  echo Starting CropFresh Frontend server on http://localhost:3000 ...
  if exist "%~dp0.venv\Scripts\python.exe" (
    "%~dp0.venv\Scripts\python.exe" frontend\dev_server.py
  ) else (
    uv run --offline python frontend\dev_server.py
  )
)
pause
