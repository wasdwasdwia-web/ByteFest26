@echo off
setlocal
cd /d "%~dp0"
where py >nul 2>nul
if errorlevel 1 goto bundled_python
if not exist ".venv\Scripts\python.exe" py -3 -m venv .venv
goto check_venv
:bundled_python
set "PYTHON_EXE=%USERPROFILE%\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe"
if not exist "%PYTHON_EXE%" (
  echo Python 3.11 or newer is required. Install Python from https://www.python.org/downloads/ and select Add Python to PATH.
  pause
  exit /b 1
)
if not exist ".venv\Scripts\python.exe" "%PYTHON_EXE%" -m venv .venv
:check_venv
if not exist ".venv\Scripts\python.exe" (
  echo Could not create the Python environment.
  pause
  exit /b 1
)
if exist ".venv\.jarvis-installed" goto dependencies_done
.venv\Scripts\python.exe -c "import fastapi,uvicorn,pydantic_settings,httpx,multipart,pypdf,docx" >nul 2>nul
if not errorlevel 1 goto dependencies_ready
echo Installing JARVIS dependencies. This requires an internet connection the first time.
.venv\Scripts\python.exe -m pip install --upgrade pip
if errorlevel 1 goto failed
.venv\Scripts\python.exe -m pip install -e ".[documents]"
if errorlevel 1 goto failed
:dependencies_ready
type nul > ".venv\.jarvis-installed"
:dependencies_done
if not exist ".env" copy ".env.example" ".env" >nul
if not exist ".env-configured" (
  echo Add your AI provider key to the .env file, then press any key to continue.
  start "" notepad.exe ".env"
  pause
  type nul > ".env-configured"
)
.venv\Scripts\python.exe launcher.py
goto end
:failed
echo Dependency installation failed. Check your internet connection and try again.
pause
:end
endlocal
