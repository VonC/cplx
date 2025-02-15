Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [DllImport("user32.dll", CharSet = CharSet.Auto, ExactSpelling = true)]
    public static extern void keybd_event(byte bVk, byte bScan, int dwFlags, int dwExtraInfo);
}
"@

$VK_MENU = 0x12       # Alt key
$VK_TAB  = 0x09       # Tab key
$VK_ENTER = 0x0D      # Enter key
$KEYEVENTF_EXTENDEDKEY = 0x1
$KEYEVENTF_KEYUP = 0x2

# Press Alt
[Win32]::keybd_event($VK_MENU, 0, $KEYEVENTF_EXTENDEDKEY, 0)
# Press Tab (while Alt is held)
[Win32]::keybd_event($VK_TAB, 0, $KEYEVENTF_EXTENDEDKEY, 0)
Start-Sleep -Milliseconds 100
# Release Tab
[Win32]::keybd_event($VK_TAB, 0, $KEYEVENTF_EXTENDEDKEY -bor $KEYEVENTF_KEYUP, 0)
# Release Alt, finalizing the Alt+Tab switch
[Win32]::keybd_event($VK_MENU, 0, $KEYEVENTF_EXTENDEDKEY -bor $KEYEVENTF_KEYUP, 0)
Start-Sleep -Milliseconds 100
# Press Enter to select the window
[Win32]::keybd_event($VK_ENTER, 0, $KEYEVENTF_EXTENDEDKEY, 0)
Start-Sleep -Milliseconds 100
# Release Enter
[Win32]::keybd_event($VK_ENTER, 0, $KEYEVENTF_EXTENDEDKEY -bor $KEYEVENTF_KEYUP, 0)