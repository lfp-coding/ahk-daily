#Requires AutoHotkey v2.0

/**
 * OpenProgram - Opens or toggles a program window
 * 
 * @param {String} name - The executable name of the program (e.g., "notepad.exe")
 * @param {String} alias - [Optional] The full path or alternative command to run if the program is not found
 * @param {String} tag - [Optional] A unique identifier to track a specific window instance across calls.
 *                       When tag is provided, the same window will be toggled each time the hotkey is pressed,
 *                       rather than toggling any instance of the program. Useful for managing multiple instances
 *                       of the same program independently (e.g., "notepad_main", "notepad_temp")
 * 
 * @description
 * Without tag parameter:
 *   - Toggles any open instance of the program (minimize if active, activate if inactive)
 *   - If multiple instances exist, behavior depends on the first match found
 * 
 * With tag parameter:
 *   - Remembers the specific window by storing its handle (hwnd) in TaggedWindows Map
 *   - On first call: Captures the window handle of the newly opened instance
 *   - On subsequent calls: Always toggles the same window instance
 *   - Automatically removes stale tags when the window is closed
 * 
 * @example
 * OpenProgram("notepad.exe")
 * OpenProgram("firefox.exe", "C:\Program Files\Mozilla Firefox\firefox.exe")
 * OpenProgram("notepad.exe", , "notepad_main")  ; Always toggles the same window instance
 */
OpenProgram(name, alias := "", options := "", tag := "") {

    if tag {
        ; Tag parameter provided - toggle specific tagged window instance
        if WinExist(tag) {
            if WinActive(tag)
                WinMinimize()
            else
                WinActivate()
        }
        else {
            ; Tagged window not found - launch the program
            ; Get list of existing windows

            beforeList := WinGetList("ahk_exe " name)
            beforeCount := beforeList.Length

            Run (alias ? alias : name) (options ? " " options : "")
            ; Wait for new window and rename it with the tag
            Sleep 2000
            loop {
                afterList := WinGetList("ahk_exe " name)
                if (afterList.Length > beforeCount) {
                    ; New window detected
                    for window in afterList {
                        found := false
                        for existingWindow in beforeList {
                            if (existingWindow = window) {
                                found := true
                                break
                            }
                        }
                        if !found {
                            ; This is the new window
                            WinSetTitle(tag, "ahk_id " . window)
                            return
                        }
                    }
                    Sleep 100
                }
            }

        }

    }
    else {
        ; No tag parameter - simple toggle behavior: toggle any open instance of the program
        if WinExist("ahk_exe " . name) {
            if WinActive("ahk_exe " . name)
                WinMinimize()
            else
                WinActivate()
        }
        else {
            ; Program not running - launch it
            Run alias ? alias : name
        }
    }
}
