#SingleInstance force
#Requires AutoHotkey v2.0

#Include helper_functions.ahk

; windows + Alt + P ruft Windows Terminal auf
#!p:: OpenProgram("WindowsTerminal.exe", "wt")

; windows + Alt + N ruft Notepad++ auf
#!n:: OpenProgram("Notepad.exe")

#!c:: OpenProgram("comet.exe", , tag := "comet_main")