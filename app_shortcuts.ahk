#SingleInstance force
#Requires AutoHotkey v2.0

; windows + Alt + P ruft Windows Terminal auf
#!p:: {
    ; Check if Windows Terminal is already running
    if WinExist("ahk_exe WindowsTerminal.exe") {
        ; If it's the active window, minimize it
        if WinActive("ahk_exe WindowsTerminal.exe")
            WinMinimize
        else
            WinActivate  ; Otherwise, bring it to focus
    }
    else
        Run "wt"  ; If not running, start it
}
