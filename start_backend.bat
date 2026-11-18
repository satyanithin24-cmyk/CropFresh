@echo off
cd /d "%~dp0"
set "PATH=C:\Users\ASUS\.local\bin;%USERPROFILE%\.local\bin;%PATH%"
echo Starting CropFresh FastAPI Backend on http://localhost:8000 ...
if exist "%~dp0.venv\Scripts\python.exe" (
  "%~dp0.venv\Scripts\python.exe" -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
) else (
  uv run --offline --with fastapi --with uvicorn --with pydantic --with python-multipart --with pillow --with numpy python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
)
pause
