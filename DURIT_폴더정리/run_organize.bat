@echo off
chcp 65001 >nul
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0organize_durit.ps1" -Root "%~dp0."
pause
