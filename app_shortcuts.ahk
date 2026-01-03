#SingleInstance force
#Requires AutoHotkey v2.0

#Include helper_functions.ahk
#Include settings.ahk

; Disables Microsoft Office key conflicting with Hyper key
+!^LWin::
#^!Shift::
#^+Alt::
#!+Ctrl::
{
    Send "{Blind}{vkE8}"
    return
}

; Hyper + P ruft Windows Terminal auf
Hotkey(hyper . "p", (*) => OpenProgram("WindowsTerminal.exe", "wt"))

; Hyper + N ruft Notepad++ auf
Hotkey(hyper . "n", (*) => OpenProgram("Notepad.exe"))

; Hyper + C ruft Comet AI im Standardbrowser auf, immer dieselbe Instanz
Hotkey(hyper . "c", (*) => OpenProgram("comet.exe", , "--new-window `"https://www.perplexity.ai/`"", tag :=
    "comet_main"))