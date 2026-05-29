:: =====================================================================
:: Senior-Dev-Buddy CLI Wrapper f?r CMD
:: %~dp0 sorgt daf?r, dass der Pfad relativ zur Batch-Datei aufgel?st wird.
:: %* reicht alle ?bergebenen Argumente eins zu eins an die PowerShell weiter.
:: =====================================================================
@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0buddy.ps1" %*
