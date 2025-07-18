#Requires AutoHotkey v2.0
#SingleInstance

SetTimer(AutoSave, 1000)

AutoSave() {
    if (WinActive("ahk_exe lmms.exe"))
        Send("^s")
}