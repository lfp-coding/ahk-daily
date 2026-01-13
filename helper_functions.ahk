#Requires AutoHotkey v2.0

; Tracks hwnd of opened programs if the tag option is used
global TaggedWindows := Map()

OpenProgram(name, alias := "", options := "", tag := "") {
    exe_name := RegExReplace(name, ".*[\\/](.+)$", "$1")

    if tag {
        global TaggedWindows
        ; Tag parameter provided - toggle specific tagged window instance
        ; Check if we already have a tagged window stored for this tag
        if TaggedWindows.Has(tag) {
            hwnd := TaggedWindows.Get(tag)

            ; Verify the stored window still exists and belongs to the correct program
            if WinExist("ahk_id " . hwnd) && WinGetProcessName("ahk_id " . hwnd) = exe_name {
                ; Tagged window exists - toggle its state
                if WinActive("ahk_id " . hwnd)
                    WinMinimize("ahk_id " . hwnd)
                else
                    WinActivate("ahk_id " . hwnd)
                return
            }
            else {
                ; Stored window no longer valid - remove from map
                TaggedWindows.Delete(tag)
            }
        }
        else {
            ; Tagged window not found - launch the program
            ; Get list of existing windows

            beforeList := WinGetList("ahk_exe " name)
            beforeCount := beforeList.Length

            Run (alias ? alias : name) (options ? " " options : "")
            ; Wait for new window and rename it with the tag
            Sleep 2000
            if tag = "comet_ai" {
                Send("{F11}")
            } ; Specific action for comet_ai to go fullscreen
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
                            TaggedWindows.Set(tag, window)
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
        if WinExist("ahk_exe " . exe_name) {
            if WinActive("ahk_exe " . exe_name)
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
