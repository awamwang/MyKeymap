#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook true

#include lib/translation.ahk
#Include lib/Functions.ahk
#Include lib/Actions.ahk
#Include lib/KeymapManager.ahk
#Include lib/InputTipWindow.ahk
#Include lib/Utils.ahk

; #WinActivateForce   ; 先关了遇到相关问题再打开试试
; InstallKeybdHook    ; 这个可以重装 keyboard hook, 提高自己的 hook 优先级, 以后可能会用到
; ListLines False     ; 也许能提升一点点性能 ( 别抱期待 ), 当有这个需求时再打开试试
; #Warn All, Off      ; 也许能提升一点点性能 ( 别抱期待 ), 当有这个需求时再打开试试

try DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") ; 多显示器不同缩放比例会导致问题: https://www.autohotkey.com/boards/viewtopic.php?f=14&t=13810
SetMouseDelay 0                                           ; SendInput 可能会降级为 SendEvent, 此时会有 10ms 的默认 delay
SetWinDelay 0                                             ; 默认会在 activate, maximize, move 等窗口操作后睡眠 100ms
A_MaxHotkeysPerInterval := 256                            ; 默认 70 可能有点低, 即使没有热键死循环也触发警告
SendMode "Event"                                          ; 执行 SendInput 的期间会短暂卸载 Hook, 这时候松开引导键会丢失 up 事件, 所以 Event 模式更适合 MyKeymap
SetKeyDelay 0                                             ; 默认 10 太慢了, https://www.reddit.com/r/AutoHotkey/comments/gd3z4o/possible_unreliable_detection_of_the_keyup_event/
ProcessSetPriority "High"
SetWorkingDir("../")
InitTrayMenu()
InitKeymap()
OnExit(MyKeymapExit)
#include ../data/custom_functions.ahk

