#Requires AutoHotkey v2.0

; Tracks hwnd of opened programs if the tag option is used
global TaggedWindows := Map()

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
OpenProgram(name, alias := "", tag := "") {

    if tag {
        global TaggedWindows

        exe_name := StrSplit(name, " ")[1]
        ; Check if we already have a tagged window stored for this tag
        if TaggedWindows.Has(tag) {
            hwnd := TaggedWindows.Get(tag)

            ; Verify the stored window still exists and belongs to the correct program
            if WinExist("ahk_id " . hwnd) && WinGetProcessName("ahk_id " . hwnd) = exe_name {
                ; Window still valid - toggle it (minimize if active, activate if inactive)
                if WinActive("ahk_id " . hwnd)
                    WinMinimize("ahk_id " . hwnd)
                else
                    WinActivate("ahk_id " . hwnd)
                return
            } else {
                ; Window no longer exists or process changed - remove stale entry
                TaggedWindows.Delete(tag)
            }
        }

        ; Tag doesn't exist or was stale - capture the window handle of the newly opened instance
        ; First, get list of all currently open instances of this program
        old_hwnd := WinGetList("ahk_exe " . exe_name)

        ; Launch the program
        Run alias ? alias : name

        ; delay to allow the program to open
        Sleep 500

        ; Get updated list of all open instances
        new_hwnd := WinGetList("ahk_exe " . exe_name)
        ; Find the newly opened window by comparing old and new lists
        ; Using Map.Has() is more efficient than nested loop iteration
        for hwnd in new_hwnd {
            ; Check if this window is NOT in the old list
            if !old_hwnd.Has(hwnd) {
                ; Found the new window - store its handle and activate it
                TaggedWindows.Set(tag, hwnd)
                WinActivate("ahk_id " . hwnd)
                return
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
