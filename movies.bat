@ECHO OFF
PowerShell.exe -NoLogo -NoProfile -NonInteractive -NoExit -ExecutionPolicy unrestricted -Command "& %~d0%~p0%~n0.ps1" %*