InitKeymap()
{
  taskSwitch := TaskSwitchKeymap("e", "d", "s", "f", "c", "space")
  mouseTip := false
  slow := MouseKeymap("slow mouse", false, mouseTip, 10, 13, "T0.13", "T0.01", 1, "T0.2", "T0.03")
  fast := MouseKeymap("fast mouse", false, mouseTip, 110, 70, "T0.13", "T0.01", 1, "T0.2", "T0.03", slow)
  slow.Map("*space", slow.LButtonUp())

  capsHook := InputHook("", "{CapsLock}{Esc}", "bb,ca,cc,cmd,dd,dm,ex,ga,gg,gj,kp,ld,lj,ly,mm,ms,mu,no,pd,rb,rex,sd,se,sl,sp,ss,td,th,tm,vm,we,wf,wt")
  capsHook.KeyOpt("{CapsLock}", "S")
  capsHook.KeyOpt("{Backspace}", "N")
  capsHook.OnChar := PostCharToCaspAbbr
  capsHook.OnKeyDown := PostBackspaceToCaspAbbr
  Run("bin\MyKeymap-CommandInput.exe")


  ; 路径变量
  programs := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"

  ; 窗口组
  GroupAdd("MY_WINDOW_GROUP__1", "Stardew Valley ahk_class SDL_app")
  GroupAdd("MY_WINDOW_GROUP__1", "ahk_exe Rune Factory 3 Special.exe")
  GroupAdd("MY_WINDOW_GROUP_1", "ahk_exe chrome.exe")
  GroupAdd("MY_WINDOW_GROUP_1", "ahk_exe msedge.exe")
  GroupAdd("MY_WINDOW_GROUP_1", "ahk_exe firefox.exe")

  KeymapManager.GlobalKeymap.DisabledAt := "ahk_group MY_WINDOW_GROUP__1"

  ; CapsLock
  km5 := KeymapManager.NewKeymap("*CapsLock", "CapsLock", "", "")
  km := km5
  km.Map("*c", _ => SoundControl())
  km.Map("*z", _ => CopySelectedAsPlainText())
  km.Map("*.", _ => MakeWindowDraggable())
  km.Map("*a", _ => CenterAndResizeWindow(1370, 930))
  km.Map("*b", _ => MinimizeWindow())
  km.Map("*e", _ => Send("^!{tab}"), taskSwitch)
  km.Map("*g", _ => ToggleWindowTopMost())
  km.Map("*p", _ => GoToNextVirtualDesktop())
  km.Map("*q", _ => MaximizeWindow())
  km.Map("*r", _ => LoopRelatedWindows())
  km.Map("*s", _ => CenterAndResizeWindow(1200, 800))
  km.Map("*t", BindWindow())
  km.Map("*v", _ => MoveWindowToNextMonitor())
  km.Map("*w", _ => GoToLastWindow())
  km.Map("*x", _ => SmartCloseWindow())
  km.Map("*y", _ => GoToPreviousVirtualDesktop())
  km.Map("*,", fast.LButtonDown()), slow.Map("*,", slow.LButtonDown())
  km.Map("*/", _ => MoveMouseToCaret()), slow.Map("*/", _ => MoveMouseToCaret())
  km.Map("*;", fast.ScrollWheelRight), slow.Map("*;", slow.ScrollWheelRight)
  km.Map("*h", fast.ScrollWheelLeft), slow.Map("*h", slow.ScrollWheelLeft)
  km.Map("*i", fast.MoveMouseUp, slow), slow.Map("*i", slow.MoveMouseUp)
  km.Map("*j", fast.MoveMouseLeft, slow), slow.Map("*j", slow.MoveMouseLeft)
  km.Map("*k", fast.MoveMouseDown, slow), slow.Map("*k", slow.MoveMouseDown)
  km.Map("*l", fast.MoveMouseRight, slow), slow.Map("*l", slow.MoveMouseRight)
  km.Map("*m", fast.RButton()), slow.Map("*m", slow.RButton())
  km.Map("*n", fast.LButton()), slow.Map("*n", slow.LButton())
  km.Map("*o", fast.ScrollWheelDown), slow.Map("*o", slow.ScrollWheelDown)
  km.Map("*u", fast.ScrollWheelUp), slow.Map("*u", slow.ScrollWheelUp)
  km.Map("*0", _ => (Send("{home}+{end}{backspace}"), Send("{text}i love homura and hikari"), Sleep(1000), Send("{enter}yes{enter}")))
  km.Map("*d", _ => CenterAndResizeWindow(1740, 1000))
  km.Map("singlePress", _ => EnterCapslockAbbr(capsHook))

  ; CapsLock + F
  km6 := KeymapManager.AddSubKeymap(km5, "*f", "CapsLock + F", "")
  km := km6
  km.Map("*a", _ => ActivateOrRun("ahk_exe Appetizer.exe", "G:\Projects\104手机自动化\工具\Appetizer-win32-x64\Appetizer.exe"))
  km.Map("*b", _ => ActivateOrRun("ahk_exe  C:\Program Files\Billfish\Billfish.exe", "C:\Program Files\Billfish\Billfish.exe"))
  km.Map("*c", _ => ActivateOrRun("ahk_exe Code.exe", "shortcuts\Visual Studio Code.lnk"))
  km.Map("*d", _ => ActivateOrRun("ahk_exe C:\Program Files (x86)\Microsoft\Edge Dev\Application\msedge.exe", "shortcuts\Microsoft Edge Dev.lnk"))
  km.Map("*e", _ => ActivateOrRun("ahk_exe C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe", "shortcuts\Microsoft Edge.lnk", "", "", false, true, false))
  km.Map("*g", _ => ActivateOrRun("ahk_exe chrome.exe", "shortcuts\Google Chrome.lnk"))
  km.Map("*h", _ => ActivateOrRun("- Microsoft Visual Studio", "shortcuts\Visual Studio 2019.lnk"))
  km.Map("*i", _ => ActivateOrRun("ahk_exe Typora.exe", "shortcuts\Typora.lnk"))
  km.Map("*j", _ => ActivateOrRun("ahk_exe JianyingPro.exe", "shortcuts\剪映专业版.lnk"))
  km.Map("*k", _ => ActivateOrRun("Kimi.ai - 帮你看更大的世界 ahk_class Chrome_WidgetWin_1", "shortcuts\Kimi.ai - 帮你看更大的世界.lnk"))
  km.Map("*l", _ => ActivateOrRun("ahk_exe Logseq.exe", "C:\Users\Administrator\AppData\Local\Logseq\Logseq.exe"))
  km.Map("*m", _ => ActivateOrRun("ahk_exe 幕布.exe", "shortcuts\幕布.lnk"))
  km.Map("*n", _ => ActivateOrRun("ahk_exe Notion.exe", "shortcuts\Notion.lnk"))
  km.Map("*o", _ => ActivateOrRun("ahk_exe dopus.exe", "shortcuts\Directory Opus.lnk"))
  km.Map("*p", _ => ActivateOrRun("ahk_class PotPlayer64", "S:\Program Files\PotPlayerPortable64\PotPlayerPortable.exe"))
  km.Map("*q", _ => ActivateOrRun("ahk_exe Q-Dir.exe", "C:\Program Files\00MUST\Q-Dir\Q-Dir.exe"))
  km.Map("*r", _ => ActivateOrRun("ahk_exe FoxitReader.exe", "D:\install\Foxit Reader\FoxitReader.exe"))
  km.Map("*s", _ => ActivateOrRun("ahk_exe sublime_text.exe", "shortcuts\Sublime Text.lnk"))
  km.Map("*t", _ => ActivateOrRun("ahk_exe WindowsTerminal.exe", "shortcuts\终端预览.lnk"))
  km.Map("*v", _ => ActivateOrRun("ahk_exe v2rayN.exe", "S:\Program Files\00MUST\v2rayN-With-Core\v2rayN.exe"))
  km.Map("*w", _ => ActivateOrRun("ahk_exe Wiz.exe", "shortcuts\Wiz.lnk"))
  km.Map("*x", _ => ActivateOrRun("ahk_exe Code.exe", "shortcuts\Visual Studio Code.lnk"))
  km.Map("*y", _ => ActivateOrRun("ahk_exe Nox.exe", "shortcuts\夜神模拟器.lnk"))
  km.Map("singlePress", _ => (Send("{blind}{f}")))

  ; CapsLock + Space
  km7 := KeymapManager.AddSubKeymap(km5, "*Space", "CapsLock + Space", "")
  km := km7
  km.Map("*c", _ => ActivateOrRun("ahk_exe Cursor.exe", "shortcuts\Cursor.lnk"))
  km.Map("*d", _ => ActivateOrRun("ahk_exe datagrip64.exe", "shortcuts\DataGrip.lnk"))
  km.Map("*f", _ => ActivateOrRun("ahk_exe FoxitPDFReader.exe", "C:\Program Files (x86)\Foxit Software\Foxit PDF Reader\FoxitPDFReader.exe"))
  km.Map("*l", _ => ActivateOrRun("ahk_exe localsend_app.exe", "shortcuts\LocalSend.lnk"))
  km.Map("*m", _ => ActivateOrRun("ahk_exe mailmaster.exe", "shortcuts\网易邮箱大师.lnk"))
  km.Map("*o", _ => ActivateOrRun("ahk_exe obs64.exe", "shortcuts\OBS Studio (64bit).lnk"))
  km.Map("*p", _ => ActivateOrRun("ahk_exe putty.exe", "shortcuts\PuTTY.lnk"))
  km.Map("*t", _ => ActivateOrRun("ahk_exe hexin.exe", "C:\Users\Administrator\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\同花顺.lnk"))
  km.Map("*v", _ => ActivateOrRun("ahk_exe v2rayN.exe", "S:\Program Files\00MUST\v2rayN-With-Core\v2rayN.exe"))
  km.Map("*w", _ => ActivateOrRun("ahk_exe WinSCP.exe", "S:\Program Files (x86)\WinSCP\WinSCP.exe"))
  km.Map("singlePress", _ => (Send("{blind}{space}")))

  ; 3 模式
  km10 := KeymapManager.NewKeymap("*3", "3 模式", "", "")
  km := km10
  km.RemapKey("0", "F10")
  km.RemapKey("2", "F2")
  km.RemapKey("4", "F4")
  km.RemapKey("5", "F5")
  km.RemapKey("9", "F9")
  km.RemapKey("b", "7")
  km.RemapKey("e", "F11")
  km.RemapKey("h", "0")
  km.RemapKey("i", "5")
  km.RemapKey("j", "1")
  km.RemapKey("k", "2")
  km.RemapKey("l", "3")
  km.RemapKey("m", "9")
  km.RemapKey("n", "8")
  km.RemapKey("o", "6")
  km.RemapKey("r", "F12")
  km.RemapKey("t", "Volume_Up")
  km.RemapKey("u", "4")
  km.RemapKey("w", "Volume_Down")
  km.RemapKey("space", "F1")
  km.Map("singlePress", _ => (Send("{blind}{3}")))
  km.Map("*/", km.ToggleLock)

  ; Custom Hotkeys
  km1 := KeymapManager.NewKeymap("customHotkeys", "Custom Hotkeys", "", "")
  km := km1
  km.RemapInHotIf("RAlt", "LControl")
  km.Map("!'", _ => MyKeymapReload(), , , , "S")
  km.Map("!+'", _ => MyKeymapToggleSuspend(), , , , "S")
  km.Map("!f17", _ => MyKeymapReload(), , , , "S")
  km.Map("!CapsLock", _ => ToggleCapslock())


  KeymapManager.GlobalKeymap.Enable()
}

ExecCapslockAbbr(command) {
  ; 路径变量
  programs := "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\"

  switch command {
    case "bb":
      ActivateOrRun("Bing 词典", "msedge.exe", "--app=https://www.bing.com/dict/search?q={selected}", "", false, false, false)
    case "ca":
      ActivateOrRun("计算器", "calc.exe")
    case "cc":
      ActivateOrRun("", "shortcuts\Visual Studio Code.lnk", "-n `"{selected}`"", "", false, false, false)
    case "cmd":
      ActivateOrRun("ahk_exe cmd.exe", "cmd.exe", "/k cd /d %userprofile%", "", false, false, false)
    case "dd":
      ActivateOrRun("", "shell:downloads")
    case "dm":
      ActivateOrRun("", A_WorkingDir)
    case "ex":
      MyKeymapExit()
    case "ga":
      ActivateOrRun("Game ahk_exe explorer.exe", A_Desktop "\Game")
    case "gg":
      ActivateOrRun("", "https://www.google.com/search?q={selected}")
    case "gj":
      SystemShutdown()
    case "kp":
      CloseWindowProcesses()
    case "ld":
      BrightnessControl()
    case "lj":
      ActivateOrRun("", "shell:RecycleBinFolder")
    case "ly":
      ActivateOrRun("", "ms-settings:bluetooth")
    case "mm":
      ActivateOrRun("MyKeymap2 - Visual Studio Code", "shortcuts\Visual Studio Code.lnk", "D:\MyFiles\MyKeymap2", "", false, false, false)
    case "ms":
      ActivateOrRun("my_site - Visual Studio Code", "shortcuts\Visual Studio Code.lnk", "D:\project\my_site", "", false, false, false)
    case "mu":
      MuteActiveApp()
    case "no":
      ActivateOrRun("记事本", "notepad.exe")
    case "pd":
      ShowActiveProcessInFolder()
    case "rb":
      SystemReboot(true)
    case "rex":
      SystemRestartExplorer()
    case "sd":
      ActivateOrRun("SD.bat ahk_class CASCADIA_HOSTING_WINDOW_CLASS", "G:\Projects\19AI\AIGC\sd.webui\run.bat", "", "G:\Projects\19AI\AIGC\sd.webui", false, false, false)
    case "se":
      MyKeymapOpenSettings()
    case "sl":
      SystemSleep()
    case "sp":
      ActivateOrRun("Spotify", "https://open.spotify.com/")
    case "ss":
      ActivateOrRun("ahk_exe Spotify.exe", "shortcuts\Spotify.lnk")
    case "td":
      ActivateOrRun("ahk_exe tdxw.exe", "S:\StockProgram\通达信犀牛股\TDX_xili\tdxw.exe")
    case "th":
      ActivateOrRun("ahk_exe D:\Programs\同花顺软件\同花顺\hexin.exe", "shortcuts\同花顺.lnk", "", "", false, true, false)
    case "tm":
      Send("^+{esc}")
    case "vm":
      ActivateOrRun("", "ms-settings:apps-volume")
    case "we":
      ActivateOrRun("网易云音乐", "shortcuts\网易云音乐.lnk")
    case "wf":
      ActivateOrRun("", "ms-availablenetworks:")
    case "wt":
      ActivateOrRun("", "wt.exe", "-d `"{selected}`"", "", false, false, false)
  }
}

ExecSemicolonAbbr(command) {
}

InitTrayMenu() {
  A_TrayMenu.Delete()
  A_TrayMenu.Add(Translation().menu_pause, TrayMenuHandler)
  A_TrayMenu.Add(Translation().menu_exit, TrayMenuHandler)
  A_TrayMenu.Add(Translation().menu_reload, TrayMenuHandler)
  A_TrayMenu.Add(Translation().menu_settings, TrayMenuHandler)
  A_TrayMenu.Add(Translation().menu_window_spy, TrayMenuHandler)
  A_TrayMenu.Default := Translation().menu_pause
  A_TrayMenu.ClickCount := 1

  A_IconTip := "MyKeymap 2.0-beta33 created by 咸鱼阿康"
  TraySetIcon("./bin/icons/logo.ico", , true)
}


#HotIf
RAlt::LControl

#HotIf